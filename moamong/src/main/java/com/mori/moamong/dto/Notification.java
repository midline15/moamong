package com.mori.moamong.dto;

import java.time.LocalDateTime;
import lombok.Data;

@Data
public class Notification {
	private Long notificationId;
	private Long memberId;
	private String notificationType;
	private String notificationTitle;
	private String notificationContent;
	private Long relatedId;
	private String isRead;
	private String isImportant;
	private String isDeleted;
	private LocalDateTime createdAt;
	private LocalDateTime readAt;
}
