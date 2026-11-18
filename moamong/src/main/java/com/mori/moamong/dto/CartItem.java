package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CartItem {
    private Long cartItemId;
    private Long cartId;
    private Long productId;
    private Long packageId;
    private Long quantity;
    private LocalDateTime createdAt;
}
