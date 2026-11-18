package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CartDto {
    private Long cartId;
    private Long memberId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
