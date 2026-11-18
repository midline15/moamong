package com.mori.moamong.member.controller;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;

import org.springframework.ai.model.Model;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.mori.moamong.member.service.MemberService;

@RequiredArgsConstructor
@Controller
public class MemberController {
    private final MemberService memberService;

    @RequestMapping("/")
    public String requestMethodName() {
        return "/default";
    }
    

    @RequestMapping(value = "/id-duplicate-check.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String idDuplicateCheck(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
		HashMap<String, Object> resultMap = new HashMap<String, Object>();
		
		// resultMap = memberService.idDuplicateCheck(map);
		
		return new Gson().toJson(resultMap); 
	}
    
}
