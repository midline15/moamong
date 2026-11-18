package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ChatbotMessage {
    private Long messageId;
    private Long chatbotId;
    private String senderType;
    private String messageContent;
    private LocalDateTime createdAt;
}
