package spark.benchmark

import benchmark.common.Utils
import org.apache.spark.sql.streaming.Trigger
import org.apache.spark.sql.{DataFrame, Dataset, ForeachWriter, SparkSession}
import org.json.JSONObject
import redis.clients.jedis._

import java.util
import java.util.UUID
import scala.jdk.CollectionConverters._

object AdvertisingSpark {


  case class AdsEvent(user_id: String, page_id: String, ad_id: String, ad_type: String, event_type: String, event_time: String, ip_address: String)

  private object AdsEvent {
    def apply(rawStr: String): AdsEvent = {
      val parser = new JSONObject(rawStr)
      AdsEvent(
        parser.getString("user_id"),
        parser.getString("page_id"),
        parser.getString("ad_id"),
        parser.getString("ad_type"),
        parser.getString("event_type"),
        parser.getString("event_time"),
        parser.getString("ip_address"))
    }
  }

  private case class AdsFiltered(ad_id: String, event_time: String)

  private case class AdsEnriched(campaign_id: String, ad_id: String, event_time: String)

  private case class AdsCalculated(ad_id: String, campaign_id: String, window_time: Long)

  private case class AdsCounted(campaign_id: String, window_time: Long, count: Long = 0)


  def main(args: Array[String]): Unit = {
    val commonConfig = Utils.findAndReadConfigFile("./conf/localConf.yaml", true).asInstanceOf[java.util.Map[String, Any]]
//    val commonConfig = Utils.findAndReadConfigFile(args(0), true).asInstanceOf[java.util.Map[String, Any]];
    val timeDivisor = commonConfig.get("time.divisor") match {
      case n: Number => n.longValue()
      case other => throw new ClassCastException(other + " not a Number")
    }

    val batchSize = commonConfig.get("spark.batchtime") match {
      case n: Number => n.longValue()
      case other => throw new ClassCastException(other + " not a Number")
    }
    val topic = commonConfig.get("kafka.topic") match {
      case s: String => s
      case other => throw new ClassCastException(other + " not a String")
    }

    val redisHost = commonConfig.get("redis.host") match {
      case s: String => s
      case other => throw new ClassCastException(other + " not a String")
    }

    val appName = commonConfig.get("spark.app.name") match {
      case s: String => s
      case other => throw new ClassCastException(other + " not a String")
    }


    val masterHost = commonConfig.get("spark.master") match {
      case s: String => s
      case other => throw new ClassCastException(other + " not a String")
    }


    // Create context with 2 second batch interval
    //    val sparkConf = new SparkConf().setAppName("AdvertisingSpark")
    //    val ssc = new StreamingContext(sparkConf, Milliseconds(batchSize))


    val spark = SparkSession.builder().appName(appName)
      .master(masterHost).getOrCreate()

    import spark.implicits._

    spark.sparkContext.setLogLevel("WARN")


    val kafkaHosts = commonConfig.get("kafka.brokers").asInstanceOf[java.util.List[String]] match {
      case l: java.util.List[String] => l.asScala.toSeq
      case other => throw new ClassCastException(other + " not a List[String]")
    }
    val kafkaPort = commonConfig.get("kafka.port") match {
      case n: Number => n.toString
      case other => throw new ClassCastException(other + " not a Number")
    }

    val brokers = joinHosts(kafkaHosts, kafkaPort)

    System.err.println(
      "Trying to connect to Kafka at " + brokers)
    //    val messages = KafkaUtils.createDirectStream[String, String](
    //      ssc, LocationStrategies.PreferConsistent,ConsumerStrategies.Subscribe[String, String](topicsSet, kafkaParams))
    val messages: DataFrame = spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", brokers)
      .option("subscribe", topic)
      //.schema(schema)  : we cannot set a schema for kafka source. Kafka source has a fixed schema of (key, value)
      .load()

    val kafkaData: Dataset[AdsEvent] = messages.selectExpr("CAST(value AS STRING)").map(r ⇒ AdsEvent(r.getString(0)))


    //Filter the records if event type is "view"
    val filteredOnView = kafkaData.filter("event_type = 'view'")


    //project the event, basically filter the fields.
    val projected = filteredOnView.select("ad_id", "event_time").map(row => AdsFiltered(row.getAs(0), row.getAs(1)))


    //Note that the Storm benchmark caches the results from Redis, we don't do that here yet
    val redisJoined = projected.mapPartitions(queryRedisTopLevel(_, redisHost))


    val campaign_timeStamp = redisJoined.map(event => AdsCalculated(event.ad_id, event.campaign_id, timeDivisor * (event.event_time.toLong / timeDivisor)))
    //each record in the RDD: key:(campaign_id : String, window_time: Long),  Value: (ad_id : String)

    val totalEventsPerCampaignTime = campaign_timeStamp.groupByKey(p => (p.campaign_id, p.window_time))
      .count().as("count")
    //
    //    totalEventsPerCampaignTime.writeStream
    //      .outputMode("complete")
    //      .format("console")
    //      .start()

    val writer = new ForeachWriter[((String, Long), Long)] {

      override def open(partitionId: Long, version: Long): Boolean = {
        true
      }

      override def process(value: ((String, Long), Long)): Unit = {
        writeRedisTopLevel(AdsCounted(value._1._1, value._1._2, value._2), redisHost)
      }

      override def close(errorOrNull: Throwable): Unit = {
      }
    }
    val writeToConsole = totalEventsPerCampaignTime
      .writeStream.foreach(writer)
      .trigger(Trigger.ProcessingTime(batchSize))
      .outputMode("update").start()

    spark.streams.awaitAnyTermination()
  }

