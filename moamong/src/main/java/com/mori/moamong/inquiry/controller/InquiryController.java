package com.mori.moamong.inquiry.controller;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RequestMethod;

import com.google.gson.Gson;
import com.mori.moamong.inquiry.service.InquiryService;

@RequiredArgsConstructor
@Controller
public class InquiryController {
    private final InquiryService inquiryService;

	// 1:1문의 목록 페이지
    @RequestMapping("/inquiry/list.do")
	public String list(Model model) throws Exception{
		
		return "/inquiry/list";
	}

    @RequestMapping(value = "/inquiry/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String list(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
		HashMap<String, Object> resultMap = new HashMap<String, Object>();
		
		resultMap = inquiryService.getInquiryList(map);
		
		return new Gson().toJson(resultMap); 
	}

}
