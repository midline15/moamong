package com.mori.moamong.dto;

import lombok.Data;

@Data
public class GiftPackageExtraDto {
    private Long packageExtraId;
    private Long packageId;
    private String extraType;
    private String extraName;
    private Boolean isRequired;
    private Integer displayOrder;
}
