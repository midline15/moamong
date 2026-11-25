package com.mori.moamong.coupon.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.mori.moamong.coupon.service.CouponService;

@Controller
public class CouponController {

	@Autowired
	CouponService couponService;

	// 마이페이지 - 내 쿠폰
	@RequestMapping("/coupon/mylist.do")
	public String myCouponList(@RequestParam("memberId") Long memberId, Model model) {
		model.addAttribute("memberId", memberId);
		return "coupon/MyCouponList";
	}

	// 관리자 쿠폰 목록
	@RequestMapping("/coupon/list.do")
	public String list(Model model) {
		return "/coupon/list";
	}

	// 쿠폰 등록 화면
	@RequestMapping("/coupon/add.do")
	public String add(Model model) {
		return "/coupon/add";
	}

	// 쿠폰 발급 화면
	@RequestMapping("/coupon/issue.do")
	public String issue(Model model) {
		return "/coupon/issue";
	}

	// 쿠폰 수정 화면
	@RequestMapping("/coupon/edit.do")
	public String edit(Model model, @RequestParam HashMap<String, Object> map) {
		model.addAttribute("couponId", map.get("couponId"));
		return "/coupon/edit";
	}

	// 쿠폰 회수 관리 화면
	@RequestMapping("/coupon/view.do")
	public String couponView(Model model, @RequestParam HashMap<String, Object> map) {
		model.addAttribute("couponId", map.get("couponId"));
		return "coupon/view";
	}

	// 마이페이지 쿠폰 조회 - 기존 기능 유지
	@RequestMapping("/coupon/mylist.dox")
	@ResponseBody
	public Map<String, Object> getMyCouponList(@RequestParam("memberId") Long memberId) {

		HashMap<String, Object> map = new HashMap<>();
		map.put("memberId", memberId);

		return couponService.geCouponList(map);
	}

	// 관리자 쿠폰 목록 조회
	@RequestMapping(value = "/coupon/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> getCouponList(@RequestParam HashMap<String, Object> map) {
		return couponService.getCouponList(map);
	}

	// 쿠폰 상세 조회
	@RequestMapping(value = "/coupon/view.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> getCoupon(@RequestParam HashMap<String, Object> map) {
		return couponService.getCoupon(map);
	}

	// 쿠폰 등록
	@RequestMapping(value = "/coupon/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> addCoupon(@RequestParam HashMap<String, Object> map) {
		return couponService.addCoupon(map);
	}

	// 쿠폰 수정
	@RequestMapping(value = "/coupon/edit.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> editCoupon(@RequestParam HashMap<String, Object> map) {
		return couponService.editCoupon(map);
	}

	// 쿠폰 삭제
	@RequestMapping(value = "/coupon/remove.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> removeCoupon(@RequestParam HashMap<String, Object> map) {
		return couponService.removeCoupon(map);
	}

	// 회원 검색
	@RequestMapping(value = "/coupon/member/search.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> searchMember(@RequestParam HashMap<String, Object> map) {
		return couponService.searchMember(map);
	}

	// 쿠폰 발급
	@RequestMapping(value = "/coupon/issue.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> issueCoupon(@RequestParam HashMap<String, Object> map) {
		return couponService.issueCoupon(map);
	}

	// 발급 회원 목록
	@RequestMapping(value = "/coupon/issued/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> getIssuedMemberList(@RequestParam HashMap<String, Object> map) {
		return couponService.getIssuedMemberList(map);
	}

	// 회원 쿠폰 개별 회수
	@RequestMapping(value = "/coupon/revoke.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> revokeMemberCoupon(@RequestParam HashMap<String, Object> map) {
		return couponService.revokeMemberCoupon(map);
	}

	// 사용 가능한 쿠폰 일괄 회수
	@RequestMapping(value = "/coupon/revoke/all.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public HashMap<String, Object> revokeAllMemberCoupon(@RequestParam HashMap<String, Object> map) {
		return couponService.revokeAllMemberCoupon(map);
	}
}