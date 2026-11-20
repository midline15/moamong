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
    public String list(Model model) throws Exception {

        return "/inquiry/list";
    }

    // 1:1문의 상세 페이지
    @RequestMapping("/inquiry/view.do")
    public String view(Model model, @RequestParam(required = false) Long inqId) throws Exception {
        model.addAttribute("inqId", inqId);
        return "/inquiry/view";
    }

    // 1:1문의 등록/수정 페이지 (inqId 있으면 수정)
    @RequestMapping("/inquiry/write.do")
    public String write(Model model, @RequestParam(required = false) Long inqId) throws Exception {
        model.addAttribute("inqId", inqId);
        return "/inquiry/write";
    }

    // 1:1문의 목록 조회
    @RequestMapping(value = "/inquiry/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String list(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = inquiryService.getInquiryList(map);

        return new Gson().toJson(resultMap);
    }

    // 1:1문의 상세 조회
    @RequestMapping(value = "/inquiry/view.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String view(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = inquiryService.getInquiry(map);

        return new Gson().toJson(resultMap);
    }

    // 1:1문의 등록
    @RequestMapping(value = "/inquiry/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String add(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = inquiryService.addInquiry(map);

        return new Gson().toJson(resultMap);
    }

    // 1:1문의 수정 (답변 대기 상태에서만 가능)
    @RequestMapping(value = "/inquiry/update.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String update(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = inquiryService.updateInquiry(map);

        return new Gson().toJson(resultMap);
    }

    // 1:1문의 답변 등록/수정 (관리자)
    @RequestMapping(value = "/inquiry/answer.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String answer(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = inquiryService.answerInquiry(map);

        return new Gson().toJson(resultMap);
    }

    // 1:1문의 삭제
    @RequestMapping(value = "/inquiry/delete.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String delete(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = inquiryService.removeInquiry(map);

        return new Gson().toJson(resultMap);
    }

}