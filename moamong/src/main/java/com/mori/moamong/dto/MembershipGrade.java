package com.mori.moamong.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class MembershipGrade {
    private Long gradeId;
    private String gradeCode;
    private String gradeName;
    private BigDecimal minPurchaseAmount;
    private LocalDateTime createdAt;
}
