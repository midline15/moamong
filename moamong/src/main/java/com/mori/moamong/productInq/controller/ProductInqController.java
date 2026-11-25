package com.mori.moamong.productInq.controller;

import java.util.HashMap;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.mori.moamong.productInq.service.ProductInqService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class ProductInqController {
    private final ProductInqService productInqService;

    // 상품 문의 목록 조회
    @RequestMapping(value = "/productInq/list.dox")
    @ResponseBody
    public String productInqList(
            @RequestParam HashMap<String, Object> map,
            HttpSession session) {

        map.put("memberId", session.getAttribute("sessionId"));
        map.put("role", session.getAttribute("sessionRole"));

        HashMap<String, Object> result = productInqService.getProductInqList(map);

        return new Gson().toJson(result);
    }

    // 상품 문의 등록
    @RequestMapping(value = "/productInq/add.dox")
    @ResponseBody
    public String productInqAdd(
            @RequestParam HashMap<String, Object> map,
            HttpSession session) {

        HashMap<String, Object> result = new HashMap<>();

        // 로그인 여부 확인
        if (session.getAttribute("sessionId") == null) {
            result.put("result", "fail");
            result.put("message", "로그인 후 문의를 작성할 수 있습니다.");
            return new Gson().toJson(result);
        }

        // 로그인 세션 정보 설정
        map.put("memberId", session.getAttribute("sessionId"));

        result = productInqService.addProductInq(map);

        return new Gson().toJson(result);
    }

    // 상품 문의 답변 등록
    @RequestMapping(value = "/productInq/answer.dox")
    @ResponseBody
    public String productInqAnswer(
            @RequestParam HashMap<String, Object> map,
            HttpSession session) {

        HashMap<String, Object> result = new HashMap<>();

        // 관리자 권한 확인
        if (!"ADMIN".equals(session.getAttribute("sessionRole"))) {
            result.put("result", "fail");
            result.put("message", "관리자만 답변을 등록할 수 있습니다.");
            return new Gson().toJson(result);
        }

        // 답변 작성 관리자 ID 설정
        map.put("answeredBy", session.getAttribute("sessionId"));

        result = productInqService.addProductInqAnswer(map);

        return new Gson().toJson(result);
    }

    // 상품 문의 수정
    @RequestMapping(value = "/productInq/edit.dox")
    @ResponseBody
    public String productInqEdit(
            @RequestParam HashMap<String, Object> map,
            HttpSession session) {

        HashMap<String, Object> result = new HashMap<>();

        // 로그인 여부 확인
        if (session.getAttribute("sessionId") == null) {
            result.put("result", "fail");
            result.put("message", "로그인 후 이용할 수 있습니다.");
            return new Gson().toJson(result);
        }

        // 작성자 ID는 세션에서 설정
        map.put("memberId", session.getAttribute("sessionId"));

        result = productInqService.editProductInq(map);

        return new Gson().toJson(result);
    }

    // 상품 문의 삭제
    @RequestMapping(value = "/productInq/remove.dox")
    @ResponseBody
    public String productInqRemove(
            @RequestParam HashMap<String, Object> map,
            HttpSession session) {

        HashMap<String, Object> result = new HashMap<>();

        // 로그인 여부 확인
        if (session.getAttribute("sessionId") == null) {
            result.put("result", "fail");
            result.put("message", "로그인 후 이용할 수 있습니다.");
            return new Gson().toJson(result);
        }

        // 작성자 ID는 세션에서 설정
        map.put("memberId", session.getAttribute("sessionId"));

        result = productInqService.removeProductInq(map);

        return new Gson().toJson(result);
    }

    // 상품 문의 답변 수정
    @RequestMapping(value = "/productInq/answerEdit.dox")
    @ResponseBody
    public String productInqAnswerEdit(
            @RequestParam HashMap<String, Object> map,
            HttpSession session) {

        HashMap<String, Object> result = new HashMap<>();

        if (!"ADMIN".equals(session.getAttribute("sessionRole"))) {
            result.put("result", "fail");
            result.put("message", "관리자만 답변을 수정할 수 있습니다.");
            return new Gson().toJson(result);
        }

        result = productInqService.editProductInqAnswer(map);

        return new Gson().toJson(result);
    }

    // 상품 문의 답변 삭제
    @RequestMapping(value = "/productInq/answerRemove.dox")
    @ResponseBody
    public String productInqAnswerRemove(
            @RequestParam HashMap<String, Object> map,
            HttpSession session) {

        HashMap<String, Object> result = new HashMap<>();

        if (!"ADMIN".equals(session.getAttribute("sessionRole"))) {
            result.put("result", "fail");
            result.put("message", "관리자만 답변을 삭제할 수 있습니다.");
            return new Gson().toJson(result);
        }

        result = productInqService.removeProductInqAnswer(map);

        return new Gson().toJson(result);
    }
}
