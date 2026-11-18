package com.mori.moamong.dto;

import lombok.Data;

@Data
public class Category {
    private Long categoryId;
    private Long parentCategoryId;
    private String categoryName;
    private Integer categoryDepth;
    private Integer displayOrder;
}
