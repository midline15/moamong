package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Shipment {
    private Long shipmentId;
    private Long orderId;
    private String courierName;
    private String trackingNumber;
    private String shipmentStatus;
    private LocalDateTime shippedAt;
    private LocalDateTime deliveredAt;
}
