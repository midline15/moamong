
package com.mori.moamong.member.controller;

import java.time.LocalDateTime;
import java.util.HashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

import com.mori.moamong.member.service.AdminMemberService;

@Controller
public class AdminMemberController {

	@Autowired
	private AdminMemberService adminmemberService;

	// Gson 설정
	private final Gson gson = new GsonBuilder()
			.registerTypeAdapter(LocalDateTime.class, (JsonSerializer<LocalDateTime>) (src, typeOfSrc,
					context) -> src == null ? null : new JsonPrimitive(src.toString()))
			.create();

	// =====================================
	// 회원 목록 데이터 조회
	// =====================================
	@RequestMapping(value = "/admin/member/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String admin(@RequestParam HashMap<String, Object> map) throws Exception {

		if (map.get("limit") == null) {
			map.put("limit", 5);
		}

		if (map.get("offset") == null) {
			map.put("offset", 0);
		}

		HashMap<String, Object> resultMap = adminmemberService.getAdminList(map);

		return gson.toJson(resultMap);
	}

	// =====================================
	// 회원 상세정보 데이터 조회
	// =====================================
	@RequestMapping(value = "/admin/member/view.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String view2(@RequestParam HashMap<String, Object> map) throws Exception {

		HashMap<String, Object> resultMap = adminmemberService.getAdminDetail(map);

		return gson.toJson(resultMap);
	}

}
