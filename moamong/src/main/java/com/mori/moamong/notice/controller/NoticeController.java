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
    public String list(Model model) throws Exception {

        return "/notice/list";
    }

    // 공지사항 상세 페이지
    @RequestMapping("/notice/view.do")
    public String view(Model model, @RequestParam(required = false) Long noticeId) throws Exception {
        model.addAttribute("noticeId", noticeId);
        return "/notice/view";
    }

    // 공지사항 등록/수정 페이지 (noticeId 있으면 수정)
    @RequestMapping("/notice/write.do")
    public String write(Model model, @RequestParam(required = false) Long noticeId) throws Exception {
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

    // 공지사항 등록
    @RequestMapping(value = "/notice/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String add(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = noticeService.addNotice(map);

        return new Gson().toJson(resultMap);
    }

    // 공지사항 수정
    @RequestMapping(value = "/notice/update.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String update(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = noticeService.updateNotice(map);

        return new Gson().toJson(resultMap);
    }

    // 공지사항 삭제
    @RequestMapping(value = "/notice/delete.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String delete(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = noticeService.removeNotice(map);

        return new Gson().toJson(resultMap);
    }

}