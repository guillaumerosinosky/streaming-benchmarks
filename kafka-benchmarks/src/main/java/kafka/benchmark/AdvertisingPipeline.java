package kafka.benchmark;

import benchmark.common.Utils;
import benchmark.common.advertising.CampaignProcessorCommon;
import benchmark.common.advertising.RedisAdCampaignCache;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.Options;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.KeyValue;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.Transformer;
import org.apache.kafka.streams.processor.TimestampExtractor;
import org.apache.kafka.streams.processor.api.ContextualProcessor;
import org.apache.kafka.streams.processor.api.ProcessorContext;
import org.apache.kafka.streams.processor.api.Record;
import org.json.JSONObject;

import java.io.Serializable;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Properties;


public class AdvertisingPipeline {

    private static int timeDivisor;
    private static String redisServerHost;

    public static class RowData implements Serializable {

        RowData(
                String user_id,
                String page_id,
                String ad_id,
                String ad_type,
                String event_type,
                String event_time,
                String ip_address
        ) {
            this.user_id = user_id;
            this.page_id = page_id;
            this.ad_id = ad_id;
            this.ad_type = ad_type;
            this.event_type = event_type;
            this.event_time = event_time;
            this.ip_address = ip_address;
        }

        String user_id;
        String page_id;
        String ad_id;
        String ad_type;
        String event_type;
        String event_time;
        String ip_address;
    }

    public static void main(final String[] args) throws Exception {

        Options opts = new Options();
        opts.addOption("conf", true, "Path to the config file.");

        CommandLineParser parser = new DefaultParser();
        CommandLine cmd = parser.parse(opts, args);
        String configPath = cmd.getOptionValue("conf");
        //noinspection rawtypes
        Map commonConfig = Utils.findAndReadConfigFile(configPath, true);

        redisServerHost = (String) commonConfig.get("redis.host");
        String kafkaTopic = (String) commonConfig.get("kafka.topic");
        String kafkaServerHosts = Utils.joinHosts((List<String>) commonConfig.get("kafka.brokers"),
                                                  Integer.toString((Integer) commonConfig.get("kafka.port")));

        timeDivisor = ((Number) commonConfig.get("time.divisor")).intValue();


        Properties config = new Properties();
        config.put(StreamsConfig.DEFAULT_TIMESTAMP_EXTRACTOR_CLASS_CONFIG, TimestampExtractorImpl.class.getName());
        config.put(StreamsConfig.APPLICATION_ID_CONFIG, "kafka-benchmark");
        config.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaServerHosts);
        config.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        config.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        StreamsBuilder builder = new StreamsBuilder();
        builder.stream(kafkaTopic)
               .mapValues(o -> deserializeBolt(o.toString()))
               .filter((o, rowData) -> rowData.event_type.equals("view"))
               .mapValues(rowData -> new EnrichedData(rowData.ad_id, rowData.event_time))
               .transform(RedisJoinBolt::new)
               .process(CampaignProcessor::new);
        KafkaStreams streams = new KafkaStreams(builder.build(), config);
        streams.start();


    }

    public static class TimestampExtractorImpl implements TimestampExtractor {

        public TimestampExtractorImpl() {
        }

        @Override
        public long extract(ConsumerRecord<Object, Object> consumerRecord, long l) {
            return new Date().getTime();
        }
    }


    public static class RedisJoinBolt implements Transformer<Object, EnrichedData, KeyValue<String, EnrichedData>> {

        RedisAdCampaignCache redisAdCampaignCache;

        @Override
        public void init(org.apache.kafka.streams.processor.ProcessorContext context) {
            this.redisAdCampaignCache = new RedisAdCampaignCache(redisServerHost);
            this.redisAdCampaignCache.prepare();
        }

        @Override
        public KeyValue<String, EnrichedData> transform(final Object s, final EnrichedData input) {

            String campaign_id = this.redisAdCampaignCache.execute(input.ad_id);
            if (campaign_id == null) {
                return null;
            }
            input.campaign_id = campaign_id;

            return KeyValue.pair(null, input);
        }

        @Override
        public void close() {
        }
    }


    public static class CampaignProcessor extends ContextualProcessor<String, EnrichedData, String, EnrichedData> {

        CampaignProcessorCommon campaignProcessorCommon;

        @Override
        public void init(final ProcessorContext<String, EnrichedData> context) {
            this.campaignProcessorCommon = new CampaignProcessorCommon(redisServerHost, (long) timeDivisor);
            this.campaignProcessorCommon.prepare();
        }

        @Override
        public void process(Record record) {
            String campaign_id = ((EnrichedData) record.value()).campaign_id;
            String event_time = ((EnrichedData) record.value()).event_time;
            campaignProcessorCommon.execute(campaign_id, event_time);
        }
    }


    private static RowData deserializeBolt(String value) {
        JSONObject obj = new JSONObject(value);
        return new RowData(obj.getString("user_id"),
                           obj.getString("page_id"),
                           obj.getString("ad_id"),
                           obj.getString("ad_type"),
                           obj.getString("event_type"),
                           obj.getString("event_time"),
                           obj.getString("ip_address"));
    }


}
