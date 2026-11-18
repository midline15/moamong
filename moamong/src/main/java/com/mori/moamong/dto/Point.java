package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Point {
    private Long pointHistoryId;
    private Long memberId;
    private Long orderId;
    private String historyType;
    private Long pointAmount;
    private Long balanceAfter;
    private String description;
    private LocalDateTime createdAt;
}
