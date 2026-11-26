package com.mori.moamong.community.controller;

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
import com.mori.moamong.community.service.CommunityService;

@RequiredArgsConstructor
@Controller
public class CommunityController {
    private final CommunityService communityService;

    // 개발용 가짜 로그인 (false 로 유지, 실제 로그인 세션을 사용)
    private static final boolean DEV_MODE = false;
    private static final long DEV_MEMBER_ID = 1L;

    // 최근 7일 구매 상품 (로그인 필요, 회원번호는 세션에서)
    @RequestMapping(value = "/community/buy-list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String buyList(Model model, HttpSession session) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        long memberId = getMemberId(session);
        if (memberId == 0) {
            resultMap.put("result", "fail");
            resultMap.put("msg", "로그인이 필요합니다.");
            return new Gson().toJson(resultMap);
        }
        resultMap = communityService.getBuyList(memberId);

        return new Gson().toJson(resultMap);
    }

    // 로그인한 회원 번호 (로그아웃 상태면 0) - 로그인 시 세션에 "sessionId" 로 저장됨
    private long getMemberId(HttpSession session) {
        if (DEV_MODE)
            return DEV_MEMBER_ID;
        Object id = session.getAttribute("sessionId");
        if (id == null)
            return 0L;
        try {
            return Long.parseLong(String.valueOf(id));
        } catch (NumberFormatException e) {
            return 0L;
        }
    }

    // 관리자 여부 (회원의 role 이 ADMIN 인지 DB에서 확인)
    private boolean isAdmin(long memberId) {
        if (memberId == 0)
            return false;
        return communityService.isAdmin(memberId);
    }

    // 커뮤니티 목록 페이지
    @RequestMapping("/community/list.do")
    public String list(Model model, HttpSession session) throws Exception {
        long memberId = getMemberId(session);
        model.addAttribute("memberId", memberId);
        model.addAttribute("isLogin", memberId > 0);
        model.addAttribute("isAdmin", isAdmin(memberId));
        return "/community/list";
    }

    // 게시글 목록 조회 (페이지 번호 방식)
    @RequestMapping(value = "/community/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String list(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        // 화면에서 보낸 값은 믿지 않고 서버에서 다시 지정
        map.put("memberId", getMemberId(session));
        resultMap = communityService.getPostList(map);

        return new Gson().toJson(resultMap);
    }

    // 게시글 등록 (로그인 필요)
    @RequestMapping(value = "/community/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String add(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        long memberId = getMemberId(session);
        if (memberId == 0) {
            resultMap.put("result", "fail");
            resultMap.put("msg", "로그인이 필요합니다.");
            return new Gson().toJson(resultMap);
        }
        map.put("memberId", memberId);
        resultMap = communityService.addPost(map);

        return new Gson().toJson(resultMap);
    }

    // 게시글 삭제 (본인 글 또는 관리자)
    @RequestMapping(value = "/community/delete.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String delete(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        long memberId = getMemberId(session);
        if (memberId == 0) {
            resultMap.put("result", "fail");
            resultMap.put("msg", "로그인이 필요합니다.");
            return new Gson().toJson(resultMap);
        }
        map.put("memberId", memberId);
        map.put("isAdmin", isAdmin(memberId) ? "Y" : "N"); // 서버에서 다시 지정
        resultMap = communityService.removePost(map);

        return new Gson().toJson(resultMap);
    }

    // 좋아요 토글 (로그인 필요)
    @RequestMapping(value = "/community/like.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String like(Model model, HttpSession session, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        long memberId = getMemberId(session);
        if (memberId == 0) {
            resultMap.put("result", "fail");
            resultMap.put("msg", "로그인이 필요합니다.");
            return new Gson().toJson(resultMap);
        }
        map.put("memberId", memberId);
        resultMap = communityService.toggleLike(map);

        return new Gson().toJson(resultMap);
    }

    // 댓글 목록 조회 (글 하나의 댓글 전체)
    @RequestMapping(value = "/community/comment-list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String commentList(Model model, HttpSession session, @RequestParam HashMap<String, Object> map)
            throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        resultMap = communityService.getCommentList(map);

        return new Gson().toJson(resultMap);
    }

    // 댓글 등록 (로그인 필요)
    @RequestMapping(value = "/community/comment-add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String commentAdd(Model model, HttpSession session, @RequestParam HashMap<String, Object> map)
            throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        long memberId = getMemberId(session);
        if (memberId == 0) {
            resultMap.put("result", "fail");
            resultMap.put("msg", "로그인이 필요합니다.");
            return new Gson().toJson(resultMap);
        }
        map.put("memberId", memberId);
        resultMap = communityService.addComment(map);

        return new Gson().toJson(resultMap);
    }

    // 댓글 삭제 (본인 댓글 또는 관리자)
    @RequestMapping(value = "/community/comment-delete.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String commentDelete(Model model, HttpSession session, @RequestParam HashMap<String, Object> map)
            throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        long memberId = getMemberId(session);
        if (memberId == 0) {
            resultMap.put("result", "fail");
            resultMap.put("msg", "로그인이 필요합니다.");
            return new Gson().toJson(resultMap);
        }
        map.put("memberId", memberId);
        map.put("isAdmin", isAdmin(memberId) ? "Y" : "N"); // 서버에서 다시 지정
        resultMap = communityService.removeComment(map);

        return new Gson().toJson(resultMap);
    }
}