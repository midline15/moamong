package com.mori.moamong.config;

import java.io.PrintWriter;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Component
public class AuthInterceptor implements HandlerInterceptor {

	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
			throws Exception {
		String uri = request.getRequestURI();
		HttpSession session = request.getSession(false);

		Object sessionId = (session != null) ? session.getAttribute("sessionId") : null;
		String sessionRole = (session != null) ? (String) session.getAttribute("sessionRole") : null;
		String sessionStatus = (session != null) ? (String) session.getAttribute("sessionStatus") : null;

		// 1. 비로그인 차단 (로그인 필수 경로에 접근 시)
		if (sessionId == null) {
			if (uri.endsWith(".dox")) {
				response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
				response.setContentType("application/json;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.print("{\"result\":\"unauthorized\", \"message\":\"로그인이 필요한 서비스입니다.\"}");
				out.flush();
			} else {
				response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.print("<script>alert('로그인이 필요한 서비스입니다.'); location.href='/member/login.do';</script>");
				out.flush();
			}
			return false;
		}

		// 2. 정지(SUSPENDED) 또는 탈퇴(WITHDRAWN) 계정 차단 (로그인 중 DB에서 상태 변경된 경우 대비)
		if (!"ACTIVE".equals(sessionStatus)) {
			session.invalidate();
			if (uri.endsWith(".dox")) {
				response.setStatus(HttpServletResponse.SC_FORBIDDEN);
				response.setContentType("application/json;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.print("{\"result\":\"forbidden\", \"message\":\"이용이 제한된 계정입니다.\"}");
				out.flush();
			} else {
				response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.print("<script>alert('이용이 제한된 계정입니다.'); location.href='/member/login.do';</script>");
				out.flush();
			}
			return false;
		}

		// 3. 관리자(ADMIN) 권한 체크 (/admin/** 경로) 
		// 관리자(ADMIN) 권한 체크
		if (uri.startsWith("/admin/") && !"ADMIN".equals(sessionRole)) {

			if (uri.endsWith(".dox")) {

				response.setStatus(HttpServletResponse.SC_FORBIDDEN);
				response.setContentType("application/json;charset=UTF-8");

				PrintWriter out = response.getWriter();

				out.print("{\"result\":\"forbidden\", \"message\":\"관리자 권한이 없습니다.\"}");
				out.flush();

			} else {

				response.setContentType("text/html;charset=UTF-8");

				PrintWriter out = response.getWriter();

				out.print("<script>alert('관리자만 접근할 수 있는 페이지입니다.'); location.href='/';</script>");
				out.flush();

			}

			return false;
		}

		return true;
	}
}