
package com.mori.moamong.member.controller;

import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.mori.moamong.member.service.MemberService;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class MemberController {

    private final MemberService memberService;

    // 로그인 페이지 이동
    @RequestMapping("/member/login.do")
    public String login(Model model, @RequestParam HashMap<String, Object> map) throws Exception {

        model.addAttribute("memberId", map.get("memberId"));

        return "/member/login";
    }

    // 로그인 처리
    @RequestMapping(value = "/member/login.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String login(@RequestParam HashMap<String, Object> map) throws Exception {

        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = memberService.login(map);

        return new Gson().toJson(resultMap);
    }
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
