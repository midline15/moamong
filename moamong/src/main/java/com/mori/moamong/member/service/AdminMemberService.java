
package com.mori.moamong.member.service;

import java.util.HashMap;
import java.util.List;
import java.util.Arrays;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mori.moamong.dto.Member;
import com.mori.moamong.member.mapper.AdminMemberMapper;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class AdminMemberService {

	private final AdminMemberMapper adminmemberMapper;

	// 회원 목록 조회
	public HashMap<String, Object> getAdminList(HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			int limit = 5;
			int offset = 0;

			if (map.get("limit") != null) {
				limit = Integer.parseInt(map.get("limit").toString());
			}

			if (map.get("offset") != null) {
				offset = Integer.parseInt(map.get("offset").toString());
			}

			map.put("limit", limit);
			map.put("offset", offset);

			List<Member> list = adminmemberMapper.selectAdminList(map);

			int count = adminmemberMapper.selectAdminCount(map);

			Member stats = adminmemberMapper.selectStats(map);

			resultMap.put("list", list);
			resultMap.put("count", count);
			resultMap.put("stats", stats);
			resultMap.put("result", "success");

		} catch (Exception e) {

			e.printStackTrace();

			resultMap.put("result", "fail");
			resultMap.put("message", "회원 목록 조회 중 오류가 발생했습니다.");

		}

		return resultMap;

	}

	// 회원 상세 정보 조회
	public HashMap<String, Object> getAdminDetail(HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			Member userInfo = adminmemberMapper.selectAdminDetail(map);

			if (userInfo == null) {

				resultMap.put("result", "fail");
				resultMap.put("message", "회원 정보를 찾을 수 없습니다.");

				return resultMap;

			}

			resultMap.put("userInfo", userInfo);
			resultMap.put("result", "success");

		} catch (Exception e) {

			e.printStackTrace();

			resultMap.put("result", "fail");
			resultMap.put("message", "회원 상세 조회 중 오류가 발생했습니다.");

		}

		return resultMap;

	}

	// 회원 등급 변경
	@Transactional(rollbackFor = Exception.class)
	public HashMap<String, Object> updateMemberGrade(HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			Long memberId = Long.parseLong(map.get("memberId").toString());
			String memberGrade = map.get("memberGrade").toString();
			String reason = map.get("reason").toString().trim();

			List<String> gradeList = Arrays.asList("BRONZE", "SILVER", "GOLD", "VIP");

			if (!gradeList.contains(memberGrade)) {

				resultMap.put("result", "fail");
				resultMap.put("message", "잘못된 회원 등급입니다.");

				return resultMap;

			}

			if (reason.isEmpty()) {

				resultMap.put("result", "fail");
				resultMap.put("message", "변경 사유를 입력하세요.");

				return resultMap;

			}

			Member userInfo = adminmemberMapper.selectAdminDetail(map);

			if (userInfo == null) {

				resultMap.put("result", "fail");
				resultMap.put("message", "회원 정보를 찾을 수 없습니다.");

				return resultMap;

			}

			if ("WITHDRAWN".equals(userInfo.getStatus())) {

				resultMap.put("result", "fail");
				resultMap.put("message", "탈퇴 회원의 등급은 변경할 수 없습니다.");

				return resultMap;

			}

			map.put("memberId", memberId);
			map.put("memberGrade", memberGrade);

			int updateCount = adminmemberMapper.updateMemberGrade(map);

			if (updateCount == 0) {

				resultMap.put("result", "fail");
				resultMap.put("message", "등급 변경에 실패했습니다.");

				return resultMap;

			}

			resultMap.put("result", "success");

		} catch (Exception e) {

			e.printStackTrace();

			resultMap.put("result", "fail");
			resultMap.put("message", "회원 등급 변경 중 오류가 발생했습니다.");

		}

		return resultMap;

	}

	// 회원 상태 변경
	@Transactional(rollbackFor = Exception.class)
	public HashMap<String, Object> updateMemberStatus(HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			Long memberId = Long.parseLong(map.get("memberId").toString());
			String status = map.get("status").toString();
			String reason = map.get("reason").toString().trim();

			List<String> statusList = Arrays.asList("ACTIVE", "SUSPENDED", "INACTIVE");

			if (!statusList.contains(status)) {

				resultMap.put("result", "fail");
				resultMap.put("message", "잘못된 회원 상태입니다.");

				return resultMap;

			}

			if (reason.isEmpty()) {

				resultMap.put("result", "fail");
				resultMap.put("message", "변경 사유를 입력하세요.");

				return resultMap;

			}

			Member userInfo = adminmemberMapper.selectAdminDetail(map);

			if (userInfo == null) {

				resultMap.put("result", "fail");
				resultMap.put("message", "회원 정보를 찾을 수 없습니다.");

				return resultMap;

			}

			if ("WITHDRAWN".equals(userInfo.getStatus())) {

				resultMap.put("result", "fail");
				resultMap.put("message", "탈퇴 회원의 상태는 변경할 수 없습니다.");

				return resultMap;

			}

			map.put("memberId", memberId);
			map.put("status", status);

			int updateCount = adminmemberMapper.updateMemberStatus(map);

			if (updateCount == 0) {

				resultMap.put("result", "fail");
				resultMap.put("message", "상태 변경에 실패했습니다.");

				return resultMap;

			}

			resultMap.put("result", "success");

		} catch (Exception e) {

			e.printStackTrace();

			resultMap.put("result", "fail");
			resultMap.put("message", "회원 상태 변경 중 오류가 발생했습니다.");

		}

		return resultMap;

	}

	// 회원 강제 탈퇴
	@Transactional(rollbackFor = Exception.class)
	public HashMap<String, Object> withdrawMember(HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			Long memberId = Long.parseLong(map.get("memberId").toString());
			String reason = map.get("reason").toString().trim();

			if (reason.isEmpty()) {

				resultMap.put("result", "fail");
				resultMap.put("message", "탈퇴 사유를 입력하세요.");

				return resultMap;

			}

			Member userInfo = adminmemberMapper.selectAdminDetail(map);

			if (userInfo == null) {

				resultMap.put("result", "fail");
				resultMap.put("message", "회원 정보를 찾을 수 없습니다.");

				return resultMap;

			}

			if ("WITHDRAWN".equals(userInfo.getStatus())) {

				resultMap.put("result", "fail");
				resultMap.put("message", "이미 탈퇴 처리된 회원입니다.");

				return resultMap;

			}

			map.put("memberId", memberId);

			int updateCount = adminmemberMapper.withdrawMember(map);

			if (updateCount == 0) {

				resultMap.put("result", "fail");
				resultMap.put("message", "회원 탈퇴 처리에 실패했습니다.");

				return resultMap;

			}

			resultMap.put("result", "success");

		} catch (Exception e) {

			e.printStackTrace();

			resultMap.put("result", "fail");
			resultMap.put("message", "회원 탈퇴 처리 중 오류가 발생했습니다.");

		}

		return resultMap;

	}

}
