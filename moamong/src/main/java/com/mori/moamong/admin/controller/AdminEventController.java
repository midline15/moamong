
package com.mori.moamong.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class AdminEventController {


	// 관리자 이벤트 목록
	@RequestMapping("/admin/event/list.do")
	public String list() {
		return "/admin/event/list";
	}

	// 관리자 이벤트 상세
	@RequestMapping("/admin/event/view.do")
	public String view() {
		return "/admin/event/view";
	}

	// 관리자 이벤트 등록/수정
	@RequestMapping("/admin/event/write.do")
	public String write() {
		return "/admin/event/write";
	}

	
}
