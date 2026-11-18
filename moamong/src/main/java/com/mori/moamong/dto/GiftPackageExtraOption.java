package com.mori.moamong.dto;

import lombok.Data;

@Data
public class GiftPackageExtraOption {
    private Long packageExtraOptionId;
    private Long packageExtraId;
    private String optionName;
    private Integer additionalPrice;
    private Integer displayOrder;
}
