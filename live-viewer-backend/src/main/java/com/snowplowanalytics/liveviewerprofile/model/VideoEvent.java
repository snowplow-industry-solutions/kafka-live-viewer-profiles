package com.snowplowanalytics.liveviewerprofile.model;

import java.time.Instant;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.snowplowanalytics.liveviewerprofile.service.VideoStateMachine.State;

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.experimental.Accessors;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;

@NoArgsConstructor
@AllArgsConstructor
@DynamoDbBean
public class VideoEvent {
    @JsonProperty("video_ts")
    double videoTs;
    @JsonProperty("collector_tstamp")
    Instant collectorTstamp;
    @JsonProperty("event_id")
    String eventId;
    @JsonProperty("event_name")
    String eventName;
    @JsonProperty("viewer_id")
    String viewerId;
    int adsClicked;
    int adsSkipped;
    int adId;
    State status;

    @DynamoDbAttribute("video_ts")
    public double getVideoTs() {
        return videoTs;
    }
    public void setVideoTs(double videoTs) {
        this.videoTs = videoTs;
    }

    @DynamoDbAttribute("collector_tstamp")
    public Instant getCollectorTstamp() {
        return collectorTstamp;
    }
    public void setCollectorTstamp(Instant collectorTstamp) {
        this.collectorTstamp = collectorTstamp;
    }

    @DynamoDbAttribute("event_id")
    public String getEventId() {
        return eventId;
    }
    public void setEventId(String eventId) {
        this.eventId = eventId;
    }

    @DynamoDbAttribute("event_name")
    public String getEventName() {
        return eventName;
    }
    public void setEventName(String eventName) {
        this.eventName = eventName;
    }

    @DynamoDbPartitionKey
    @DynamoDbAttribute("viewer_id")
    public String getViewerId() {
        return viewerId;
    }
    public void setViewerId(String viewerId) {
        this.viewerId = viewerId;
    }

    public int getAdsClicked() {
        return adsClicked;
    }
    public void setAdsClicked(int adsClicked) {
        this.adsClicked = adsClicked;
    }

    public int getAdsSkipped() {
        return adsSkipped;
    }
    public void setAdsSkipped(int adsSkipped) {
        this.adsSkipped = adsSkipped;
    }

    public int getAdId() {
        return adId;
    }
    public void setAdId(int adId) {
        this.adId = adId;
    }

    public State getStatus() {
        return status;
    }
    public void setStatus(State status) {
        this.status = status;
    }
}