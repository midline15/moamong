package com.mori.moamong.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class MembershipGradeDto {
    private Long gradeId;
    private String gradeCode;
    private String gradeName;
    private BigDecimal minPurchaseAmount;
    private LocalDateTime createdAt;
}
