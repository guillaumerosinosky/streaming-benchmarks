package kafka.benchmark;

public class EnrichedData {

    EnrichedData(String ad_id, String event_time) {
        this.ad_id = ad_id;
        this.event_time = event_time;
    }

    String ad_id;
    String campaign_id;
    String event_time;
}