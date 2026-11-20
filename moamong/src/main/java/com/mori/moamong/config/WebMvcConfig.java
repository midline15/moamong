package com.mori.moamong.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import lombok.RequiredArgsConstructor;

@Configuration
@RequiredArgsConstructor
public class WebMvcConfig implements WebMvcConfigurer {

	private final AuthInterceptor authInterceptor;

	@Override
	public void addInterceptors(InterceptorRegistry registry) {
		registry.addInterceptor(authInterceptor)
				// 로그인이 반드시 필요한 URL 패턴 등록
				.addPathPatterns(
						// 1. 회원 마이페이지 및 정보 수정/탈퇴
						"/member/mypage.do", "/member/edit.do", "/member/myinfo.dox", "/member/update-info.dox",
						"/member/change-password.dox", "/member/withdraw.dox",

						// 2. 장바구니 / 주문 / 결제 / 찜 등 회원 전용 액션 (추후 기능 확장 대비)
						"/cart/**", "/order/**", "/payment/**", "/wishlist/**",

						// 3. 관리자 전용 영역 (sessionRole == "ADMIN" 필수)
						"/admin/**")
				// 로그인/회원가입/중복체크 및 정적 리소스는 항상 허용
				.excludePathPatterns("/member/login.do", "/member/login.dox", "/member/join.do", "/member/join.dox",
						"/member/id-duplicate-check.dox", "/css/**", "/js/**", "/images/**");
	}
}
