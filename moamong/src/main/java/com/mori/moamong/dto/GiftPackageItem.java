package com.mori.moamong.dto;

import lombok.Data;

@Data
public class GiftPackageItem {
    private Long packageItemId;
    private Long packageId;
    private Long productId;
    private String itemRole;
    private Integer itemOrder;
    private Long quantity;
}
