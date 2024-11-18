package com.example.demo.model;

import java.time.Instant;

import com.example.demo.service.VideoStateMachine.State;
import com.fasterxml.jackson.annotation.JsonProperty;

public record VideoEvent(
    @JsonProperty("video_ts") double videoTs,
    @JsonProperty("collector_tstamp") Instant collectorTstamp,
    @JsonProperty("event_id") String eventId,
    @JsonProperty("event_name") String eventName,
    @JsonProperty("viewer_id") String viewerId,
    @JsonProperty("adsClicked") int adsClicked,
    @JsonProperty("adsSkipped") int adsSkipped,
    @JsonProperty("adId") int adId,
    State status
) {}