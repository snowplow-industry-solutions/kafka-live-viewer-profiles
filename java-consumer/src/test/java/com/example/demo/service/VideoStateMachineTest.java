package com.example.demo.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class VideoStateMachineTest {

    private VideoStateMachine machine;
    private String viewerId = "user123";
    private String videoId = "video456";

    @BeforeEach
    public void setUp() {
        machine = new VideoStateMachine();
    }

    @Test
    public void testInitialState() {
        assertEquals(VideoStateMachine.State.WATCHING_VIDEO, machine.getCurrentState(viewerId, videoId));
    }

    @Test
    public void testPauseEvent() {
        machine.handleEvent(viewerId, videoId, "pause_event");
        assertEquals(VideoStateMachine.State.PAUSED_VIDEO, machine.getCurrentState(viewerId, videoId));
    }

    @Test
    public void testPlayEventFromPaused() {
        machine.handleEvent(viewerId, videoId, "pause_event");
        machine.handleEvent(viewerId, videoId, "play_event");
        assertEquals(VideoStateMachine.State.WATCHING_VIDEO, machine.getCurrentState(viewerId, videoId));
    }

    @Test
    public void testAdBreakStartEvent() {
        machine.handleEvent(viewerId, videoId, "ad_break_start_event");
        assertEquals(VideoStateMachine.State.WATCHING_AD, machine.getCurrentState(viewerId, videoId));
    }

    @Test
    public void testAdBreakEndEvent() {
        machine.handleEvent(viewerId, videoId, "ad_break_start_event");
        machine.handleEvent(viewerId, videoId, "ad_break_end_event");
        assertEquals(VideoStateMachine.State.WATCHING_VIDEO, machine.getCurrentState(viewerId, videoId));
    }

    @Test
    public void testEndEventFromWatchingVideo() {
        machine.handleEvent(viewerId, videoId, "end_event");
        assertEquals(VideoStateMachine.State.COMPLETED_VIDEO, machine.getCurrentState(viewerId, videoId));
    }

    @Test
    public void testEndEventFromWatchingAd() {
        machine.handleEvent(viewerId, videoId, "ad_break_start_event");
        machine.handleEvent(viewerId, videoId, "end_event");
        assertEquals(VideoStateMachine.State.COMPLETED_VIDEO, machine.getCurrentState(viewerId, videoId));
    }
}
