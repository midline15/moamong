
package com.mori.moamong.admin.controller;

import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model; // Spring MVC의 Model을 사용합니다.
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.mori.moamong.admin.service.AdminService;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class AdminController {

	// AdminService를 사용하기 위한 객체입니다.
	// final과 @RequiredArgsConstructor를 사용하면 생성자가 자동으로 만들어집니다.
	private final AdminService adminService;

	// =====================================
	// 1. 관리자 콘솔 - 회원 목록 화면 이동
	// =====================================
	@RequestMapping("/admin/list.do")
	public String admin(Model model) throws Exception {

		// 회원 목록 JSP 화면을 보여줍니다.
		return "/admin/list";
	}

	// =====================================
	// 2. 관리자 콘솔 - 회원 상세 화면 이동
	// =====================================

	@RequestMapping("/admin/view.do")
	public String view(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

		// 목록에서 전달받은 회원 ID를 JSP에 전달합니다.
		model.addAttribute("memberId", map.get("memberId"));

		return "/admin/view";
	}

	// =====================================
	// 3. 관리자 콘솔 - 이벤트 화면 이동
	// =====================================
	@RequestMapping("/admin/event.do")
	public String event(Model model) throws Exception {
		return "/admin/event";
	}

	// =====================================
	// 회원 목록 데이터 조회
	// =====================================

	@RequestMapping(value = "/admin/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String admin(@RequestParam HashMap<String, Object> map) throws Exception {

		// limit이 전달되지 않았거나 비어 있다면 5명으로 설정
		if (map.get("limit") == null) {
			map.put("limit", 5);
		}

		// offset이 전달되지 않았거나 비어 있다면 0으로 설정
		if (map.get("offset") == null) {
			map.put("offset", 0);
		}

		HashMap<String, Object> resultMap = adminService.getAdminList(map);

		// JSON 형태로 변환해서 JSP에 전달
		return new Gson().toJson(resultMap);
	}


	// =====================================
	// 회원 상세정보 데이터 조회
	// =====================================
	@RequestMapping(value = "/admin/view.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String view2(@RequestParam HashMap<String, Object> map) throws Exception {

		// Service를 호출하여 회원 상세정보를 조회합니다.
		HashMap<String, Object> resultMap = adminService.getAdminDetail(map);

		// 결과를 JSON으로 변환하여 JSP에 전달합니다.
		return new Gson().toJson(resultMap);
	}

}