  private def joinHosts(hosts: Seq[String], port: String): String = {
    val joined = new StringBuilder("")
    hosts.foreach({
      joined.append(",").append(_).append(":").append(port)
    })
    joined.toString().substring(1)
  }
  //noinspection DuplicatedCode
  private def queryRedisTopLevel(eventsIterator: Iterator[AdsFiltered], redisHost: String): Iterator[AdsEnriched] = {
    val pool = new Pool(new JedisPool(new JedisPoolConfig(), redisHost, 6379, 2000))
    val ad_to_campaign = new util.HashMap[String, String]()
    val eventsIteratorMap = eventsIterator.map(event => queryRedis(pool, ad_to_campaign, event))
    pool.underlying.getResource.close()
    eventsIteratorMap
  }

  private def queryRedis(pool: Pool, ad_to_campaign: util.HashMap[String, String], event: AdsFiltered): AdsEnriched = {
    val ad_id = event.ad_id
    val campaign_id_cache = ad_to_campaign.get(ad_id)
    if (campaign_id_cache == null) {
      pool.withJedisClient { client =>
        val campaign_id_temp = Dress.up(client).get(ad_id)
        if (campaign_id_temp.isDefined) {
          val campaign_id = campaign_id_temp.get
          ad_to_campaign.put(ad_id, campaign_id)
          AdsEnriched(campaign_id, event.ad_id, event.event_time)
          //campaign_id, ad_id, event_time
        } else {
          AdsEnriched("Campaign_ID not found in either cache nore Redis for the given ad_id!", event.ad_id, event.event_time)
        }
      }
    } else {
      AdsEnriched(campaign_id_cache, event.ad_id, event.event_time)
    }
  }

  //noinspection DuplicatedCode
  private def writeRedisTopLevel(campaign_window_counts: AdsCounted, redisHost: String): Unit = {

    val pool = new Pool(new JedisPool(new JedisPoolConfig(), redisHost, 6379, 2000))
    writeWindow(pool, campaign_window_counts)
    pool.underlying.getResource.close()

  }

  private def writeWindow(pool: Pool, campaign_window_counts: AdsCounted): String = {

    val campaign = campaign_window_counts.campaign_id
    val window_timestamp = campaign_window_counts.window_time.toString
    val window_seenCount = campaign_window_counts.count
    pool.withJedisClient { client =>

      val dressUp = Dress.up(client)
      var windowUUID = dressUp.hmget(campaign, window_timestamp).head.get
      if (windowUUID == null) {
        windowUUID = UUID.randomUUID().toString
        dressUp.hset(campaign, window_timestamp, windowUUID)
        var windowListUUID: String = dressUp.hmget(campaign, "windows").head.get
        if (windowListUUID == null) {
          windowListUUID = UUID.randomUUID.toString
          dressUp.hset(campaign, "windows", windowListUUID)
        }
        dressUp.lpush(windowListUUID, window_timestamp)
      }
      dressUp.hincrBy(windowUUID, "seen_count", window_seenCount)
      dressUp.hset(windowUUID, "time_updated", System.currentTimeMillis().toString)
      return window_seenCount.toString
    }

  }
}
