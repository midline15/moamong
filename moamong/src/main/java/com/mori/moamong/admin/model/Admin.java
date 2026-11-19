package com.mori.moamong.admin.model;

public class Admin {

    // 회원 번호
    private String memberId;

    // 회원 로그인 아이디
    private String loginId;


    // 회원 이름
    private String memberName;

    // 회원 이메일
    private String email;
    
    // 회원 총 결제 금액
    private String totalPayment;

    // 회원 전화번호
    private String phone;

    // 회원 권한
    private String role;

    // 회원 상태
    private String status;

    // 회원 가입일
    private String createdAt;

    // 등급 테이블과 JOIN해서 가져온 회원 등급
    private String memberGrade;
    
    
    private int totalCount;
    private int todayCount;
    private int activeCount;
    private int dormantCount;
    
}
