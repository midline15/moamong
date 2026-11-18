package com.mori.moamong.dto;

import lombok.Data;

@Data
public class ProductImageDto {
    private Long imageId;
    private Long productId;
    private String imageUrl;
    private String imageOriginName;
    private String imageName;
    private String imageSize;
    private String imageType;
    private Integer displayOrder;
}
