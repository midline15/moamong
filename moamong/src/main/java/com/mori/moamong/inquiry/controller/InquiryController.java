package com.mori.moamong.inquiry.controller;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;

import jakarta.servlet.http.HttpSession;

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

    // 로그인한 회원 번호 (로그아웃 상태면 0) - 로그인 시 세션에 "sessionId" 로 저장됨
    private long getMemberId(HttpSession session) {
        Object id = session.getAttribute("sessionId");
        if (id == null)
            return 0L;
        try {
            return Long.parseLong(String.valueOf(id));
        } catch (NumberFormatException e) {
            return 0L;
        }
    }

    // 관리자 여부 (DB의 ROLE 로 확인)
    private boolean isAdmin(long memberId) {
        if (memberId == 0)
            return false;
        return inquiryService.isAdmin(memberId);
    }

    // 로그인 필요 응답
    private String needLogin() {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        resultMap.put("result", "fail");
        resultMap.put("msg", "로그인 후 이용해주세요.");
        return new Gson().toJson(resultMap);
    }

    // 1:1문의 목록 페이지
    @RequestMapping("/inquiry/list.do")
    public String list(Model model, HttpSession session) throws Exception {
        long memberId = getMemberId(session);
        model.addAttribute("memberId", memberId);
        model.addAttribute("isLogin", memberId > 0);
        model.addAttribute("isAdmin", isAdmin(memberId));
        return "/inquiry/list";
    }

    // 1:1문의 상세 페이지
    @RequestMapping("/inquiry/view.do")
    public String view(Model model, HttpSession session, @RequestParam(required = false) Long inqId) throws Exception {
        long memberId = getMemberId(session);
        model.addAttribute("inqId", inqId);
        model.addAttribute("memberId", memberId);
        model.addAttribute("isAdmin", isAdmin(memberId));
        return "/inquiry/view";
    }

    // 1:1문의 등록/수정 페이지 (로그인 필요, inqId 있으면 수정)
    @RequestMapping("/inquiry/write.do")
    public String write(Model model, HttpSession session, @RequestParam(required = false) Long inqId) throws Exception {
        if (getMemberId(session) == 0) {
            return "redirect:/member/login.do";
        }
        model.addAttribute("inqId", inqId);
        return "/inquiry/write";
    }

    // 1:1문의 목록 조회 (전체 공개, 내용은 내려주지 않음)
    @RequestMapping(value = "/inquiry/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String list(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = inquiryService.getInquiryList(map);

        return new Gson().toJson(resultMap);
    }

    // 1:1문의 상세 조회 (비밀글은 작성자/관리자만)
    @RequestMapping(value = "/inquiry/view.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String view(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        long memberId = getMemberId(session);
        map.put("viewerId", memberId);                          // 서버에서 다시 지정
        map.put("isAdmin", isAdmin(memberId) ? "Y" : "N");
        resultMap = inquiryService.getInquiry(map);

        return new Gson().toJson(resultMap);
    }

    // 1:1문의 등록 (로그인 필요)
    @RequestMapping(value = "/inquiry/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String add(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        long memberId = getMemberId(session);
        if (memberId == 0)
            return needLogin();

        map.put("memberId", memberId);
        HashMap<String, Object> resultMap = inquiryService.addInquiry(map);

        return new Gson().toJson(resultMap);
    }

    // 1:1문의 수정 (작성자만, 답변 대기 상태에서만)
    @RequestMapping(value = "/inquiry/update.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String update(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        long memberId = getMemberId(session);
        if (memberId == 0)
            return needLogin();

        map.put("memberId", memberId);
        HashMap<String, Object> resultMap = inquiryService.updateInquiry(map);

        return new Gson().toJson(resultMap);
    }

    // 1:1문의 답변 등록/수정 (관리자만)
    @RequestMapping(value = "/inquiry/answer.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String answer(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        long memberId = getMemberId(session);
        if (memberId == 0)
            return needLogin();

        if (!isAdmin(memberId)) {
            HashMap<String, Object> resultMap = new HashMap<String, Object>();
            resultMap.put("result", "fail");
            resultMap.put("msg", "답변은 관리자만 등록할 수 있어요.");
            return new Gson().toJson(resultMap);
        }
        map.put("adminId", memberId);                           // 화면 값 대신 세션의 관리자 번호
        HashMap<String, Object> resultMap = inquiryService.answerInquiry(map);

        return new Gson().toJson(resultMap);
    }

    // 1:1문의 삭제 (작성자 또는 관리자)
    @RequestMapping(value = "/inquiry/delete.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String delete(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        long memberId = getMemberId(session);
        if (memberId == 0)
            return needLogin();

        map.put("viewerId", memberId);
        map.put("isAdmin", isAdmin(memberId) ? "Y" : "N");
        HashMap<String, Object> resultMap = inquiryService.removeInquiry(map);

        return new Gson().toJson(resultMap);
    }

}