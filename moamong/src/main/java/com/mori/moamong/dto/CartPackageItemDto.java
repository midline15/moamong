package com.mori.moamong.dto;

import lombok.Data;

@Data
public class CartPackageItemDto {
    private Long cartPackageItemId;
    private Long cartItemId;
    private Long packageItemId;
    private Long selectedProductId;
    private String itemRole;
    private Integer additionalPrice;
}
