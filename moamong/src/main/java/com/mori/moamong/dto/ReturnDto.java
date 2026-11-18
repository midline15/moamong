package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ReturnDto {
    private Long returnId;
    private Long orderId;
    private Long productId;
    private Long memberId;
    private String returnReason;
    private String returnContent;
    private String returnStatus;
    private Long refundAmount;
    private Long returnQuantity;
    private String refundStatus;
    private Long adminId;
    private LocalDateTime requestedAt;
    private LocalDateTime processedAt;
    private LocalDateTime updatedAt;
}
