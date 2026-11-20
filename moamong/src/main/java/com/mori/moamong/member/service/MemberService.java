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

	// 멤버 조회
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
				// 계정 상태 체크 (ACTIVE만 로그인 허용)
				if ("SUSPENDED".equals(member.getStatus())) {
					resultMap.put("loginFlg", false);
					resultMap.put("message", "관리자에 의해 정지된 계정입니다.");
					resultMap.put("result", "fail");
					return resultMap;
				}
				if ("WITHDRAWN".equals(member.getStatus())) {
					resultMap.put("loginFlg", false);
					resultMap.put("message", "탈퇴 처리된 계정입니다.");
					resultMap.put("result", "fail");
					return resultMap;
				}

				boolean login = passwordEncoder.matches((String) map.get("pwd"), member.getPassword());
				if (login) {
					session.setAttribute("sessionId", member.getMemberId());
					session.setAttribute("sessionName", member.getMemberName());
					session.setAttribute("sessionRole", member.getRole());
					session.setAttribute("sessionStatus", member.getStatus());
					session.setAttribute("sessionCreatedAt", member.getCreatedAt());

					resultMap.put("loginFlg", true);
					resultMap.put("message", member.getMemberName() + "님 환영합니다.");
				} else {
					resultMap.put("loginFlg", false);
					resultMap.put("message", "비밀번호가 일치하지 않습니다.");
				}
			} else {
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

	// 아이디 중복 확인
	public HashMap<String, Object> idDuplicateCheck(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			String loginId = (String) map.get("loginId");
			if (loginId == null || loginId.trim().isEmpty()) {
				resultMap.put("result", "fail");
				resultMap.put("message", "아이디를 입력해주세요.");
				return resultMap;
			}

			int count = memberMapper.idDuplicateCheck(map);
			if (count > 0) {
				resultMap.put("isDuplicate", true);
				resultMap.put("message", "이미 사용 중인 아이디입니다.");
			} else {
				resultMap.put("isDuplicate", false);
				resultMap.put("message", "사용 가능한 아이디입니다.");
			}
			resultMap.put("result", "success");
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "중복 확인 중 오류가 발생했습니다.");
			System.out.println(e.getMessage());
		}
		return resultMap;
	}

	// 회원가입 처리
	public HashMap<String, Object> join(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			String loginId = (String) map.get("loginId");
			String password = (String) map.get("password");
			String memberName = (String) map.get("memberName");
			String email = (String) map.get("email");
			String phone = (String) map.get("phone");

			// 1. 필수 값 검증 (NOT NULL 컬럼)
			if (loginId == null || loginId.trim().isEmpty()) {
				resultMap.put("result", "fail");
				resultMap.put("message", "아이디는 필수 입력 항목입니다.");
				return resultMap;
			}
			if (password == null || password.trim().isEmpty()) {
				resultMap.put("result", "fail");
				resultMap.put("message", "비밀번호는 필수 입력 항목입니다.");
				return resultMap;
			}
			if (memberName == null || memberName.trim().isEmpty()) {
				resultMap.put("result", "fail");
				resultMap.put("message", "이름은 필수 입력 항목입니다.");
				return resultMap;
			}
			if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
				resultMap.put("result", "fail");
				resultMap.put("message", "올바른 이메일 형식을 입력해주세요.");
				return resultMap;
			}

			// 2. 선택 값(휴대폰 번호) 입력 시 형식 및 중복 검증
			if (phone != null && !phone.trim().isEmpty()) {
				if (!phone.matches("^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$")) {
					resultMap.put("result", "fail");
					resultMap.put("message", "올바른 휴대폰 번호 형식(010-0000-0000)을 입력해주세요.");
					return resultMap;
				}
				if (memberMapper.phoneDuplicateCheck(map) > 0) {
					resultMap.put("result", "fail");
					resultMap.put("message", "이미 등록된 휴대폰 번호입니다.");
					return resultMap;
				}
			}

			// 3. 필수 UNIQUE 컬럼 중복 재검증
			if (memberMapper.idDuplicateCheck(map) > 0) {
				resultMap.put("result", "fail");
				resultMap.put("message", "이미 사용 중인 아이디입니다.");
				return resultMap;
			}
			if (memberMapper.emailDuplicateCheck(map) > 0) {
				resultMap.put("result", "fail");
				resultMap.put("message", "이미 가입된 이메일입니다.");
				return resultMap;
			}

			// 4. 비밀번호 해싱 후 저장
			map.put("password", passwordEncoder.encode(password));
			int res = memberMapper.insertMember(map);

			if (res > 0) {
				resultMap.put("result", "success");
				resultMap.put("message", "회원가입이 완료되었습니다.");
			} else {
				resultMap.put("result", "fail");
				resultMap.put("message", "회원가입에 실패했습니다.");
			}
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "회원가입 처리 중 오류가 발생했습니다.");
			System.out.println(e.getMessage());
		}
		return resultMap;
	}

	// 마이페이지 내 정보 조회
	public HashMap<String, Object> getMyInfo(Long memberId) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			Member member = memberMapper.selectMemberById(memberId);
			if (member != null) {
				member.setPassword(null); // 보안상 암호화된 비밀번호도 프론트로 내보내지 않음
				resultMap.put("member", member);
				resultMap.put("result", "success");
			} else {
				resultMap.put("result", "fail");
				resultMap.put("message", "회원 정보를 찾을 수 없습니다.");
			}
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "조회 중 오류가 발생했습니다.");
			System.out.println(e.getMessage());
		}
		return resultMap;
	}

	// 내 정보 수정 (이름, 이메일, 휴대폰 번호)
	public HashMap<String, Object> updateMemberInfo(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			Long memberId = Long.valueOf(String.valueOf(map.get("memberId")));
			Member current = memberMapper.selectMemberById(memberId);

			String memberName = (String) map.get("memberName");
			String email = (String) map.get("email");
			String phone = (String) map.get("phone");

			if (memberName == null || memberName.trim().isEmpty()) {
				resultMap.put("result", "fail");
				resultMap.put("message", "이름을 입력해주세요.");
				return resultMap;
			}
			if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
				resultMap.put("result", "fail");
				resultMap.put("message", "올바른 이메일 형식을 입력해주세요.");
				return resultMap;
			}
			// 이메일이 변경된 경우에만 중복 검사
			if (!email.trim().equals(current.getEmail()) && memberMapper.emailDuplicateCheck(map) > 0) {
				resultMap.put("result", "fail");
				resultMap.put("message", "이미 사용 중인 이메일입니다.");
				return resultMap;
			}
			// 휴대폰 번호 입력 시 형식 및 변경된 경우 중복 검사
			if (phone != null && !phone.trim().isEmpty()) {
				if (!phone.matches("^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$")) {
					resultMap.put("result", "fail");
					resultMap.put("message", "올바른 휴대폰 번호 형식(010-0000-0000)을 입력해주세요.");
					return resultMap;
				}
				if (!phone.trim().equals(current.getPhone()) && memberMapper.phoneDuplicateCheck(map) > 0) {
					resultMap.put("result", "fail");
					resultMap.put("message", "이미 등록된 휴대폰 번호입니다.");
					return resultMap;
				}
			}

			int res = memberMapper.updateMemberInfo(map);
			if (res > 0) {
				session.setAttribute("sessionName", memberName.trim()); // 세션 이름도 최신화
				resultMap.put("result", "success");
				resultMap.put("message", "회원정보가 수정되었습니다.");
			} else {
				resultMap.put("result", "fail");
				resultMap.put("message", "수정에 실패했습니다.");
			}
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "수정 처리 중 오류가 발생했습니다.");
			System.out.println(e.getMessage());
		}
		return resultMap;
	}

	// 비밀번호 변경
	public HashMap<String, Object> changePassword(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			Long memberId = Long.valueOf(String.valueOf(map.get("memberId")));
			String currentPwd = (String) map.get("currentPwd");
			String newPwd = (String) map.get("newPwd");

			Member current = memberMapper.selectMemberById(memberId);
			if (current.getSocialType() != null || current.getPassword() == null) {
				resultMap.put("result", "fail");
				resultMap.put("message", "소셜 로그인 계정은 비밀번호를 변경할 수 없습니다.");
				return resultMap;
			}
			if (!passwordEncoder.matches(currentPwd, current.getPassword())) {
				resultMap.put("result", "fail");
				resultMap.put("message", "현재 비밀번호가 일치하지 않습니다.");
				return resultMap;
			}

			map.put("newPassword", passwordEncoder.encode(newPwd));
			int res = memberMapper.updatePassword(map);
			if (res > 0) {
				resultMap.put("result", "success");
				resultMap.put("message", "비밀번호가 변경되었습니다.");
			} else {
				resultMap.put("result", "fail");
				resultMap.put("message", "비밀번호 변경에 실패했습니다.");
			}
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "비밀번호 변경 중 오류가 발생했습니다.");
			System.out.println(e.getMessage());
		}
		return resultMap;
	}

	// 회원 탈퇴 (일반 회원: 비밀번호 검증 / 소셜 회원: 비밀번호 없이 즉시 탈퇴 허용)
	public HashMap<String, Object> withdraw(Long memberId, String password) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			Member current = memberMapper.selectMemberById(memberId);
			if (current == null) {
				resultMap.put("result", "fail");
				resultMap.put("message", "회원 정보를 찾을 수 없습니다.");
				return resultMap;
			}

			// 일반 회원만 비밀번호 검증 (소셜 회원은 password가 null이므로 패스)
			if (current.getSocialType() == null && current.getPassword() != null) {
				if (password == null || !passwordEncoder.matches(password, current.getPassword())) {
					resultMap.put("result", "fail");
					resultMap.put("message", "비밀번호가 일치하지 않습니다.");
					return resultMap;
				}
			}

			int res = memberMapper.withdrawMember(memberId);
			if (res > 0) {
				session.invalidate(); // 탈퇴 즉시 로그아웃 처리
				resultMap.put("result", "success");
				resultMap.put("message", "회원 탈퇴가 완료되었습니다.");
			} else {
				resultMap.put("result", "fail");
				resultMap.put("message", "회원 탈퇴에 실패했습니다.");
			}
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "탈퇴 처리 중 오류가 발생했습니다.");
			System.out.println(e.getMessage());
		}
		return resultMap;
	}

}
