package com.mori.moamong.faq.controller;

import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@RequiredArgsConstructor
@Controller
public class FaqController {

    // 자주 묻는 질문 페이지 (하드코딩이라 .do 하나만 사용)
    @RequestMapping("/faq/list.do")
    public String list(Model model) throws Exception {

        return "/faq/list";
    }

}