package com.mori.moamong.dto;

import lombok.Data;

@Data
public class OrderItem {
    private Long orderItemId;
    private Long orderId;
    private Long productId;
    private Long packageId;
    private String itemNameSnapshot;
    private Long unitPrice;
    private Long quantity;
    private Long lineAmount;

    private String isReviewed;
}
