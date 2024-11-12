package com.example.kafkaconsumer;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class MessageListener {

    @KafkaListener(topics = "snowplow-enriched-good", groupId = "kafka-consumer-group")
    public void listen(String message) {
        System.out.println("Received: " + message);
    }
}

