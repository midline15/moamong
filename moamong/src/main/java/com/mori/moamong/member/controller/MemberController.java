
package com.mori.moamong.member.controller;

import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.mori.moamong.member.service.MemberService;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class MemberController {

	private final MemberService memberService;

	// 로그인 페이지 이동
	@RequestMapping("/member/login.do")
	public String login(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

		model.addAttribute("memberId", map.get("memberId"));

		return "member/login";
	}

	// 로그인 처리
	@RequestMapping(value = "/member/login.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String login(@RequestParam HashMap<String, Object> map) throws Exception {

		HashMap<String, Object> resultMap = new HashMap<String, Object>();

		resultMap = memberService.login(map);

		return new Gson().toJson(resultMap);
	}

	@RequestMapping("/")
	public String requestMethodName() {
		return "/default";
	}

	@RequestMapping(value = "/id-duplicate-check.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String idDuplicateCheck(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
		HashMap<String, Object> resultMap = new HashMap<String, Object>();

		// resultMap = memberService.idDuplicateCheck(map);

		return new Gson().toJson(resultMap);
	}

	// 회원가입 페이지 이동
	@RequestMapping("/member/join.do")
	public String joinPage() {
		return "member/join";
	}

	// 아이디 중복 확인
	@RequestMapping(value = "/member/id-duplicate-check.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String idDuplicateCheck(@RequestParam HashMap<String, Object> map) throws Exception {
		HashMap<String, Object> resultMap = memberService.idDuplicateCheck(map);
		return new Gson().toJson(resultMap);
	}

	// 회원가입 처리
	@RequestMapping(value = "/member/join.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String join(@RequestParam HashMap<String, Object> map) throws Exception {
		HashMap<String, Object> resultMap = memberService.join(map);
		return new Gson().toJson(resultMap);
	}

	// 로그아웃 처리 (페이지 이동 방식)
	@RequestMapping("/member/logout.do")
	public String logout(jakarta.servlet.http.HttpSession session) {
		session.invalidate();
		return "redirect:/member/login.do";
	}

	// 로그아웃 처리 (AJAX 방식)
	@RequestMapping(value = "/member/logout.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String logoutAjax(jakarta.servlet.http.HttpSession session) {
		HashMap<String, Object> resultMap = new HashMap<>();
		session.invalidate();
		resultMap.put("result", "success");
		resultMap.put("message", "로그아웃 되었습니다.");
		return new Gson().toJson(resultMap);
	}

	// 마이페이지 대시보드 이동
	@RequestMapping("/member/mypage.do")
	public String mypage(jakarta.servlet.http.HttpSession session) {
		if (session.getAttribute("sessionId") == null) {
			return "redirect:/member/login.do";
		}
		return "member/mypage";
	}

	// 회원정보 수정/탈퇴 페이지 이동
	@RequestMapping("/member/edit.do")
	public String editMemberPage(jakarta.servlet.http.HttpSession session) {
		if (session.getAttribute("sessionId") == null) {
			return "redirect:/member/login.do";
		}
		return "member/edit";
	}

	// 내 정보 조회
	 @RequestMapping(value = "/member/myinfo.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	    @ResponseBody
	    public HashMap<String, Object> getMyInfo(jakarta.servlet.http.HttpSession session) {
	        Long memberId = Long.valueOf(String.valueOf(session.getAttribute("sessionId")));
	        return memberService.getMyInfo(memberId);
	}

	// 내 정보 수정
	@RequestMapping(value = "/member/update-info.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String updateMemberInfo(@RequestParam HashMap<String, Object> map,
			jakarta.servlet.http.HttpSession session) {
		map.put("memberId", session.getAttribute("sessionId"));
		HashMap<String, Object> resultMap = memberService.updateMemberInfo(map);
		return new Gson().toJson(resultMap);
	}

	// 비밀번호 변경
	@RequestMapping(value = "/member/change-password.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String changePassword(@RequestParam HashMap<String, Object> map, jakarta.servlet.http.HttpSession session) {
		map.put("memberId", session.getAttribute("sessionId"));
		HashMap<String, Object> resultMap = memberService.changePassword(map);
		return new Gson().toJson(resultMap);
	}

	// 회원 탈퇴
	@RequestMapping(value = "/member/withdraw.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String withdraw(@RequestParam("password") String password, jakarta.servlet.http.HttpSession session) {
		Long memberId = Long.valueOf(String.valueOf(session.getAttribute("sessionId")));
		HashMap<String, Object> resultMap = memberService.withdraw(memberId, password);
		return new Gson().toJson(resultMap);
	}

}
