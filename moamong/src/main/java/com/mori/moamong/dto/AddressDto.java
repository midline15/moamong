package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AddressDto {
    private Long addressId;
    private Long memberId;
    private String recipientName;
    private String recipientPhone;
    private String postalCode;
    private String addressDefault;
    private String addressDetail;
    private String addressName;
    private Boolean isDefault;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
