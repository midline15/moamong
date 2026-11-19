package com.mori.moamong.common;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.firewall.HttpFirewall;
import org.springframework.security.web.firewall.StrictHttpFirewall;

import com.mori.moamong.member.service.CustomOAuth2UserService;

import lombok.RequiredArgsConstructor;

@Configuration
@RequiredArgsConstructor // 👈 1. 생성자 자동 주입 어노테이션 추가
public class SecurityConfig {

	// 👈 2. 소셜 로그인 처리 서비스 주입
	private final CustomOAuth2UserService customOAuth2UserService;

	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder(); // 비밀번호 해싱 기능만 사용
	}

	// ✅ 핵심: firewall 설정 추가
	@Bean
	public HttpFirewall allowDoubleSlashFirewall() {
		StrictHttpFirewall firewall = new StrictHttpFirewall();
		firewall.setAllowUrlEncodedDoubleSlash(true);
		firewall.setAllowSemicolon(true);
		return firewall;
	}

	// ✅ firewall 적용
	@Bean
	public WebSecurityCustomizer webSecurityCustomizer() {
		return web -> web.httpFirewall(allowDoubleSlashFirewall());
	}

	@Bean
	public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
		http.authorizeHttpRequests(auth -> auth.anyRequest().permitAll() // 모든 요청 허용 (로그인 필요 없음)
		).csrf(csrf -> csrf.disable()) // CSRF 보호 비활성화 (필요 시 설정 가능)
				.formLogin(form -> form.disable()) // 기본 로그인 페이지 비활성화
				.httpBasic(basic -> basic.disable()) // HTTP Basic 인증 비활성화
				// 👈 3. 소셜 로그인(OAuth2) 설정 추가
				.oauth2Login(oauth2 -> oauth2.loginPage("/member/login.do")
						.userInfoEndpoint(userInfo -> userInfo.userService(customOAuth2UserService))
						.defaultSuccessUrl("/", true) // 카카오 로그인 처리가 끝나면 최종적으로 메인(/)으로 이동
				);

		return http.build();
	}
}