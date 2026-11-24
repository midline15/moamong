package com.mori.moamong.dto;


import java.time.LocalDateTime;

import lombok.Data;

@Data
public class Coupon {

	// COUPON 테이블 정보


	private Long couponId; // 쿠폰 고유 번호
	private String couponName; // 쿠폰 이름
	private String discountType; // 할인 유형 (FIXED / RATE)
	private Integer discountValue; // 할인 금액 또는 할인율
	private Integer minimumOrderAmount; // 최소 주문 금액
	private Integer maximumDiscountAmount; // 최대 할인 금액
	private LocalDateTime validFrom; // 쿠폰 사용 시작일
	private LocalDateTime validUntil; // 쿠폰 사용 종료일

	
	// MEMBER_COUPON 테이블 정보


	private Long memberCouponId; // 회원 쿠폰 고유 번호
	private Long memberId; // 회원 번호
	private LocalDateTime issuedAt; // 쿠폰 발급일
	private LocalDateTime usedAt; // 쿠폰 사용일
	private String couponStatus; // 쿠폰 상태

	
	// ORDER_COUPON 테이블 정보
	

	private Long orderId; // 주문 번호
	private Integer discountAmount; // 실제 할인 금액

	
	// 화면 표시용 정보
	

	private String displayStatus; // 화면에 표시할 쿠폰 상태

}
