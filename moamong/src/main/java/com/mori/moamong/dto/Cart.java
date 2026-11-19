package com.mori.moamong.dto;

import lombok.Data;

@Data
public class Cart {
    private Long cartId;
    private Long memberId;
    private String createdAt;
    private String updatedAt;
}
