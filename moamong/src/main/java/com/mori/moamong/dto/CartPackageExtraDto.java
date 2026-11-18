package com.mori.moamong.dto;

import lombok.Data;

@Data
public class CartPackageExtraDto {
    private Long cartPackageExtraId;
    private Long cartItemId;
    private Long packageExtraOptionId;
    private Integer additionalPrice;
}
