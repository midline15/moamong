
package com.mori.moamong.member.controller;

import java.util.HashMap;

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
import com.mori.moamong.member.service.AdminMemberService;

import java.time.LocalDateTime;

@Controller
public class AdminMemberController {

	@Autowired
	private AdminMemberService adminmemberService;

	// JSON 변환 설정
	private final Gson gson = new GsonBuilder().registerTypeAdapter(LocalDateTime.class,
			(JsonSerializer<LocalDateTime>) (src, type, context) -> new com.google.gson.JsonPrimitive(src.toString()))
			.create();


	// 회원 목록 조회
	@RequestMapping(value = "/admin/member/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String listData(@RequestParam HashMap<String, Object> map) {

		if (!map.containsKey("limit")) {
			map.put("limit", 5);
		}

		if (!map.containsKey("offset")) {
			map.put("offset", 0);
		}

		HashMap<String, Object> resultMap = adminmemberService.getAdminList(map);

		return gson.toJson(resultMap);

	}

	// 회원 상세 정보 조회
	@RequestMapping(value = "/admin/member/edit.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String view(@RequestParam HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = adminmemberService.getAdminDetail(map);

		return gson.toJson(resultMap);

	}

	// 회원 등급 변경
	@RequestMapping(value = "/admin/member/grade/update.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String updateGrade(@RequestParam HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = adminmemberService.updateMemberGrade(map);

		return gson.toJson(resultMap);

	}

	// 회원 상태 변경
	@RequestMapping(value = "/admin/member/status/update.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String updateStatus(@RequestParam HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = adminmemberService.updateMemberStatus(map);

		return gson.toJson(resultMap);

	}

	// 회원 강제 탈퇴
	@RequestMapping(value = "/admin/member/withdraw.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String withdraw(@RequestParam HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = adminmemberService.withdrawMember(map);

		return gson.toJson(resultMap);

	}
	
	// 회원 기본정보 수정
	@RequestMapping(value = "/admin/member/info/update.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String updateInfo(@RequestParam HashMap<String, Object> map) {

	    HashMap<String, Object> resultMap = adminmemberService.updateMemberInfo(map);

	    return gson.toJson(resultMap);

	}

}
