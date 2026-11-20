package com.mori.moamong.cart.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.mori.moamong.cart.service.CartService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

/**
 * 장바구니 컨트롤러
 * - .do  : 장바구니 JSP 화면으로 이동
 * - .dox : AJAX 비동기 요청을 받아 JSON(HashMap)으로 응답
 */
@RequiredArgsConstructor
@Controller
public class CartController {

    private final CartService cartService;

    // 1. 장바구니 화면 이동 (비로그인 사용자는 로그인 페이지로 리다이렉트)
    @RequestMapping(value = "/cart/list.do")
    public String cart(HttpSession session) {
        if (session.getAttribute("sessionId") == null) {
            return "redirect:/member/login.do";
        }
        return "cart/cart";
    }

    // 2. 내 장바구니 목록 및 총 결제 예정 금액 조회
    @RequestMapping(value = "/cart/list.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> cartList(HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) {
            return unauthorizedMap();
        }
        return cartService.getCartListWithSummary(memberId);
    }

    // 3-1. 장바구니 담기 (단품 전용 - 일반 form 파라미터 방식)
    @RequestMapping(value = "/cart/add.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> addCart(@RequestParam HashMap<String, Object> map, HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) {
            return unauthorizedMap();
        }
        return cartService.addCart(memberId, map);
    }

    // 3-2. 장바구니 담기 (패키지+옵션 배열 포함 JSON 방식)
    @RequestMapping(value = "/cart/add-json.dox", method = RequestMethod.POST, consumes = "application/json")
    @ResponseBody
    public HashMap<String, Object> addCartJson(@RequestBody Map<String, Object> payload, HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) {
            return unauthorizedMap();
        }
        return cartService.addCart(memberId, payload);
    }

    // 4. 장바구니 특정 항목 수량 변경
    @RequestMapping(value = "/cart/update.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> updateCart(@RequestParam("cartItemId") Long cartItemId,
                                              @RequestParam("quantity") int quantity,
                                              HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) {
            return unauthorizedMap();
        }
        return cartService.updateCart(memberId, cartItemId, quantity);
    }

    // 5. 장바구니 개별 항목 1건 삭제
    @RequestMapping(value = "/cart/remove.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> removeCart(@RequestParam("cartItemId") Long cartItemId, HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) {
            return unauthorizedMap();
        }
        HashMap<String, Object> resultMap = new HashMap<>();
        int cnt = cartService.removeCart(memberId, cartItemId);
        resultMap.put("result", cnt > 0 ? "success" : "fail");
        return resultMap;
    }

    // 6. 체크박스로 선택한 여러 항목 일괄 삭제 (예: cartItemIds = "1,3,5")
    @RequestMapping(value = "/cart/removeSelected.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> removeSelectedCart(@RequestParam("cartItemIds") String cartItemIdsStr,
                                                      HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) {
            return unauthorizedMap();
        }
        List<Long> ids = parseIdList(cartItemIdsStr);
        int cnt = cartService.removeSelectedCartItems(memberId, ids);

        HashMap<String, Object> resultMap = new HashMap<>();
        resultMap.put("result", cnt > 0 ? "success" : "fail");
        resultMap.put("deletedCount", cnt);
        return resultMap;
    }

    // 7. 내 장바구니 전체 비우기
    @RequestMapping(value = "/cart/deleteAll.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> deleteAllCartItems(HttpSession session) {
        Long memberId = getSessionMemberId(session);
        if (memberId == null) {
            return unauthorizedMap();
        }
        HashMap<String, Object> resultMap = new HashMap<>();
        cartService.deleteAllCartItems(memberId);
        resultMap.put("result", "success");
        return resultMap;
    }

    // [공통] 세션에서 로그인 회원 고유번호(memberId) 추출
    private Long getSessionMemberId(HttpSession session) {
        Object idObj = session.getAttribute("sessionId");
        if (idObj == null) return null;
        return Long.parseLong(String.valueOf(idObj));
    }

    // [공통] 비로그인 AJAX 호출 시 반환할 실패 응답
    private HashMap<String, Object> unauthorizedMap() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("result", "fail");
        map.put("message", "로그인이 필요합니다.");
        return map;
    }

    // [공통] "1,2,3" 형태의 콤마 문자열을 List<Long>으로 변환
    private List<Long> parseIdList(String csv) {
        List<Long> list = new ArrayList<>();
        if (csv == null || csv.trim().isEmpty()) return list;
        for (String token : csv.split(",")) {
            String trimmed = token.trim();
            if (!trimmed.isEmpty()) {
                list.add(Long.parseLong(trimmed));
            }
        }
        return list;
    }
}
