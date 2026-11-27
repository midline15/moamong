
package com.mori.moamong.shipment.service;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mori.moamong.dto.ShipmentHistory;
import com.mori.moamong.order.service.OrderService;
import com.mori.moamong.shipment.mapper.ShipmentMapper;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class ShipmentService {
    private final ShipmentMapper shipmentMapper;
    private final OrderService orderService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${taekbaenet.api.base-url}")
    private String baseUrl;

    @Value("${taekbaenet.api.token}")
    private String apiToken;

    private final RestTemplate restTemplate = new RestTemplate();

    // 가상 운송장 생성 및 배송조회
    @Transactional(rollbackFor = Exception.class)
    public HashMap<String, Object> createShipment(HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            // 1. 테스트 운송장 번호 지정
            String trackingNumber = "CA123456789KR";

            // 2. 주문 ID 가져오기
            Long orderId = Long.parseLong(map.get("orderId").toString());

            // 3. 택배넷 배송조회
            String trackingInfo = getTrackingInfo(trackingNumber);

            // 4. 택배넷 응답 JSON 파싱
            JsonNode trackingJson = objectMapper.readTree(trackingInfo);

            String statusCode = trackingJson.path("status").path("code").asText();

            // 5. 택배넷 상태를 모아몽 배송 상태로 변환
            String shipmentStatus;

            switch (statusCode) {
                case "accepted":
                    shipmentStatus = "REGISTERED";
                    break;

                case "in_transit":
                case "at_destination_terminal":
                case "out_for_delivery":
                    shipmentStatus = "SHIPPING";
                    break;

                case "delivered":
                    shipmentStatus = "DELIVERED";
                    break;

                case "returned":
                    shipmentStatus = "RETURNED";
                    break;

                default:
                    throw new Exception("처리할 수 없는 배송 상태입니다: " + statusCode);
            }

            // 6. 배송 정보 저장
            map.put("orderId", orderId);
            map.put("courierName", "우체국 EMS");
            map.put("courierCode", "ems");
            map.put("trackingNumber", trackingNumber);
            map.put("shipmentStatus", shipmentStatus);

            shipmentMapper.insertShipment(map);

            // 배송 이력 저장
            JsonNode events = trackingJson.path("events");

            for (JsonNode event : events) {

                HashMap<String, Object> historyMap = new HashMap<>();

                historyMap.put("shipmentId", map.get("shipmentId"));
                historyMap.put("occurredAt", event.path("occurred_at_raw").asText());
                historyMap.put("location", event.path("location").asText());
                historyMap.put("statusText", event.path("status_text").asText());
                historyMap.put("stage", event.path("stage").asText());
                historyMap.put("timePrecision", event.path("time_precision").asText());

                shipmentMapper.insertShipmentHistory(historyMap);
            }

            // 7. 주문 상태 변경
            String orderStatus = shipmentStatus.equals("DELIVERED")
                    ? "DELIVERED"
                    : shipmentStatus.equals("RETURNED")
                            ? "RETURNED"
                            : "배송중";

            orderService.updateAdminOrderStatus(orderId, orderStatus);

            // 8. 결과 반환
            resultMap.put("result", "success");
            resultMap.put("trackingNumber", trackingNumber);
            resultMap.put("trackingInfo", trackingInfo);

        } catch (Exception e) {

            e.printStackTrace();

            resultMap.put("result", "fail");
            resultMap.put("message", "배송 생성에 실패했습니다.");
            throw new RuntimeException("배송 생성에 실패했습니다.", e);
        }

        return resultMap;
    }

    // 택배넷 배송조회
    public String getTrackingInfo(String trackingNumber) {

        if (trackingNumber == null || trackingNumber.isBlank()) {
            throw new IllegalArgumentException("운송장 번호가 필요합니다.");
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(apiToken);
        headers.setAccept(java.util.Collections.singletonList(
                MediaType.APPLICATION_JSON));

        HttpEntity<Void> entity = new HttpEntity<>(headers);

        try {
            ResponseEntity<byte[]> response = restTemplate.exchange(
                    baseUrl + "/v1/tracking/" + trackingNumber,
                    HttpMethod.GET,
                    entity,
                    byte[].class);

            // UTF-8로 응답 본문 변환
            return new String(
                    response.getBody(),
                    StandardCharsets.UTF_8);

        } catch (org.springframework.web.client.HttpStatusCodeException e) {
            System.out.println("택배넷 오류 상태: " + e.getStatusCode());
            System.out.println("택배넷 오류 내용: "
                    + new String(
                            e.getResponseBodyAsByteArray(),
                            StandardCharsets.UTF_8));

            throw e;
        }
    }

    // 배송 이력 조회
    public HashMap<String, Object> getShipmentHistory(Long shipmentId) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            List<ShipmentHistory> historyList = shipmentMapper.selectShipmentHistory(shipmentId);

            resultMap.put("result", "success");
            resultMap.put("historyList", historyList);

        } catch (Exception e) {

            e.printStackTrace();

            resultMap.put("result", "fail");
            resultMap.put("message", "배송 이력 조회에 실패했습니다.");
        }

        return resultMap;
    }
}
