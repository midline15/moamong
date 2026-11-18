package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class MemberCoupon {
    private Long memberCouponId;
    private Long memberId;
    private Long couponId;
    private LocalDateTime issuedAt;
    private LocalDateTime usedAt;
    private String couponStatus;
}
