package com.mori.moamong.dto;

import lombok.Data;

@Data
public class GiftPackageItemOption {
    private Long packageItemOptionId;
    private Long packageItemId;
    private Long optionProductId;
    private Integer additionalPrice;

    private String productName;
    private int productPrice;
    private String thumbnailUrl;
}
