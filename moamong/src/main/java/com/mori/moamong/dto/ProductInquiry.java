package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ProductInquiry {
    private Long inqId;
    private Long productId;
    private Long memberId;
    private String inqContent;
    private String inqStatus;
    private String answerContent;
    private Long answeredBy;
    private LocalDateTime answeredAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String isSecret;
    private String isDeleted;
}
