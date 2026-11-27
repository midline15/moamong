
package com.mori.moamong.admin;

import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model; // Spring MVC의 Model을 사용합니다.
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class AdminController {

	// 관리자 콘솔 - 회원 목록 화면 이동
	@RequestMapping("/admin/member/list.do")
	public String memberlist(Model model) throws Exception {

		// 회원 목록 JSP 화면을 보여줍니다.
		return "/admin/member/list";
	}

	// 관리자 콘솔 - 회원 상세/수정 화면 이동
	@RequestMapping("/admin/member/edit.do")
	public String memberview(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
		model.addAttribute("memberId", map.get("memberId"));

		return "/admin/member/edit";
	}

	// 관리자 콘솔 - 상품(단품) 목록 화면 이동
	@RequestMapping("/admin/product/list.do")
	public String productlist(Model model) throws Exception {

		return "/admin/product/list";
	}

	// 관리자 콘솔 - 상품(단품) 목록 상세/수정 화면 이동
	@RequestMapping("/admin/product/edit.do")
	public String productView(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
		model.addAttribute("productId", map.get("productId"));
		return "/admin/product/edit";
	}

	
	// 관리자 콘솔 - 상품 목록 등록 화면 이동
	@RequestMapping("/admin/product/add.do")
	public String productadd(Model model) throws Exception {

		return "/admin/product/add";
	}

	
	// 관리자 콘솔 - 쿠폰 목록 이동
	@RequestMapping("/admin/coupon/list.do")
	public String couponlist() {
		return "/admin/coupon/list";
	}

	// 관리자 콘솔 - 쿠폰 등록 화면
	@RequestMapping("/admin/coupon/add.do")
	public String couponadd() {
		return "/admin/coupon/add";
	}

	// 관리자 콘솔 - 쿠폰 발급 화면
	@RequestMapping("/admin/coupon/issue.do")
	public String couponissue() {
		return "/admin/coupon/issue";
	}

	// 관리자 콘솔 - 쿠폰 수정 화면
	@RequestMapping("/admin/coupon/edit.do")
	public String couponedit(Model model, @RequestParam HashMap<String, Object> map) {

		model.addAttribute("couponId", map.get("couponId"));

		return "/admin/coupon/edit";
	}

	// 관리자 콘솔 - 쿠폰 회수 관리 화면
	@RequestMapping("/admin/coupon/view.do")
	public String couponView(Model model, @RequestParam HashMap<String, Object> map) {

		model.addAttribute("couponId", map.get("couponId"));

		return "/admin/coupon/view";
	}

	// 관리자 콘솔 - 관리자 이벤트 목록
	@RequestMapping("/admin/event/list.do")
	public String eventlist() {
		return "/admin/event/list";
	}

	// 관리자 콘솔 - 관리자 이벤트 상세
	@RequestMapping("/admin/event/view.do")
	public String eventview() {
		return "/admin/event/view";
	}

	// 관리자 콘솔 - 관리자 이벤트 등록/수정
	@RequestMapping("/admin/event/write.do")
	public String eventwrite() {
		return "/admin/event/write";
	}

	// 관리자 콘솔 - 운영 정책 관리 화면

	@RequestMapping("admin/policy/list.do")
	public String policylist(Model model) throws Exception {

		return "/admin/policy/list";
	}

}
