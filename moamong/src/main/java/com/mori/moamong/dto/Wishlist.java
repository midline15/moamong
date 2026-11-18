package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Wishlist {
    private Long wishlistId;
    private Long memberId;
    private Long productId;
    private Long packageId;
    private LocalDateTime createdAt;
}
