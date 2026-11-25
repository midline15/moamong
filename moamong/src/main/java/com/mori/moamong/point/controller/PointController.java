package com.mori.moamong.point.controller;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;
import com.mori.moamong.point.service.PointService;

@Controller
public class PointController {
	// 포인트 내역 조회를 담당하는 Service를 가져옵니다.
    @Autowired
    PointService pointService;

    // 포인트 히스토리 화면으로 이동합니다.
    @RequestMapping("/point/history.do")
    public String history(
            @RequestParam(value = "memberId", required = false) String memberId,
            jakarta.servlet.http.HttpSession session,
            Model model) {
        if ((memberId == null || memberId.isEmpty() || "null".equals(memberId)) && session.getAttribute("sessionId") != null) {
            memberId = String.valueOf(session.getAttribute("sessionId"));
        }
        if (memberId == null) return "redirect:/member/login.do";
        model.addAttribute("memberId", memberId);
        return "point/list";
    }

    // 포인트 내역을 조회하는 AJAX 요청입니다.
    @RequestMapping(value = "/point/history.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String getHistory(
            jakarta.servlet.http.HttpSession session,
            @RequestParam HashMap<String, Object> map) throws Exception {
        if ((map.get("memberId") == null || String.valueOf(map.get("memberId")).isEmpty() || "null".equals(String.valueOf(map.get("memberId"))))
                && session.getAttribute("sessionId") != null) {
            map.put("memberId", session.getAttribute("sessionId"));
        }
        HashMap<String, Object> resultMap = pointService.getPointList(map);
        Gson gson = new GsonBuilder()
                .registerTypeAdapter(
                    LocalDateTime.class,
                    (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context) ->
                        new JsonPrimitive(src.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")))
                )
                .create();
        return gson.toJson(resultMap);
    }

}
