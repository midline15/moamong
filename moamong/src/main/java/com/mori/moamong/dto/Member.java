
package com.mori.moamong.dto;

import lombok.Data;

@Data
public class Member {

	// 회원 기본 정보
	private Long memberId;
	private String loginId;
	private String password;
	private String memberName;
	private String email;
	private String phone;
	private String role;

	// 회원 계정 상태
	private String status;

	// 회원 가입 및 변경 일자
	private String createdAt;
	private String updatedAt;
	private String withdrawnAt;

	// 회원 등급
	private String memberGrade;

	// 소셜 로그인 정보
	private String socialType;
	private String socialUserId;
	private String connectedAt;

	// 최근 로그인 일자
	private String lastLoginAt;

	// 주문 및 결제 정보
	private Long totalPayment;
	private int orderCount;

	// 회원 통계 정보
	private int totalCount;
	private int todayCount;
	private int activeCount;
	private int dormantCount;
	private int withdrawnCount;
}
