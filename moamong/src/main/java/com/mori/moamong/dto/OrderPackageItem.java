package com.mori.moamong.dto;

import lombok.Data;

@Data
public class OrderPackageItem {
    private Long orderPackageItemId;
    private Long orderItemId;
    private Long sourcePackageItemId;
    private Long productId;
    private String productNameSnapshot;
    private String itemRole;
    private Long quantity;
    private Integer additionalPrice;
}
