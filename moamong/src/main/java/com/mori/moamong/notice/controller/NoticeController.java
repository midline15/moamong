package com.mori.moamong.notice.controller;

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
import com.mori.moamong.notice.service.NoticeService;

@RequiredArgsConstructor
@Controller
public class NoticeController {
    private final NoticeService noticeService;

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
        return noticeService.isAdmin(memberId);
    }

    // 관리자가 아닐 때 응답 (null 이면 관리자)
    private String checkAdmin(long memberId) {
        if (memberId == 0 || !isAdmin(memberId)) {
            HashMap<String, Object> resultMap = new HashMap<String, Object>();
            resultMap.put("result", "fail");
            resultMap.put("msg", memberId == 0 ? "로그인 후 이용해주세요." : "공지사항은 관리자만 작성할 수 있어요.");
            return new Gson().toJson(resultMap);
        }
        return null;
    }

    // 공지사항 목록 페이지
    @RequestMapping("/notice/list.do")
    public String list(Model model, HttpSession session) throws Exception {
        model.addAttribute("isAdmin", isAdmin(getMemberId(session)));
        return "/notice/list";
    }

    // 공지사항 상세 페이지
    @RequestMapping("/notice/view.do")
    public String view(Model model, HttpSession session, @RequestParam(required = false) Long noticeId) throws Exception {
        model.addAttribute("noticeId", noticeId);
        model.addAttribute("isAdmin", isAdmin(getMemberId(session)));
        return "/notice/view";
    }

    // 공지사항 등록/수정 페이지 (관리자만, noticeId 있으면 수정)
    @RequestMapping("/notice/write.do")
    public String write(Model model, HttpSession session, @RequestParam(required = false) Long noticeId) throws Exception {
        if (!isAdmin(getMemberId(session))) {
            return "redirect:/notice/list.do";
        }
        model.addAttribute("noticeId", noticeId);
        return "/notice/write";
    }

    // 공지사항 목록 조회
    @RequestMapping(value = "/notice/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String list(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = noticeService.getNoticeList(map);

        return new Gson().toJson(resultMap);
    }

    // 공지사항 상세 조회 (addView = Y 이면 조회수 증가)
    @RequestMapping(value = "/notice/view.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String view(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = noticeService.getNotice(map);

        return new Gson().toJson(resultMap);
    }

    // 공지사항 등록 (관리자만)
    @RequestMapping(value = "/notice/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String add(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        long memberId = getMemberId(session);
        String denied = checkAdmin(memberId);
        if (denied != null)
            return denied;

        map.put("adminId", memberId);   // 화면 값 대신 세션의 관리자 번호
        HashMap<String, Object> resultMap = noticeService.addNotice(map);

        return new Gson().toJson(resultMap);
    }

    // 공지사항 수정 (관리자만)
    @RequestMapping(value = "/notice/update.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String update(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        String denied = checkAdmin(getMemberId(session));
        if (denied != null)
            return denied;

        HashMap<String, Object> resultMap = noticeService.updateNotice(map);

        return new Gson().toJson(resultMap);
    }

    // 공지사항 삭제 (관리자만)
    @RequestMapping(value = "/notice/delete.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String delete(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        String denied = checkAdmin(getMemberId(session));
        if (denied != null)
            return denied;

        HashMap<String, Object> resultMap = noticeService.removeNotice(map);

        return new Gson().toJson(resultMap);
    }

}