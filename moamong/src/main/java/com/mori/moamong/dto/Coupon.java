package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Coupon {

    private Long memberCouponId;
    private Long memberId;
    private Long couponId;

    private String couponName;
    private String discountType;
    private Long discountValue;

    private Long minimumOrderAmount;
    private Long maximumDiscountAmount;

    private LocalDateTime issuedAt;
    private LocalDateTime validFrom;
    private LocalDateTime validUntil;
    private LocalDateTime usedAt;

    private String couponStatus;
    private String displayStatus;

    private Long orderId;
    private Long discountAmount;
}
