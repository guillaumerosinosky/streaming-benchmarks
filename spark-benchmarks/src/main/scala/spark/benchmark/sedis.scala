package spark.benchmark

import redis.clients.jedis._

import scala.language.implicitConversions

trait Dress {
  implicit def delegateToJedis(d: Wrap): Jedis = d.j

  implicit def fromJedistoScala(j: Jedis): Wrap = up(j)

  class Wrap(val j: Jedis) {
    import collection.JavaConverters._

    def hmget(key: String, values: String*): List[Option[String]] = {
      j.hmget(key,values: _*).asScala.toList.map(Option.apply)
    }


    def get(k: String): Option[String] = {
      val f = j.get(k)
      Option(f)
    }

    def sort(key: String, params: SortingParams): List[String] = {
      j.sort(key,params).asScala.toList
    }
    def sort(key: String):List[String] = {
      j.sort(key).asScala.toList
    }

  }
  def up(j: Jedis) = new Wrap(j)
}
object Dress extends Dress



class Pool(val underlying: JedisPool) {

  def withJedisClient[T](body: Jedis => T): T = {
    val jedis: Jedis = underlying.getResource
    try {
      body(jedis)
    } finally {
      underlying.returnResourceObject(jedis)
    }
  }
}


