package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Member {
	
	// =====================================
	// 회원 기본 정보
	// =====================================

	// 회원 번호
	private Long memberId;

	// 회원 로그인 아이디
	private String loginId;

	// 회원 비밀번호
	private String password;

	// 회원 이름
	private String memberName;

	// 회원 이메일
	private String email;

	// 회원 전화번호
	private String phone;

	// 회원 권한
	private String role;

	// 회원 상태
	private String status;

	// 회원 가입일
	private LocalDateTime createdAt;

	// 회원 정보 수정일
	private LocalDateTime updatedAt;

	// 회원 탈퇴일
	private LocalDateTime withdrawnAt;

	// 회원 등급
	private String memberGrade;

	// =====================================
	// 소셜 로그인 정보
	// =====================================

	// 소셜 로그인 유형
	private String socialType;

	// 소셜 로그인 사용자 ID
	private String socialUserId;

	// 소셜 로그인 연동일
	private LocalDateTime connectedAt;

	// =====================================
	// 회원 로그인 정보
	// =====================================

	// 최종 로그인 일시 (휴면 처리용)
	private LocalDateTime lastLoginAt;

	// =====================================
	// 회원 구매 정보
	// =====================================

	// 회원 총 결제 금액
	private Long totalPayment;

	// 회원 누적 주문 건수
	private int orderCount;

	// 전체 회원 통계 정보


	// 전체 회원 수
	private int totalCount;

	// 오늘 가입한 회원 수
	private int todayCount;

	// 활성 회원 수
	private int activeCount;

	// 휴면 회원 수
	private int dormantCount;

	// 탈퇴 회원 수
	private int withdrawnCount;
}