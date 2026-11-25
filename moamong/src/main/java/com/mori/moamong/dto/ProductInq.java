package com.mori.moamong.dto;

import lombok.Data;

@Data
public class ProductInq {
    private Long inqId;
    private Long productId;
    private Long packageId;
    private Long memberId;
    private String inqContent;
    private String inqStatus;
    private String answerContent;
    private Long answeredBy;
    private String answeredAt;
    private String createdAt;
    private String updatedAt;
    private String isSecret;
    private String isDeleted;

    private String memberName;
    private String productName;
}
