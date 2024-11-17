package com.example.demo.service;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.example.demo.model.VideoEvent;
import com.example.demo.websocket.WebSocketHandler;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class KafkaConsumerService {

    private final WebSocketHandler webSocketHandler;
    private final ObjectMapper objectMapper;

    @KafkaListener(topics = "${spring.kafka.consumer.topics}", groupId = "${spring.kafka.consumer.group-id}")
    public void listen(String message) {
        System.out.println("Received message from Kafka: " + message);

        try {
            VideoEvent videoEvent = objectMapper.readValue(message, VideoEvent.class);
            System.out.println("Received Video Event: " + videoEvent);
        } catch (Exception e) {
            System.err.println("Error processing message: " + message);
            e.printStackTrace();
        }

        webSocketHandler.broadcast(message);
    }
}
