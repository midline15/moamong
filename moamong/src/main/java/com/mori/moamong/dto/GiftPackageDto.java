package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class GiftPackageDto {
    private Long packageId;
    private String packageName;
    private String packageDescription;
    private String packageGrade;
    private Long packagePrice;
    private String packageStatus;
    private Long viewCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
