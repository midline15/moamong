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
    // 사용자가 /point/history.do 주소로 접속하면 실행됩니다.
    @RequestMapping("/point/history.do")
    public String history( @RequestParam("memberId") String memberId, Model model) {
        model.addAttribute("memberId", memberId);
        return "point/list";
    }


    // 포인트 내역을 조회하는 AJAX 요청입니다.
    // JSP에서 /point/history.dox 주소로 POST 요청을 보내면 실행됩니다.
    @RequestMapping(value = "/point/history.dox", method = RequestMethod.POST,produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String getHistory(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        // Service에서 반환한 결과를 저장할 공간입니다.
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        // Service에 포인트 내역 조회를 요청합니다.
        resultMap = pointService.getPointList(map);
        // HashMap에 담긴 결과를 JSON 문자열로 변환하여 화면에 전달합니다.
        Gson gson = new GsonBuilder()
        	    .registerTypeAdapter(
        	        LocalDateTime.class,
        	        (JsonSerializer<LocalDateTime>) (src, typeOfSrc, context) ->
        	            new JsonPrimitive(
        	                src.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))
        	            )
        	    )
        	    .create();

        	return gson.toJson(resultMap);
    }

}
