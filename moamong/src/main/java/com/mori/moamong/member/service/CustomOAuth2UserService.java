package com.mori.moamong.member.service;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import com.mori.moamong.dto.Member;
import com.mori.moamong.member.mapper.MemberMapper;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

	private final MemberMapper memberMapper;
	private final HttpSession session;

	@Override
	@SuppressWarnings("unchecked")
	public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
		OAuth2User oAuth2User = super.loadUser(userRequest);

		// 1. 소셜 플랫폼 구분 (KAKAO, NAVER, GOOGLE)
		String registrationId = userRequest.getClientRegistration().getRegistrationId().toUpperCase();
		Map<String, Object> attributes = oAuth2User.getAttributes();

		String socialUserId = "";
		String memberName = "";
		String email = "";

		if ("KAKAO".equals(registrationId)) {
			socialUserId = String.valueOf(attributes.get("id"));
			Map<String, Object> kakaoAccount = (Map<String, Object>) attributes.get("kakao_account");
			if (kakaoAccount != null) {
				email = (String) kakaoAccount.get("email");
				Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");
				if (profile != null) {
					memberName = (String) profile.get("nickname");
				}
			}
		} else if ("NAVER".equals(registrationId)) {
			Map<String, Object> response = (Map<String, Object>) attributes.get("response");
			if (response != null) {
				socialUserId = String.valueOf(response.get("id"));
				memberName = (String) response.get("name");
				email = (String) response.get("email");
			}
		} else if ("GOOGLE".equals(registrationId)) {
			socialUserId = String.valueOf(attributes.get("sub"));
			memberName = (String) attributes.get("name");
			email = (String) attributes.get("email");
		}

		// 이메일 미제공 시 UNIQUE 제약조건 회피용 대체 이메일 생성 (@ 앞뒤 오타 수정)
		if (email == null || email.isEmpty()) {
			email = registrationId.toLowerCase() + "_" + socialUserId + "@moamong.com";
		}
		if (memberName == null || memberName.isEmpty()) {
			memberName = registrationId + "회원";
		}

		// 2. DB에서 소셜 회원 조회 -> 없으면 자동 회원가입
		HashMap<String, Object> param = new HashMap<>();
		param.put("socialType", registrationId);
		param.put("socialUserId", socialUserId);

		Member member = memberMapper.selectMemberBySocial(param);
		if (member == null) {
			param.put("memberName", memberName);
			param.put("email", email);
			memberMapper.insertSocialMember(param);
			member = memberMapper.selectMemberBySocial(param);
		} else {
			// 2-1. 기존 소셜 계정이 탈퇴(WITHDRAWN) 또는 정지(SUSPENDED) 상태면 로그인 차단
			if ("WITHDRAWN".equals(member.getStatus())) {
				throw new OAuth2AuthenticationException(new OAuth2Error("withdrawn_member"), "탈퇴 처리된 계정입니다.");
			}
			if ("SUSPENDED".equals(member.getStatus())) {
				throw new OAuth2AuthenticationException(new OAuth2Error("suspended_member"), "이용이 정지된 계정입니다.");
			}
		}

		// 3. 기존 일반 로그인과 100% 동일한 세션 저장
		session.setAttribute("sessionId", member.getMemberId());
		session.setAttribute("sessionName", member.getMemberName());
		session.setAttribute("sessionRole", member.getRole());
		session.setAttribute("sessionStatus", member.getStatus());
		session.setAttribute("sessionCreatedAt", member.getCreatedAt());

		String userNameAttributeName = userRequest.getClientRegistration().getProviderDetails().getUserInfoEndpoint()
				.getUserNameAttributeName();

		return new DefaultOAuth2User(Collections.singleton(new SimpleGrantedAuthority("ROLE_" + member.getRole())),
				attributes, userNameAttributeName);
	}
}
