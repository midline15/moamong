package com.mori.moamong.policy.controller;

import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;


import com.google.gson.Gson;
import com.mori.moamong.dto.Policy;
import com.mori.moamong.policy.service.PolicyService;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class PolicyController {
	private final PolicyService policyService;
	

	// =====================================
	// 운영 정책 전체 목록 조회
	// =====================================

	@RequestMapping(value = "/policy/policyList.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String policyList() throws Exception {

		HashMap<String, Object> resultMap = policyService.getPolicyList();

		return new Gson().toJson(resultMap);
	}

	// =====================================
	// 운영 정책 상세 조회
	// =====================================

	@RequestMapping(value = "/policy/policyDetail.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String policyDetail(@RequestParam HashMap<String, Object> map) throws Exception {

		HashMap<String, Object> resultMap = policyService.getPolicyDetail(map);

		return new Gson().toJson(resultMap);
	}

	// =====================================
	// 운영 정책 수정
	// =====================================

	@RequestMapping(value = "/policy/policyUpdate.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String policyUpdate(@RequestParam HashMap<String, Object> map) throws Exception {

		Policy policy = new Policy();

		policy.setPolicyId(Long.parseLong(String.valueOf(map.get("policyId"))));
		policy.setTitle(String.valueOf(map.get("title")));
		policy.setContent(String.valueOf(map.get("content")));
		policy.setIsRequired(String.valueOf(map.get("isRequired")));
		policy.setIsActive(String.valueOf(map.get("isActive")));

		HashMap<String, Object> resultMap = policyService.updatePolicy(policy);

		return new Gson().toJson(resultMap);
	}

	// =====================================
	// 고객센터 운영 시간 전체 조회
	// =====================================

	@RequestMapping(value = "/policy/customerServiceHoursList.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String customerServiceHoursList() throws Exception {

		HashMap<String, Object> resultMap = policyService.getCustomerServiceHours();

		return new Gson().toJson(resultMap);
	}

	// =====================================
	// 고객센터 운영 시간 저장 및 수정
	// =====================================

	@RequestMapping(value = "/policy/customerServiceHoursSave.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String customerServiceHoursSave(@RequestParam HashMap<String, Object> map) throws Exception {

		HashMap<String, Object> resultMap = policyService.saveCustomerServiceHours(map);

		return new Gson().toJson(resultMap);
	}

}
