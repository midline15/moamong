package com.mori.moamong.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class OrderCancelDto {
    private Long cancelId;
    private Long orderId;
    private String cancelReason;
    private String cancelStatus;
    private BigDecimal cancelAmount;
    private LocalDateTime createdAt;
}
