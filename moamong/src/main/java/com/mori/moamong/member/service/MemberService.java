package com.mori.moamong.member.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
					// 휴면 계정(INACTIVE)인 경우 세션 보류 후 휴면 해제 안내 플래그 반환
					if ("INACTIVE".equals(member.getStatus())) {
						resultMap.put("loginFlg", false);
						resultMap.put("isInactive", true);
						resultMap.put("loginId", member.getLoginId());
						resultMap.put("message", "30일 이상 미접속으로 휴면 전환된 계정입니다. 비밀번호 인증 후 해제해주세요.");
						resultMap.put("result", "success");
						return resultMap;
					}

					// [추가] 정상 로그인 시 최종 로그인 일시 갱신
					memberMapper.updateLastLoginAt(member.getMemberId());

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

	// 회원가입용 활성 약관 목록 조회 (POLICY 테이블 연동)
	public HashMap<String, Object> getJoinPolicies() {
		HashMap<String, Object> resultMap = new HashMap<>();
		resultMap.put("result", "success");
		resultMap.put("list", memberMapper.selectJoinPolicies());
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
			String phone = String.valueOf(map.getOrDefault("phone", "")).trim();
			
			if (phone.isEmpty()) {
				resultMap.put("result", "fail");
				resultMap.put("message", "휴대폰 본인인증을 완료해주세요.");
				return resultMap;
			}

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

	// 마이페이지 내 정보 진입 전 비밀번호 재확인
	public HashMap<String, Object> verifyPassword(Long memberId, String password) {
	    HashMap<String, Object> resultMap = new HashMap<>();
	    if (password == null || password.trim().isEmpty()) {
	        resultMap.put("result", "fail");
	        resultMap.put("message", "비밀번호를 입력해주세요.");
	        return resultMap;
	    }
	    Member member = memberMapper.selectMemberById(memberId);
	    if (member == null || !passwordEncoder.matches(password, member.getPassword())) {
	        resultMap.put("result", "fail");
	        resultMap.put("message", "비밀번호가 일치하지 않습니다.");
	        return resultMap;
	    }
	    resultMap.put("result", "success");
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
		String currentPwd = String.valueOf(map.getOrDefault("currentPwd", ""));
		String newPwd = String.valueOf(map.getOrDefault("newPwd", ""));

		if (newPwd.trim().isEmpty()) {
			resultMap.put("result", "fail");
			resultMap.put("message", "새 비밀번호를 입력해주세요.");
			return resultMap;
		}
		if (currentPwd.equals(newPwd)) {
			resultMap.put("result", "fail");
			resultMap.put("message", "현재 비밀번호와 다른 새 비밀번호를 입력해주세요.");
			return resultMap;
		}
		
		try {
			Long memberId = Long.valueOf(String.valueOf(map.get("memberId")));

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

	// 아이디 찾기 (이름 + 이메일)
	public HashMap<String, Object> findLoginId(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			String memberName = (String) map.get("memberName");
			String email = (String) map.get("email");

			if (memberName == null || memberName.trim().isEmpty()) {
				resultMap.put("result", "fail");
				resultMap.put("message", "이름을 입력해주세요.");
				return resultMap;
			}
			if (email == null || email.trim().isEmpty()) {
				resultMap.put("result", "fail");
				resultMap.put("message", "이메일을 입력해주세요.");
				return resultMap;
			}

			Member member = memberMapper.selectMemberByNameAndEmail(map);
			if (member == null) {
				resultMap.put("result", "fail");
				resultMap.put("message", "일치하는 회원 정보를 찾을 수 없습니다.");
				return resultMap;
			}

			if ("SUSPENDED".equals(member.getStatus())) {
				resultMap.put("result", "fail");
				resultMap.put("message", "정지된 계정입니다. 관리자에게 문의해주세요.");
				return resultMap;
			}

			// 소셜 가입 회원인 경우 안내
			if (member.getSocialType() != null && !member.getSocialType().isEmpty()) {
				resultMap.put("result", "success");
				resultMap.put("isSocial", true);
				resultMap.put("socialType", member.getSocialType());
				resultMap.put("message", member.getSocialType() + " 소셜 로그인으로 가입된 계정입니다.");
				return resultMap;
			}

			resultMap.put("result", "success");
			resultMap.put("isSocial", false);
			resultMap.put("loginId", member.getLoginId());
			resultMap.put("createdAt", String.valueOf(member.getCreatedAt()));
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "아이디 찾기 중 오류가 발생했습니다.");
			System.out.println(e.getMessage());
		}
		return resultMap;
	}

	// 비밀번호 재설정 전 본인 확인 (아이디 + 이름 + 이메일)
	public HashMap<String, Object> verifyMemberForReset(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			String loginId = (String) map.get("loginId");
			String memberName = (String) map.get("memberName");
			String email = (String) map.get("email");

			if (loginId == null || loginId.trim().isEmpty() || memberName == null || memberName.trim().isEmpty()
					|| email == null || email.trim().isEmpty()) {
				resultMap.put("result", "fail");
				resultMap.put("message", "아이디, 이름, 이메일을 모두 입력해주세요.");
				return resultMap;
			}

			Member member = memberMapper.selectMemberForPasswordReset(map);
			if (member == null) {
				resultMap.put("result", "fail");
				resultMap.put("message", "입력하신 정보와 일치하는 회원이 없습니다.");
				return resultMap;
			}
			if (member.getSocialType() != null && !member.getSocialType().isEmpty()) {
				resultMap.put("result", "fail");
				resultMap.put("message", member.getSocialType() + " 소셜 로그인 계정은 비밀번호를 재설정할 수 없습니다.");
				return resultMap;
			}
			if ("SUSPENDED".equals(member.getStatus())) {
				resultMap.put("result", "fail");
				resultMap.put("message", "정지된 계정입니다. 관리자에게 문의해주세요.");
				return resultMap;
			}

			resultMap.put("result", "success");
			resultMap.put("memberId", member.getMemberId());
			resultMap.put("message", "본인 확인이 완료되었습니다. 새 비밀번호를 입력해주세요.");
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "본인 확인 중 오류가 발생했습니다.");
			System.out.println(e.getMessage());
		}
		return resultMap;
	}

	// 새 비밀번호 재설정 반영
	public HashMap<String, Object> resetPassword(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			String newPwd = (String) map.get("newPwd");
			if (newPwd == null || newPwd.trim().length() < 4) {
				resultMap.put("result", "fail");
				resultMap.put("message", "새 비밀번호는 4자 이상 입력해주세요.");
				return resultMap;
			}

			// 재검증 (직접 API 호출 악용 방지)
			Member member = memberMapper.selectMemberForPasswordReset(map);
			if (member == null || member.getSocialType() != null) {
				resultMap.put("result", "fail");
				resultMap.put("message", "유효하지 않은 요청입니다.");
				return resultMap;
			}

			map.put("memberId", member.getMemberId());
			map.put("newPassword", passwordEncoder.encode(newPwd.trim()));
			int res = memberMapper.updatePassword(map);

			if (res > 0) {
				resultMap.put("result", "success");
				resultMap.put("message", "비밀번호가 성공적으로 재설정되었습니다. 새 비밀번호로 로그인해주세요.");
			} else {
				resultMap.put("result", "fail");
				resultMap.put("message", "비밀번호 재설정에 실패했습니다.");
			}
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "비밀번호 재설정 중 오류가 발생했습니다.");
			System.out.println(e.getMessage());
		}
		return resultMap;
	}

	// [추가] 휴면 계정 해제 (비밀번호 재인증 후 ACTIVE 전환 + 자동 로그인)
	public HashMap<String, Object> activateDormant(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			String loginId = (String) map.get("memberId");
			String pwd = (String) map.get("pwd");

			Member member = memberMapper.selectMember(map);
			if (member == null || !"INACTIVE".equals(member.getStatus())) {
				resultMap.put("result", "fail");
				resultMap.put("message", "휴면 상태의 계정이 아닙니다.");
				return resultMap;
			}
			if (pwd == null || !passwordEncoder.matches(pwd, member.getPassword())) {
				resultMap.put("result", "fail");
				resultMap.put("message", "비밀번호가 일치하지 않습니다.");
				return resultMap;
			}

			if (memberMapper.activateDormantMember(member.getMemberId()) > 0) {
				session.setAttribute("sessionId", member.getMemberId());
				session.setAttribute("sessionName", member.getMemberName());
				session.setAttribute("sessionRole", member.getRole());
				session.setAttribute("sessionStatus", "ACTIVE");
				session.setAttribute("sessionCreatedAt", member.getCreatedAt());

				resultMap.put("result", "success");
				resultMap.put("message", "휴면 계정이 해제되었습니다. " + member.getMemberName() + "님 환영합니다!");
			} else {
				resultMap.put("result", "fail");
				resultMap.put("message", "휴면 해제 처리에 실패했습니다.");
			}
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "휴면 해제 중 오류가 발생했습니다.");
		}
		return resultMap;
	}

	// [수정] 소셜 휴면 계정 해제 (OAuth 인증 완료 상태이므로 버튼 클릭 시 즉시 해제)
	public HashMap<String, Object> activateSocialDormant() {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			Object dormantIdObj = session.getAttribute("dormantSocialMemberId");
			if (dormantIdObj == null) {
				resultMap.put("result", "fail");
				resultMap.put("message", "휴면 인증 세션이 만료되었습니다. 소셜 로그인을 다시 시도해주세요.");
				return resultMap;
			}
			Long memberId = Long.valueOf(String.valueOf(dormantIdObj));
			Member member = memberMapper.selectMemberById(memberId);

			if (member == null || !"INACTIVE".equals(member.getStatus())) {
				resultMap.put("result", "fail");
				resultMap.put("message", "휴면 상태의 계정이 아닙니다.");
				return resultMap;
			}

			if (memberMapper.activateDormantMember(memberId) > 0) {
				session.removeAttribute("dormantSocialMemberId");
				session.setAttribute("sessionId", member.getMemberId());
				session.setAttribute("sessionName", member.getMemberName());
				session.setAttribute("sessionRole", member.getRole());
				session.setAttribute("sessionStatus", "ACTIVE");
				session.setAttribute("sessionCreatedAt", member.getCreatedAt());

				resultMap.put("result", "success");
				resultMap.put("message", "휴면 계정이 해제되었습니다. " + member.getMemberName() + "님 환영합니다!");
			}
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "휴면 해제 처리 중 오류가 발생했습니다.");
		}
		return resultMap;
	}
	
	// 소셜 회원 본인인증 전화번호 저장
		public HashMap<String, Object> updateSocialPhone(Long memberId, String phone) {
			HashMap<String, Object> res = new HashMap<>();
			if (phone == null || phone.trim().isEmpty()) {
				res.put("result", "fail");
				res.put("message", "휴대폰 본인인증을 완료해주세요.");
				return res;
			}
			memberMapper.updateMemberPhone(memberId, phone.trim());
			res.put("result", "success");
			res.put("message", "휴대폰 번호 인증이 완료되었습니다.");
			return res;
		}
		// 마이페이지 - 내 작성글 목록 조회
		public HashMap<String, Object> getMyPosts(Long memberId) {
			HashMap<String, Object> res = new HashMap<>();
			res.put("result", "success");
			res.put("list", memberMapper.selectMyCommunityPosts(memberId));
			return res;
		}

		// 마이페이지 - 내 작성글 삭제
		@Transactional
		public HashMap<String, Object> removeMyPost(Long memberId, Long postId) {
			HashMap<String, Object> res = new HashMap<>();
			int cnt = memberMapper.deleteMyCommunityPost(memberId, postId);
			res.put("result", cnt > 0 ? "success" : "fail");
			res.put("message", cnt > 0 ? "작성글이 삭제되었습니다." : "삭제할 수 없는 게시글입니다.");
			return res;
		}

		// 마이페이지 - 내 댓글 목록 조회
		public HashMap<String, Object> getMyComments(Long memberId) {
			HashMap<String, Object> res = new HashMap<>();
			res.put("result", "success");
			res.put("list", memberMapper.selectMyCommunityComments(memberId));
			return res;
		}

		// 마이페이지 - 내 댓글 삭제
		@Transactional
		public HashMap<String, Object> removeMyComment(Long memberId, Long commentId) {
			HashMap<String, Object> res = new HashMap<>();
			int cnt = memberMapper.deleteMyCommunityComment(memberId, commentId);
			res.put("result", cnt > 0 ? "success" : "fail");
			res.put("message", cnt > 0 ? "댓글이 삭제되었습니다." : "삭제할 수 없는 댓글입니다.");
			return res;
		}

}
