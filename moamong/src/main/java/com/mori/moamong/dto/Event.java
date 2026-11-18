package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Event {
    private Long eventId;
    private String eventTitle;
    private String eventContent;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private String eventStatus;
    private LocalDateTime createdAt;
}
