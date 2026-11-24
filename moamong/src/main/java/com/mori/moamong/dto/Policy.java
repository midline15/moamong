
package com.mori.moamong.dto;

import lombok.Data;

@Data
public class Policy {

    // 정책 번호
    private Long policyId;

    // 정책 종류 (TERMS, PRIVACY, MARKETING, JOIN, DELIVERY, REFUND)
    private String policyType;

    // 정책 제목
    private String title;

    // 정책 내용
    private String content;

    // 필수 동의 여부 (Y/N)
    private String isRequired;

    // 사용 여부 (Y/N)
    private String isActive;

    // 수정일
    private String updatedAt;

    // 등록일
    private String createdAt;

}
