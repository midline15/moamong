package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Inquiry {
    private Long inqId;
    private Long memberId;
    private Long adminId;
    private String inqTitle;
    private String inqContent;
    private String answerContent;
    private String inqStatus;
    private String createdAt;
    private String answeredAt;
}
