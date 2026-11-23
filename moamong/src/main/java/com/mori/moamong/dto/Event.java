package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Event {
    private Long eventId;
    private String eventTitle;
    private String eventContent;
    private String startedAt;
    private String endedAt;
    private String eventStatus;
    private String createdAt;
    private String thumbnailUrl;    // 목록 카드용 썸네일 (EVENT_IMAGE 조회)
}
