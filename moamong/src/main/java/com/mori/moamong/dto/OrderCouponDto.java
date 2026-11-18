package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class OrderCouponDto {
    private Long orderCouponId;
    private Long orderId;
    private Long memberCouponId;
    private Long discountAmount;
    private LocalDateTime createdAt;
}
