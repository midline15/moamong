package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class PaymentDto {
    private Long paymentId;
    private Long orderId;
    private String paymentKey;
    private String paymentMethod;
    private Long paymentAmount;
    private String paymentStatus;
    private LocalDateTime paidAt;
    private LocalDateTime createdAt;
}
