package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ReviewDto {
    private Long reviewId;
    private Long memberId;
    private Long productId;
    private Long orderItemId;
    private Integer rating;
    private String reviewContent;
    private String reviewStatus;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
