package com.mori.moamong.shipment.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.shipment.mapper.ShipmentMapper;

@RequiredArgsConstructor
@Service
public class ShipmentService {
    private final ShipmentMapper shipmentMapper;

}
