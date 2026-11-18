package com.mori.moamong.dto;

import lombok.Data;

@Data
public class EventImageDto {
    private Long imageId;
    private Long eventId;
    private String imageUrl;
    private String imageOriginName;
    private String imageName;
    private String imageSize;
    private String imageType;
    private Integer displayOrder;
}
