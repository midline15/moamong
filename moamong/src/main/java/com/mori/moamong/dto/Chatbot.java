package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Chatbot {
    private Long chatbotId;
    private Long memberId;
    private String sessionKey;
    private String chatbotStatus;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
}
