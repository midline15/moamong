package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CouponDto {
    private Long couponId;
    private String couponName;
    private String discountType;
    private Long discountValue;
    private Long minimumOrderAmount;
    private Long maximumDiscountAmount;
    private LocalDateTime validFrom;
    private LocalDateTime validUntil;
}
