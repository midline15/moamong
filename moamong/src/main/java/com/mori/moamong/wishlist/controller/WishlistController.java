package com.mori.moamong.wishlist.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.mori.moamong.wishlist.service.WishlistService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class WishlistController {

    private final WishlistService wishlistService;

    // 1. 찜 목록 화면 이동 (비로그인 시 로그인 페이지로 리다이렉트)
    @RequestMapping(value = "/wishlist/list.do")
    public String wishlist(HttpSession session) {
        if (session.getAttribute("sessionId") == null) {
            return "redirect:/member/login.do";
        }
        return "wishlist/wishlist";
    }

    // 2. 내 찜 목록 JSON 조회
    @RequestMapping(value = "/wishlist/list.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> wishlistData(HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null)
            return unauthorizedMap();
        return wishlistService.getWishlist(memberId);
    }

    // 3. 찜하기 토글 (상품/패키지 상세 및 목록에서 하트 클릭 시 호출)
    @RequestMapping(value = "/wishlist/toggle.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> toggleWishlist(@RequestParam(value = "productId", required = false) Long productId,
            @RequestParam(value = "packageId", required = false) Long packageId, HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null)
            return unauthorizedMap();
        return wishlistService.toggleWishlist(memberId, productId, packageId);
    }

    // 4. 개별 찜 삭제
    @RequestMapping(value = "/wishlist/remove.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> removeWishlist(@RequestParam("wishlistId") Long wishlistId, HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null)
            return unauthorizedMap();
        HashMap<String, Object> res = new HashMap<>();
        int cnt = wishlistService.removeWishlist(memberId, wishlistId);
        res.put("result", cnt > 0 ? "success" : "fail");
        return res;
    }

    // 5. 선택 찜 일괄 삭제 (콤마 구분 문자열 예: "1,2,3")
    @RequestMapping(value = "/wishlist/removeSelected.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> removeSelected(@RequestParam("wishlistIds") String idsStr, HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null)
            return unauthorizedMap();
        List<Long> ids = parseIdList(idsStr);
        int cnt = wishlistService.removeSelectedWishlists(memberId, ids);
        HashMap<String, Object> res = new HashMap<>();
        res.put("result", cnt > 0 ? "success" : "fail");
        return res;
    }

    // 6. 찜 목록 전체 비우기
    @RequestMapping(value = "/wishlist/deleteAll.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> deleteAll(HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null)
            return unauthorizedMap();
        wishlistService.deleteAllWishlists(memberId);
        HashMap<String, Object> res = new HashMap<>();
        res.put("result", "success");
        return res;
    }

    // 7. [공통] 세션에서 로그인 회원 고유번호(memberId) 추출
    private Long getSessionMemberId(HttpSession session) {
        Object idObj = session.getAttribute("sessionId");
        return idObj == null ? null : Long.parseLong(String.valueOf(idObj));
    }

    // 8. [공통] 비로그인 AJAX 요청 시 반환할 실패 응답 생성
    private HashMap<String, Object> unauthorizedMap() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("result", "fail");
        map.put("message", "로그인이 필요합니다.");
        return map;
    }

    // 9. [공통] 콤마(,)로 구분된 ID 문자열을 Long 리스트로 변환
    private List<Long> parseIdList(String csv) {
        List<Long> list = new ArrayList<>();
        if (csv == null || csv.trim().isEmpty())
            return list;
        for (String token : csv.split(",")) {
            if (!token.trim().isEmpty())
                list.add(Long.parseLong(token.trim()));
        }
        return list;
    }

    ////////////////////////////////////////////////////////
    // 찜 여부 조회
    @RequestMapping(value = "/wishlist/check.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String checkWishlist(@RequestParam HashMap<String, Object> map, HttpSession session) {

        Long memberId = getSessionMemberId(session);

        if (memberId == null) {
            return new Gson().toJson(unauthorizedMap());
        }

        HashMap<String, Object> resultMap = wishlistService.getWishlistStatus(memberId, map);

        return new Gson().toJson(resultMap);
    }
}
