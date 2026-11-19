package com.mori.moamong.dto;

import lombok.Data;

@Data
public class CartItem {
    private Long cartItemId;
    private Long cartId;
    private Long productId;
    private Long packageId;
    private Long quantity;
    private String createdAt;
    // 상품 정보
    private String productName;
    private Long price;
}
