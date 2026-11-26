package com.mori.moamong.point.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mori.moamong.dto.Point;
import com.mori.moamong.point.mapper.PointMapper;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class PointService {

    // DB 조회를 담당하는 Mapper를 가져옵니다.
    private final PointMapper pointMapper;

    // 현재 로그인한 회원의 정보를 확인하기 위해 세션을 가져옵니다.
    private final HttpSession session;

    // 로그인한 회원의 포인트 내역을 조회하는 메서드입니다.
    // Controller에서 전달받은 map을 사용합니다.
    // 조회 결과는 HashMap에 담아서 반환합니다.
    public HashMap<String, Object> getPointList(HashMap<String, Object> map) {

        // Controller에 전달할 결과를 담을 공간입니다.
        HashMap<String, Object> resultMap = new HashMap();

        try {

            // 현재 로그인한 회원의 번호를 세션에서 가져옵니다.
            Object memberId = session.getAttribute("memberId");
            // 로그인하지 않았거나 세션이 만료되었다면
            // 포인트 내역을 조회하지 않습니다.
            /*
             * if (memberId == null) {
             * resultMap.put("result", "fail");
             * resultMap.put("message", "로그인이 필요합니다.");
             * 
             * } else {
             */

            // // 세션에서 가져온 회원 번호를 조회 조건에 넣습니다.
            // map.put("memberId", memberId);

            List<Point> list = pointMapper.selectPointList(map);
            // 조회한 포인트 내역을 list라는 이름으로 저장합니다.
            resultMap.put("list", list);

            // 조회에 성공했다는 표시를 저장합니다.
            resultMap.put("result", "success");
            // }

        } catch (Exception e) {

            // 조회 중 문제가 발생했다는 표시를 저장합니다.
            resultMap.put("result", "fail");

            // 화면에 전달할 오류 메시지를 저장합니다.
            resultMap.put("message", "포인트 내역 조회에 실패했습니다.");

            // 콘솔에 오류 내용을 출력합니다.
            System.out.println(e.getMessage());
        }

        // 완성된 결과를 Controller에 반환합니다.
        return resultMap;
    }

    public void addPointHistory(
            Long memberId,
            Long orderId,
            String historyType,
            int amount,
            String description) {

        int currentBalance = pointMapper.selectPointBalance(memberId);
        int newBalance = currentBalance + amount;

        HashMap<String, Object> map = new HashMap<>();
        map.put("memberId", memberId);
        map.put("orderId", orderId);
        map.put("historyType", historyType);
        map.put("pointAmount", amount);
        map.put("balanceAfter", newBalance);
        map.put("description", description);

        pointMapper.insertPointHistory(map);
    }

}
