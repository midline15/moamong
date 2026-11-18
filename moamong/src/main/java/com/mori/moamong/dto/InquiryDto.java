package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class InquiryDto {
    private Long inqId;
    private Long memberId;
    private Long adminId;
    private String inqTitle;
    private String inqContent;
    private String answerContent;
    private String inqStatus;
    private LocalDateTime createdAt;
    private LocalDateTime answeredAt;
}
