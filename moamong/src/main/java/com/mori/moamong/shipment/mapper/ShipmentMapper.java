package com.mori.moamong.shipment.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.ShipmentHistory;

@Mapper
public interface ShipmentMapper {

    // 배송 정보 등록
    int insertShipment(HashMap<String, Object> map);

    // 배송 상태 변경
    int updateShipmentStatus(HashMap<String, Object> map);

    // 배송 이력 등록
    int insertShipmentHistory(HashMap<String, Object> map);

    // 배송 이력 조회
    List<ShipmentHistory> selectShipmentHistory(Long shipmentId);

}
