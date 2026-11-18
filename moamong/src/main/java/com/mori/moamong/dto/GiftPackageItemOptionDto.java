package com.mori.moamong.dto;

import lombok.Data;

@Data
public class GiftPackageItemOptionDto {
    private Long packageItemOptionId;
    private Long packageItemId;
    private Long optionProductId;
    private Integer additionalPrice;
}
