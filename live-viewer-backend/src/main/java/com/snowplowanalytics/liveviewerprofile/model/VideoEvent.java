package com.snowplowanalytics.liveviewerprofile.model;

import java.time.Instant;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.snowplowanalytics.liveviewerprofile.service.VideoStateMachine.State;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbAttribute;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbBean;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbIgnore;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbPartitionKey;
import software.amazon.awssdk.enhanced.dynamodb.mapper.annotations.DynamoDbSortKey;

@NoArgsConstructor
@AllArgsConstructor
@Setter
@Getter
@Builder
@DynamoDbBean
public class VideoEvent {
    @JsonProperty("viewer_id")
    @Getter(onMethod = @__({@DynamoDbAttribute("viewer_id"), @DynamoDbPartitionKey}))
    String viewerId;

    @JsonProperty("collector_tstamp")
    @Getter(onMethod = @__({@DynamoDbAttribute("collector_tstamp"), @DynamoDbSortKey}))
    Instant collectorTstamp;
 
    @JsonProperty("event_id")
    @Getter(onMethod = @__({@DynamoDbIgnore}))
    String eventId;

    @JsonProperty("event_name")
    @Getter(onMethod = @__({@DynamoDbIgnore}))
    String eventName;

    @JsonProperty("video_ts")
    @Getter(onMethod = @__({@DynamoDbAttribute("video_ts")}))
    double videoTs;
     
    int adsClicked;
    int adsSkipped;
    int adId;
    State status;
}