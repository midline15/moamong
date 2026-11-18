package com.mori.moamong.dto;

import lombok.Data;

@Data
public class CartPackageItem {
    private Long cartPackageItemId;
    private Long cartItemId;
    private Long packageItemId;
    private Long selectedProductId;
    private String itemRole;
    private Integer additionalPrice;
}
