package com.example.demo.service;

import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

public class VideoStateMachine {

    public enum State {
        WATCHING_VIDEO,
        PAUSED_VIDEO,
        WATCHING_AD,
        COMPLETED_VIDEO
    }

    private final Map<String, State> userVideoStates = new HashMap<>();

    private final Map<State, Function<String, State>> stateTransitions = Map.of(
        State.WATCHING_VIDEO, this::handleWatchingVideo,
        State.PAUSED_VIDEO, this::handlePausedVideo,
        State.WATCHING_AD, this::handleWatchingAd,
        State.COMPLETED_VIDEO, state -> State.COMPLETED_VIDEO
    );

    public State handleEvent(String viewerId, String videoId, String event) {
        String key = generateKey(viewerId, videoId);
        return userVideoStates.compute(key, (k, currentState) -> {
            if (currentState == null) {
                currentState = State.WATCHING_VIDEO;
            }
            return stateTransitions.get(currentState).apply(event);
        });
    }

    private State handleWatchingVideo(String event) {
        return switch (event) {
            case "pause_event" -> State.PAUSED_VIDEO;
            case "ad_break_start_event" -> State.WATCHING_AD;
            case "end_event" -> State.COMPLETED_VIDEO;
            default -> State.WATCHING_VIDEO;
        };
    }

    private State handlePausedVideo(String event) {
        return "play_event".equals(event) ? State.WATCHING_VIDEO : State.PAUSED_VIDEO;
    }

    private State handleWatchingAd(String event) {
        return switch (event) {
            case "ad_break_end_event" -> State.WATCHING_VIDEO;
            case "end_event" -> State.COMPLETED_VIDEO;
            default -> State.WATCHING_AD;
        };
    }

    private String generateKey(String viewerId, String videoId) {
        return viewerId + "_" + videoId;
    }

    public State getCurrentState(String viewerId, String videoId) {
        return userVideoStates.getOrDefault(generateKey(viewerId, videoId), State.WATCHING_VIDEO);
    }
}

