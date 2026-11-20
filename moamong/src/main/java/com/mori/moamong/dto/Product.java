package com.mori.moamong.dto;

import java.util.List;

import lombok.Data;

@Data
public class Product {
    private Long productId;
    private Long categoryId;
    private String productName;
    private String productDescription;
    private Long price;
    private Long stockQuantity;
    private String productStatus;
    private Long viewCount;
    private String createdAt;
    private String updatedAt;

    //이미지 관리용
    private String thumbnailUrl;
    private List<ProductImage> productImageList;
}
