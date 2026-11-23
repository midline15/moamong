package com.mori.moamong.event.controller;

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
import com.mori.moamong.event.service.EventService;


import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class EventController {
    private final EventService eventService;

    // TODO: 로그인 기능 붙이면 false 로 바꾸기 (true 이면 누구나 관리자 취급)
    private static final boolean DEV_MODE = true;

    // 관리자 여부 (TODO: 실제 로그인 세션 키로 교체)
    private boolean isAdmin(HttpSession session) {
        if (DEV_MODE) return true;
        return session.getAttribute("adminId") != null;
    }

    // 이벤트 목록 페이지
    @RequestMapping("/event/list.do")
    public String list(Model model, HttpSession session) throws Exception {
        model.addAttribute("isAdmin", isAdmin(session));
        return "/event/list";
    }

    // 이벤트 상세 페이지
    @RequestMapping("/event/view.do")
    public String view(Model model, HttpSession session, @RequestParam(required = false) Long eventId) throws Exception {
        model.addAttribute("eventId", eventId);
        model.addAttribute("isAdmin", isAdmin(session));
        return "/event/view";
    }

    // 이벤트 등록/수정 페이지 (관리자만, eventId 있으면 수정)
    @RequestMapping("/event/write.do")
    public String write(Model model, HttpSession session, @RequestParam(required = false) Long eventId) throws Exception {
        if (!isAdmin(session)) {
            return "redirect:/event/list.do";
        }
        model.addAttribute("eventId", eventId);
        return "/event/write";
    }

    // 이벤트 목록 조회
    @RequestMapping(value = "/event/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String list(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        // 화면에서 보낸 값은 믿지 않고 서버에서 다시 지정 (숨김 이벤트는 관리자만)
        map.put("isAdmin", isAdmin(session) ? "Y" : "N");
        resultMap = eventService.getEventList(map);

        return new Gson().toJson(resultMap);
    }

    // 이벤트 상세 조회
    @RequestMapping(value = "/event/view.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String view(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        map.put("isAdmin", isAdmin(session) ? "Y" : "N");
        resultMap = eventService.getEvent(map);

        return new Gson().toJson(resultMap);
    }

    // 이벤트 등록 (관리자만)
    @RequestMapping(value = "/event/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String add(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        if (!isAdmin(session)) {
            resultMap.put("result", "fail");
            resultMap.put("msg", "권한이 없습니다.");
            return new Gson().toJson(resultMap);
        }
        resultMap = eventService.addEvent(map);

        return new Gson().toJson(resultMap);
    }

    // 이벤트 수정 (관리자만)
    @RequestMapping(value = "/event/update.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String update(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        if (!isAdmin(session)) {
            resultMap.put("result", "fail");
            resultMap.put("msg", "권한이 없습니다.");
            return new Gson().toJson(resultMap);
        }
        resultMap = eventService.updateEvent(map);

        return new Gson().toJson(resultMap);
    }

    // 이벤트 삭제 (관리자만)
    @RequestMapping(value = "/event/delete.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String delete(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        if (!isAdmin(session)) {
            resultMap.put("result", "fail");
            resultMap.put("msg", "권한이 없습니다.");
            return new Gson().toJson(resultMap);
        }
        resultMap = eventService.removeEvent(map);

        return new Gson().toJson(resultMap);
    }

}
