package com.mori.moamong.admin.controller;

import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class AdminCouponController {


	// 관리자 쿠폰 목록
	@RequestMapping("/admin/coupon/list.do")
	public String list() {
		return "/admin/coupon/list";
	}

	// 쿠폰 등록 화면
	@RequestMapping("/admin/coupon/add.do")
	public String add() {
		return "/admin/coupon/add";
	}

	// 쿠폰 발급 화면
	@RequestMapping("/admin/coupon/issue.do")
	public String issue() {
		return "/admin/coupon/issue";
	}

	// 쿠폰 수정 화면
	@RequestMapping("/admin/coupon/edit.do")
	public String edit(Model model, @RequestParam HashMap<String, Object> map) {

		model.addAttribute("couponId", map.get("couponId"));

		return "/admin/coupon/edit";
	}

	// 쿠폰 회수 관리 화면
	@RequestMapping("/admin/coupon/view.do")
	public String couponView(Model model, @RequestParam HashMap<String, Object> map) {

		model.addAttribute("couponId", map.get("couponId"));

		return "/admin/coupon/view";
	}

}