package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Notification {
    private Long notificationId;
    private Long memberId;
    private String notificationType;
    private String notificationTitle;
    private String notificationContent;
    private Long relatedId;
    private String isRead;
    private LocalDateTime createdAt;
    private LocalDateTime readAt;
}
