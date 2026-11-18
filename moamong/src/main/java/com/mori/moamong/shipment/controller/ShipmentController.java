package com.mori.moamong.shipment.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.shipment.service.ShipmentService;

@RequiredArgsConstructor
@Controller
public class ShipmentController {
    private final ShipmentService shipmentService;

}
