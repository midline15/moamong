
package com.mori.moamong.admin.model;

import lombok.Data;

@Data
public class Admin {

    // =====================================
    // 회원 기본 정보
    // =====================================

    // 회원 번호
    private String memberId;

    // 회원 로그인 아이디
    private String loginId;

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
    private String createdAt;

    // 회원 등급
    private String memberGrade;


    // =====================================
    // 회원 구매 정보
    // =====================================

    // 회원 총 결제 금액
    private String totalPayment;

    // 회원 누적 주문 건수
    private int orderCount;


    // =====================================
    // 전체 회원 통계 정보
    // =====================================

    // 전체 회원 수
    private int totalCount;

    // 오늘 가입한 회원 수
    private int todayCount;

    // 활성 회원 수
    private int activeCount;

    // 탈퇴 회원 수
    private int dormantCount;

}
