package com.mori.moamong.dto;

import lombok.Data;

@Data
public class ShipmentHistory {

    private Long historyId;
    private Long shipmentId;
    private String occurredAt;
    private String location;
    private String statusText;
    private String stage;
    private String timePrecision;
}