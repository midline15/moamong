package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class RefundDto {
    private Long refundId;
    private Long returnId;
    private Long orderId;
    private Long memberId;
    private Long refundAmount;
    private String refundMethod;
    private String refundStatus;
    private String refundReason;
    private Long adminId;
    private String refundContent;
    private LocalDateTime requestedAt;
    private LocalDateTime processedAt;
    private LocalDateTime updatedAt;
}
