package com.mori.moamong.coupon.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.mori.moamong.coupon.service.CouponService;

@Controller
public class CouponController {

	@Autowired
	CouponService couponService;

	// 쿠폰 내역 페이지 이동
	@RequestMapping("/coupon/mylist.do")
	public String myCouponList(@RequestParam("memberId") Long memberId, Model model) {

		model.addAttribute("memberId", memberId);

		return "coupon/list";
	}

	// 회원별 쿠폰 내역 조회
	@RequestMapping("/coupon/mylist.dox")
	@ResponseBody
	public Map<String, Object> getMyCouponList(@RequestParam("memberId") Long memberId) {

		// 조회 조건 전달
		HashMap<String, Object> map = new HashMap<>();
		map.put("memberId", memberId);

		// 서비스 호출
		return couponService.geCouponList(map);
	}

}