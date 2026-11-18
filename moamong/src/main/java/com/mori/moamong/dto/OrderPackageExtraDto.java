package com.mori.moamong.dto;

import lombok.Data;

@Data
public class OrderPackageExtraDto {
    private Long orderPackageExtraId;
    private Long orderItemId;
    private Long sourcePackageExtraOptionId;
    private String extraTypeSnapshot;
    private String optionNameSnapshot;
    private String optionValue;
    private Integer additionalPrice;
}
