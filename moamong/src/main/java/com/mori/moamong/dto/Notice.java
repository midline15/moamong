package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Notice {
    private Long noticeId;
    private Long adminId;
    private String noticeTitle;
    private String noticeContent;
    private Boolean isPinned;
    private Long viewCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
