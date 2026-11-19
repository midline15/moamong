package com.mori.moamong.notice.controller;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestMethod;

import com.google.gson.Gson;
import com.mori.moamong.notice.service.NoticeService;

@RequiredArgsConstructor
@Controller
public class NoticeController {
    private final NoticeService noticeService;


    // 공지사항 목록 페이지
    @RequestMapping("/notice/list.do")
	public String list(Model model) throws Exception{
		
		return "/notice/list";
	}

    @RequestMapping(value = "/notice/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String list(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
		HashMap<String, Object> resultMap = new HashMap<String, Object>();
		
		resultMap = noticeService.getNoticeList(map);
		
		return new Gson().toJson(resultMap); 
	}

}
