package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class OrderDto {
    private Long orderId;
    private Long memberId;
    private String orderNumber;
    private String recipientName;
    private String recipientPhone;
    private String postalCode;
    private String addressDefault;
    private String addressDetail;
    private Long totalProductAmount;
    private Integer totalAdditionalAmount;
    private Long discountAmount;
    private Long usedPoint;
    private Long shippingFee;
    private Long finalAmount;
    private String orderStatus;
    private LocalDateTime orderedAt;
    private LocalDateTime updatedAt;
}
