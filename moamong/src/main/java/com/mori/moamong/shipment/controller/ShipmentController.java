
package com.mori.moamong.shipment.controller;

import java.util.HashMap;

import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.mori.moamong.shipment.service.ShipmentService;

@RequiredArgsConstructor
@Controller
public class ShipmentController {

    private final ShipmentService shipmentService;

    // 가상 운송장 생성 및 배송 등록
    @RequestMapping(value = "/shipment/create.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public HashMap<String, Object> createShipment(
            @RequestParam HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {
            resultMap = shipmentService.createShipment(map);

        } catch (Exception e) {
            e.printStackTrace();

            resultMap.put("result", "fail");
            resultMap.put("message", "배송 등록에 실패했습니다.");
        }

        return resultMap;
    }

    // 택배넷 배송조회
    @RequestMapping(value = "/shipment/tracking.dox", method = RequestMethod.GET)
    @ResponseBody
    public String getTrackingInfo(
            @RequestParam("trackingNumber") String trackingNumber) {

        return shipmentService.getTrackingInfo(trackingNumber);
    }

    // 배송 이력 조회
    @RequestMapping(value = "/shipment/history.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public HashMap<String, Object> getShipmentHistory(
            @RequestParam Long shipmentId) {

        return shipmentService.getShipmentHistory(shipmentId);
    }

}
