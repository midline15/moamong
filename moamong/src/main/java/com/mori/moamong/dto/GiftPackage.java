package com.mori.moamong.dto;

import lombok.Data;

@Data
public class GiftPackage {
    private Long packageId;
    private String packageName;
    private String packageDescription;
    private String packageGrade;
    private Long packagePrice;
    private String packageStatus;
    private Long viewCount;
    private String updatedAt;
    private String createdAt;

    private String thumbnailUrl;
}
