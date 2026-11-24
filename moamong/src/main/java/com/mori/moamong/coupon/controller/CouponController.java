package com.mori.moamong.coupon.controller;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonSerializer;
import com.mori.moamong.coupon.service.CouponService;

@Controller
public class CouponController {

	@Autowired
	CouponService couponService;

	// 마이페이지 - 내 쿠폰 목록
	@RequestMapping("/coupon/mylist.do")
	public String myCouponList(@RequestParam("memberId") Long memberId, Model model) {

		model.addAttribute("memberId", memberId);

		return "coupon/MyCouponList";
	}

	// 관리자-쿠폰 목록 화면

	@RequestMapping("/coupon/list.do")
	public String list(Model model) throws Exception {

		// 관리자-쿠폰 목록 JSP 화면으로 이동합니다.
		return "/coupon/list";

	}

	// 관리자-쿠폰 등록 화면
	

	@RequestMapping("/coupon/add.do")
	public String add(Model model) throws Exception {

		// 관리자-쿠폰 등록 JSP 화면으로 이동합니다.
		return "/coupon/add";

	}

	
	// 관리자-쿠폰 상세 및 수정 화면


	@RequestMapping("/coupon/edit.do")
	public String view(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

		// URL로 전달받은 관리자-쿠폰 번호를 JSP에 전달합니다.
		// JSP에서 ${couponId} 형태로 사용할 수 있습니다.
		model.addAttribute("couponId", map.get("couponId"));

		// 관리자-쿠폰 상세 및 수정 JSP 화면으로 이동합니다.
		return "/coupon/edit";

	}

	// 마이페이지 - 내 쿠폰 목록 조회
	@RequestMapping("/coupon/mylist.dox")
	@ResponseBody
	public Map<String, Object> getMyCouponList(@RequestParam("memberId") Long memberId) {

		// 조회 조건 전달
		HashMap<String, Object> map = new HashMap<>();
		map.put("memberId", memberId);

		// 서비스 호출
		return couponService.geCouponList(map);
	}

	
	// 관리자-쿠폰 목록 조회
	

	@RequestMapping(value = "/coupon/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> getCouponList(@RequestParam HashMap<String, Object> map) throws Exception {

		HashMap<String, Object> resultMap = couponService.getCouponList(map);

		return resultMap;
	}

	
	// 관리자-쿠폰 상세 조회
	

	@RequestMapping(value = "/coupon/view.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> getCoupon(@RequestParam HashMap<String, Object> map) throws Exception {

		HashMap<String, Object> resultMap = couponService.getCoupon(map);

		return resultMap;
	}
	
	// 관리자-쿠폰 등록


	@RequestMapping(value = "/coupon/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String addCoupon(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

		// Service에 관리자-쿠폰 등록을 요청합니다.
		HashMap<String, Object> resultMap = couponService.addCoupon(map);

		// 등록 결과를 JSON 문자열로 변환해서 화면에 전달합니다.
		return new Gson().toJson(resultMap);

	}


	// 관리자-쿠폰 삭제
	

	@RequestMapping(value = "/coupon/remove.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String removeCoupon(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

		// Service에 관리자-쿠폰 삭제를 요청합니다.
		HashMap<String, Object> resultMap = couponService.removeCoupon(map);

		// 삭제 결과를 JSON 문자열로 변환해서 화면에 전달합니다.
		return new Gson().toJson(resultMap);

	}

	
	// 관리자-쿠폰 수정
	

	@RequestMapping(value = "/coupon/edit.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String editCoupon(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

		HashMap<String, Object> resultMap = couponService.editCoupon(map);
		return new Gson().toJson(resultMap);

	}

}
