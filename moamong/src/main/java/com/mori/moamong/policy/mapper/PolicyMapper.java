package com.mori.moamong.policy.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Policy;

@Mapper
public interface PolicyMapper {

	// =====================================
	// 운영 정책 및 약관 관리
	// =====================================

	// 전체 정책 목록 조회
	List<Policy> selectPolicyList();

	// 정책 상세 조회
	Policy selectPolicyDetail(HashMap<String, Object> map);

	// 정책 내용 수정
	int updatePolicy(Policy policy);

	// =====================================
	// 고객센터 운영 시간 관리
	// =====================================

	// 요일별 운영 시간 전체 조회
	List<HashMap<String, Object>> selectCustomerServiceHours();

	// 요일별 운영 시간 저장 및 수정
	int saveCustomerServiceHours(HashMap<String, Object> map);
}
