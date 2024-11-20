package com.example.demo.service;


import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.example.demo.model.VideoEvent;
import com.example.demo.websocket.WebSocketHandler;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class KafkaConsumerService {

    private final WebSocketHandler webSocketHandler;
    private final ObjectMapper objectMapper;
    private final VideoStateMachine videoStateMachine;

    @KafkaListener(topics = "${spring.kafka.consumer.topics}", groupId = "${spring.kafka.consumer.group-id}")
    public void listen(String message) {
        try {
            VideoEvent videoEvent = objectMapper.readValue(message, VideoEvent.class);
            videoStateMachine.handleEvent(videoEvent);
            VideoEvent updatedVideoEvent = new VideoEvent(
                    videoEvent.videoTs(),
                    videoEvent.collectorTstamp(),
                    videoEvent.eventId(),
                    videoEvent.eventName(),
                    videoEvent.viewerId(),
                    videoEvent.adsClicked(),
                    videoEvent.adsSkipped(),
                    videoEvent.adId(),
                    videoStateMachine.getCurrentState(videoEvent));
            String json = objectMapper.writeValueAsString(updatedVideoEvent);
            webSocketHandler.broadcast(json);
        } catch (Exception e) {
            log.error("Error processing message: " + message, e);
        }
    }
}
