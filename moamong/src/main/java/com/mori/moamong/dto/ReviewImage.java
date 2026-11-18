package com.mori.moamong.dto;

import lombok.Data;

@Data
public class ReviewImage {
    private Long imageId;
    private Long reviewId;
    private String imageUrl;
    private String imageOriginName;
    private String imageName;
    private String imageSize;
    private String imageType;
    private Integer displayOrder;
}
