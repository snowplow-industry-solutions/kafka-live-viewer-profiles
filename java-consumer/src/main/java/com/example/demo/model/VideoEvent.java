package com.example.demo.model;

import java.time.Instant;

public record VideoEvent(
        double videoTs,
        Instant collectorTstamp,
        String eventId,
        String eventName,
        String viewerId,
        int adsClicked,
        int adsSkipped,
        int adId) {
}