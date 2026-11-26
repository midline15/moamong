package com.mori.moamong.policy.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mori.moamong.dto.Policy;
import com.mori.moamong.policy.mapper.PolicyMapper;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class PolicyService {
	private final PolicyMapper policyMapper;
	// =====================================
	// 운영 정책 및 약관 관리
	// =====================================

	// 전체 정책 목록 조회
	public HashMap<String, Object> getPolicyList() {

		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			List<Policy> list = policyMapper.selectPolicyList();

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

			Policy info = policyMapper.selectPolicyDetail(map);

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

			int count = policyMapper.updatePolicy(policy);

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

			List<HashMap<String, Object>> list = policyMapper.selectCustomerServiceHours();

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
	public HashMap<String, Object> saveCustomerServiceHours(HashMap<String, Object> map) {

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

			int count = policyMapper.saveCustomerServiceHours(map);

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
