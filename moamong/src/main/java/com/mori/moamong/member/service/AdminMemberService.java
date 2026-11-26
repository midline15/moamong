
package com.mori.moamong.member.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mori.moamong.dto.Member;
import com.mori.moamong.member.mapper.AdminMemberMapper;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class AdminMemberService {

	private final AdminMemberMapper adminmemberMapper;

	// =====================================
	// 회원 목록 조회
	// =====================================
	public HashMap<String, Object> getAdminList(HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			// JSP에서 전달한 페이지당 회원 수 가져오기
			String limit = String.valueOf(map.get("limit"));

			// JSP에서 전달한 시작 위치 가져오기
			String offset = String.valueOf(map.get("offset"));

			// 기본 페이지 크기
			int pageSize = 5;

			if (!limit.equals("null") && limit.matches("\\d+")) {
				pageSize = Integer.parseInt(limit);
			}

			// 기본 시작 위치
			int startIndex = 0;

			if (!offset.equals("null") && offset.matches("\\d+")) {
				startIndex = Integer.parseInt(offset);
			}

			// 페이지 정보 설정
			map.put("limit", pageSize);
			map.put("offset", startIndex);

			// 회원 목록 조회
			List<Member> list = adminmemberMapper.selectAdminList(map);

			// 검색 조건에 맞는 전체 회원 수 조회
			int count = adminmemberMapper.selectAdminCount(map);

			// 전체 회원 통계 조회
			Member stats = adminmemberMapper.selectStats(map);

			// 조회 결과 전달
			resultMap.put("list", list);
			resultMap.put("count", count);
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

		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			// 회원 정보 조회
			Member info = adminmemberMapper.selectAdminDetail(map);

			// 회원 정보가 없는 경우
			if (info == null) {

				resultMap.put("result", "fail");
				resultMap.put("message", "회원 정보를 찾을 수 없습니다.");

				return resultMap;
			}

			// 조회한 회원 정보 전달
			resultMap.put("userInfo", info);

			resultMap.put("result", "success");

		} catch (Exception e) {

			resultMap.put("result", "fail");
			resultMap.put("message", e.getMessage());

			e.printStackTrace();
		}

		return resultMap;
	}

}
