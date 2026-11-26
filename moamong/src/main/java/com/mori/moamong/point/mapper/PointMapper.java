package com.mori.moamong.point.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Point;

@Mapper
public interface PointMapper {

    // 회원의 포인트 내역을 조회하는 메서드입니다.
    List<Point> selectPointList(HashMap<String, Object> map);

    // 회원의 현재 포인트 잔액 조회
    Integer selectPointBalance(Long memberId);

    // 포인트 적립 내역 등록
    int insertPointHistory(HashMap<String, Object> map);
    

}