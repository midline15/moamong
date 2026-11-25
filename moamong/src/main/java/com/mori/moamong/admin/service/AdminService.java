
package com.mori.moamong.admin.service;

import com.mori.moamong.dto.Policy;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mori.moamong.admin.mapper.AdminMapper;
import com.mori.moamong.admin.model.Admin;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class AdminService {

    private final AdminMapper adminMapper;

    public HashMap<String, Object> getAdminList(HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            // JSP에서 전달한 페이지당 회원 수 가져오기
            String limit = String.valueOf(map.get("limit"));

            // JSP에서 전달한 시작 위치 가져오기
            String offset = String.valueOf(map.get("offset"));

            // limit 값이 없거나 숫자가 아닌 경우 기본값 5 사용
            int pageSize = 5;

            if (!limit.equals("null") && limit.matches("\\d+")) {

                pageSize = Integer.parseInt(limit);

            }

            // offset 값이 없거나 숫자가 아닌 경우 기본값 0 사용
            int startIndex = 0;

            if (!offset.equals("null") && offset.matches("\\d+")) {

                startIndex = Integer.parseInt(offset);

            }

            // 페이지 정보를 SQL에 전달

            map.put("limit", pageSize);

            map.put("offset", startIndex);

            // 회원 목록 조회

            List<Admin> list = adminMapper.selectAdminList(map);

            // =====================================
            // 4. 검색 조건에 맞는 전체 회원 수 조회
            // =====================================

            int count = adminMapper.selectAdminCount(map);

            // =====================================
            // 5. 전체 회원 통계 조회
            // =====================================

            Admin stats = adminMapper.selectStats(map);

            // =====================================
            // 6. 조회 결과 전달
            // =====================================

            resultMap.put("list", list);

            // 검색 조건에 맞는 회원 수
            resultMap.put("count", count);

            // 전체 회원 통계
            resultMap.put("stats", stats);

            resultMap.put("result", "success");

        } catch (Exception e) {

            resultMap.put("result", "fail");

            resultMap.put("message", e.getMessage());

            e.printStackTrace();

        }

        return resultMap;

    }

    // =====================================
    // 회원 상세정보 조회
    // =====================================
    public HashMap<String, Object> getAdminDetail(HashMap<String, Object> map) {

        // Controller에 전달할 결과를 담습니다.
        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            // 전달받은 memberId로 회원 한 명을 조회합니다.
            Admin info = adminMapper.selectAdminDetail(map);

            // 회원 정보가 없는 경우
            if (info == null) {

                resultMap.put("result", "fail");
                resultMap.put("message", "회원 정보를 찾을 수 없습니다.");

                return resultMap;
            }

            // 조회한 회원 정보를 userInfo라는 이름으로 전달합니다.
            resultMap.put("userInfo", info);

            // 조회 성공 표시
            resultMap.put("result", "success");

        } catch (Exception e) {

            // 오류 발생 시 실패 처리
            resultMap.put("result", "fail");

            // 오류 메시지 전달
            resultMap.put("message", e.getMessage());

            e.printStackTrace();
        }

        return resultMap;
    }

    // =====================================
    // 운영 정책 및 약관 관리
    // =====================================

    // 전체 정책 목록 조회
    public HashMap<String, Object> getPolicyList() {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            List<Policy> list = adminMapper.selectPolicyList();

            resultMap.put("list", list);
            resultMap.put("result", "success");

        } catch (Exception e) {

            resultMap.put("result", "fail");
            resultMap.put("message", e.getMessage());

            e.printStackTrace();
        }

        return resultMap;
    }

    // 정책 상세 조회
    public HashMap<String, Object> getPolicyDetail(HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            Policy info = adminMapper.selectPolicyDetail(map);

            if (info == null) {

                resultMap.put("result", "fail");
                resultMap.put("message", "정책 정보를 찾을 수 없습니다.");

                return resultMap;
            }

            resultMap.put("policyInfo", info);
            resultMap.put("result", "success");

        } catch (Exception e) {

            resultMap.put("result", "fail");
            resultMap.put("message", e.getMessage());

            e.printStackTrace();
        }

        return resultMap;
    }

    // 정책 수정
    public HashMap<String, Object> updatePolicy(Policy policy) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            int count = adminMapper.updatePolicy(policy);

            if (count > 0) {

                resultMap.put("result", "success");

            } else {

                resultMap.put("result", "fail");
                resultMap.put("message", "정책 수정에 실패했습니다.");

            }

        } catch (Exception e) {

            resultMap.put("result", "fail");
            resultMap.put("message", e.getMessage());

            e.printStackTrace();
        }

        return resultMap;
    }

    // =====================================
    // 고객센터 운영 시간 관리
    // =====================================

    // 요일별 운영 시간 전체 조회
    public HashMap<String, Object> getCustomerServiceHours() {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            List<HashMap<String, Object>> list = adminMapper.selectCustomerServiceHours();

            resultMap.put("list", list);
            resultMap.put("result", "success");

        } catch (Exception e) {

            resultMap.put("result", "fail");
            resultMap.put("message", e.getMessage());

            e.printStackTrace();
        }

        return resultMap;
    }

    // 요일별 운영 시간 저장 및 수정
    public HashMap<String, Object> saveCustomerServiceHours(
            HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {
            // 휴무일이면 시작 시간과 종료 시간은 NULL로 저장
            if ("Y".equals(map.get("isClosed"))) {
                map.put("startTime", null);
                map.put("endTime", null);
            } else {
                // 빈 값이면 NULL로 처리
                Object start = map.get("startTime");
                Object end = map.get("endTime");

                if (start == null || start.toString().trim().isEmpty()) {
                    map.put("startTime", null);
                }

                if (end == null || end.toString().trim().isEmpty()) {
                    map.put("endTime", null);
                }
            }

            int count = adminMapper.saveCustomerServiceHours(map);

            if (count > 0) {
                resultMap.put("result", "success");
            } else {
                resultMap.put("result", "fail");
                resultMap.put("message", "운영 시간 저장에 실패했습니다.");
            }

        } catch (Exception e) {
            resultMap.put("result", "fail");
            resultMap.put("message", e.getMessage());
            e.printStackTrace();
        }

        return resultMap;
    }

}
