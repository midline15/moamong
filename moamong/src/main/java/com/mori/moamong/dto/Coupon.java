package com.mori.moamong.dto;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class Coupon {

	// COUPON
	private Long couponId;
	private String couponName;
	private String discountType;
	private Integer discountValue;
	private Integer minimumOrderAmount;
	private Integer maximumDiscountAmount;
	private LocalDateTime validFrom;
	private LocalDateTime validUntil;

	// 쿠폰 발급 설정
	private String issueType;
	private String issueStatus;

	// MEMBER_COUPON
	private Long memberCouponId;
	private Long memberId;
	private LocalDateTime issuedAt;
	private LocalDateTime usedAt;
	private LocalDateTime revokedAt;
	private String couponStatus;

	// ORDER_COUPON
	private Long orderId;
	private Integer discountAmount;

	// 회원 정보
	private String loginId;
	private String memberName;

	// 화면 표시
	private String displayStatus;

	// 관리자 발급 통계
	private Integer issuedCount;
	private Integer usedCount;
	private Integer availableCount;
}