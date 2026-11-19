package com.mori.moamong.member.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.mori.moamong.dto.Member;
import com.mori.moamong.member.mapper.MemberMapper;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MemberService {
	private final MemberMapper memberMapper;
	private final HttpSession session;
	private final PasswordEncoder passwordEncoder;

	public List<Map<String, Object>> findAll() {
		return memberMapper.findAll();
	}

	// 멤버조회
	public HashMap<String, Object> login(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap();

		// 빈 값 검증
		String memberId = (String) map.get("memberId");
		String pwd = (String) map.get("pwd");

		if (memberId == null || memberId.trim().isEmpty()) {
			resultMap.put("loginFlg", false);
			resultMap.put("message", "아이디를 입력해주세요.");
			resultMap.put("result", "fail");
			return resultMap;
		}
		if (pwd == null || pwd.trim().isEmpty()) {
			resultMap.put("loginFlg", false);
			resultMap.put("message", "비밀번호를 입력해주세요.");
			resultMap.put("result", "fail");
			return resultMap;
		}

		try {
			Member member = memberMapper.selectMember(map);
			if (member != null) {
				// 아이디는 검색 성공
				boolean login = passwordEncoder.matches((String) map.get("pwd"), member.getPassword());

				if (login) {
					session.setAttribute("sessionId", member.getMemberId());
					session.setAttribute("sessionName", member.getMemberName());
					session.setAttribute("sessionRole", member.getRole());

//					session.setMaxInactiveInterval(0); 유지시간
//					session.invalidate(); 세션 모든 정보 삭제

					resultMap.put("loginFlg", true);
					resultMap.put("message", member.getMemberName() + "님 환영합니다.");
				} else {
					resultMap.put("loginFlg", false);
					resultMap.put("message", "비밀번호가 일치하지 않습니다.");
				}

			} else {
				// 아이디가 없는 경우
				resultMap.put("loginFlg", false);
				resultMap.put("message", "아이디가 존재하지 않습니다.");
			}
			resultMap.put("result", "success");
		} catch (Exception e) {
			// TODO: handle exception
			resultMap.put("result", "fail");
			resultMap.put("message", "오류발생!");
			System.out.println(e.getMessage());
		}

		return resultMap;
	}

}
