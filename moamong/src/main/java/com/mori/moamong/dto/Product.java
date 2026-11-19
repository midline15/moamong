package com.mori.moamong.dto;

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
}
