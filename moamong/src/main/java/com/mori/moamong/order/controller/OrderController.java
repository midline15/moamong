package com.mori.moamong.order.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.mori.moamong.order.service.OrderService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;

/**
 * 주문 컨트롤러 - .do : 주문서(checkout.jsp) 및 주문내역(orderList.jsp) 화면 이동 - .dox : AJAX
 * 비동기 요청을 받아 JSON(HashMap)으로 응답
 */
@RequiredArgsConstructor
@Controller
public class OrderController {
    @Value("${portone.imp.code}")
    private String impCode;

    @Value("${portone.channel.key:}")
    private String channelKey;

    private final OrderService orderService;

    // 1. 주문서 페이지 이동
    @RequestMapping(value = "/order/checkout.do")
    public String checkoutPage(
            @RequestParam(value = "cartItemIds", required = false) String cartItemIds,
            HttpSession session, Model model) {

        if (session.getAttribute("sessionId") == null) {
            return "redirect:/member/login.do";
        }

        // 바로 구매가 아닌 경우 장바구니 구매로 처리
        if (cartItemIds != null && !cartItemIds.trim().isEmpty()) {
            model.addAttribute("purchaseType", "CART");
            model.addAttribute("cartItemIds", cartItemIds);
        } else {
            // 바로 구매 데이터 확인
            Object directPurchase = session.getAttribute("directPurchase");

            if (directPurchase == null) {
                return "redirect:/cart/list.do";
            }

            model.addAttribute("purchaseType", "DIRECT");
        }

        model.addAttribute("impCode", impCode != null ? impCode.trim() : "");
        model.addAttribute("channelKey", channelKey != null ? channelKey.trim() : "");
        return "order/checkout";
    }

    // 2. 주문서 초기 데이터 조회 (선택 상품 + 기본 배송지 + 금액 계산)
    @RequestMapping(value = "/order/checkout.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> checkoutData(
            @RequestParam(value = "cartItemIds", required = false) String cartItemIdsStr,
            HttpSession session) {

        Long memberId = getMemberId(session);

        if (memberId == null) {
            return noLoginMap();
        }

        // 장바구니 구매
        if (cartItemIdsStr != null && !cartItemIdsStr.trim().isEmpty()) {
            List<Long> ids = parseIdList(cartItemIdsStr);
            return orderService.getCheckoutData(memberId, ids);
        }

        // 바로 구매
        Object directPurchase = session.getAttribute("directPurchase");

        if (directPurchase == null) {
            HashMap<String, Object> result = new HashMap<>();
            result.put("result", "fail");
            result.put("message", "바로 구매 정보가 없습니다.");
            return result;
        }

        return orderService.getDirectCheckoutData(
                memberId, (Map<String, Object>) directPurchase);
    }

    // 3. 주문 생성 (스냅샷 저장 + 재고 차감 + 장바구니 비우기)
    // 주문 생성
    @RequestMapping(value = "/order/create.dox", method = RequestMethod.POST, consumes = "application/json")
    @ResponseBody
    public HashMap<String, Object> createOrder(
            @RequestBody Map<String, Object> payload, HttpSession session) {

        Long memberId = getMemberId(session);

        if (memberId == null) {
            return noLoginMap();
        }

        try {
        	Object directPurchase = session.getAttribute("directPurchase");
            if (directPurchase != null) {
                payload.put("directPurchase", directPurchase);
            }
        	
        	
            HashMap<String, Object> result = orderService.createOrder(memberId, payload);

            // 주문 성공 시 바로 구매 세션 정보 삭제
            if ("success".equals(result.get("result"))) {
                session.removeAttribute("directPurchase");
            }

            return result;

        } catch (IllegalStateException e) {
            HashMap<String, Object> fail = new HashMap<>();
            fail.put("result", "fail");
            fail.put("message", e.getMessage());
            return fail;
        }
    }

    // 4. 주문 내역 페이지 이동 (/order/list.do)
    @RequestMapping(value = "/order/list.do")
    public String orderListPage(HttpSession session) {
        if (session.getAttribute("sessionId") == null) {
            return "redirect:/member/login.do";
        }
        return "order/orderList";
    }

    // 5. 내 주문 내역 목록 조회 (.dox)
    @RequestMapping(value = "/order/list.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> orderList(HttpSession session) {
        Long memberId = getMemberId(session);
        if (memberId == null)
            return noLoginMap();

        return orderService.getOrderList(memberId);
    }

    // 5-1. 주문 상세 페이지 이동 (/order/detail.do?orderId=1)
    @RequestMapping(value = "/order/detail.do")
    public String orderDetailPage(@RequestParam(value = "orderId", required = false) Long orderId, HttpSession session,
            Model model) {
        if (session.getAttribute("sessionId") == null) {
            return "redirect:/member/login.do";
        }
        if (orderId == null) {
            return "redirect:/order/list.do";
        }
        model.addAttribute("orderId", orderId);
        return "order/orderDetail";
    }

    // 5-2. 주문 상세 단건 데이터 조회 (.dox)
    @RequestMapping(value = "/order/detail.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> orderDetail(@RequestParam("orderId") Long orderId, HttpSession session) {
        Long memberId = getMemberId(session);
        if (memberId == null)
            return noLoginMap();

        return orderService.getOrderDetail(memberId, orderId);
    }

    // 6. 주문 취소 처리 (.dox)
    @RequestMapping(value = "/order/cancel.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> cancelOrder(@RequestParam("orderId") Long orderId,
            @RequestParam(value = "cancelReason", required = false) String cancelReason, HttpSession session) {
        Long memberId = getMemberId(session);
        if (memberId == null)
            return noLoginMap();

        return orderService.cancelOrder(memberId, orderId, cancelReason);
    }

    // [공통] 세션에서 로그인 회원 번호 추출
    private Long getMemberId(HttpSession session) {
        Object idObj = session.getAttribute("sessionId");
        return idObj == null ? null : Long.parseLong(String.valueOf(idObj));
    }

    // [공통] 비로그인 요청 시 실패 응답
    private HashMap<String, Object> noLoginMap() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("result", "fail");
        map.put("message", "로그인이 필요합니다.");
        return map;
    }

    // [공통] "1,2,3" 콤마 문자열을 List<Long>으로 변환
    private List<Long> parseIdList(String csv) {
        List<Long> list = new ArrayList<>();
        if (csv == null || csv.trim().isEmpty())
            return list;
        for (String token : csv.split(",")) {
            String trimmed = token.trim();
            if (!trimmed.isEmpty()) {
                list.add(Long.parseLong(trimmed));
            }
        }
        return list;
    }

    // 7. 사용자 전용 취소/환불 내역 페이지 이동 (/order/cancel-list.do)
    @RequestMapping(value = "/order/cancel-list.do")
    public String cancelListPage(HttpSession session) {
        if (session.getAttribute("sessionId") == null) {
            return "redirect:/member/login.do";
        }
        return "order/cancelList";
    }

    // 8. 취소/환불 통합 내역 목록 조회 (.dox)
    @RequestMapping(value = "/order/cancel-list.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> cancelList(HttpSession session) {
        Long memberId = getMemberId(session);
        return memberId == null ? noLoginMap() : orderService.getCancelRefundList(memberId);
    }

    // 9. 취소/환불 단건 상세 내역 조회 (.dox)
    @RequestMapping(value = "/order/cancel-detail.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> cancelDetail(@RequestParam("claimType") String claimType,
            @RequestParam("claimId") Long claimId, @RequestParam("orderId") Long orderId, HttpSession session) {
        Long memberId = getMemberId(session);
        return memberId == null ? noLoginMap()
                : orderService.getCancelRefundDetail(memberId, claimType, claimId, orderId);
    }

    // 10. 반품/환불 신청 (+ 임시 관리자 자동 승인 처리) (.dox)
    @RequestMapping(value = "/order/return-request.dox", method = RequestMethod.POST, consumes = "application/json")
    @ResponseBody
    public HashMap<String, Object> requestReturn(@RequestBody Map<String, Object> payload, HttpSession session) {
        Long memberId = getMemberId(session);
        return memberId == null ? noLoginMap() : orderService.requestReturnAndRefund(memberId, payload);
    }

    // 바로구매
    // 세션에 구매할 단품 정보 저장
    @RequestMapping(value = "/order/direct-buy.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> directBuy(
            @RequestParam HashMap<String, Object> map,
            HttpSession session) {

        Long memberId = getMemberId(session);

        if (memberId == null) {
            return noLoginMap();
        }

        HashMap<String, Object> result = new HashMap<>();

        try {
            map.put("itemType", "PRODUCT");
            session.setAttribute("directPurchase", map);

            result.put("result", "success");
            result.put("message", "주문서로 이동합니다.");

        } catch (Exception e) {
            e.printStackTrace();

            result.put("result", "fail");
            result.put("message", "바로 구매 요청에 실패했습니다.");
        }

        return result;
    }

    // 패키지 바로 구매 정보 세션 저장
    @RequestMapping(value = "/order/direct-buy-json.dox", method = RequestMethod.POST, consumes = "application/json")
    @ResponseBody
    public HashMap<String, Object> directBuyJson(
            @RequestBody Map<String, Object> payload,
            HttpSession session) {

        Long memberId = getMemberId(session);

        if (memberId == null) {
            return noLoginMap();
        }

        HashMap<String, Object> result = new HashMap<>();

        try {
            payload.put("itemType", "PACKAGE");
            session.setAttribute("directPurchase", payload);

            result.put("result", "success");
            result.put("message", "주문서로 이동합니다.");

        } catch (Exception e) {
            e.printStackTrace();

            result.put("result", "fail");
            result.put("message", "바로 구매 요청에 실패했습니다.");
        }

        return result;
    }

    // 바로 구매 취소
    @RequestMapping(value = "/order/cancel-direct.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> cancelDirectBuy(HttpSession session) {

        HashMap<String, Object> result = new HashMap<>();

        session.removeAttribute("directPurchase");

        result.put("result", "success");
        result.put("message", "바로 구매가 취소되었습니다.");

        return result;
    }

    // ==================== 관리자 전체 주문 목록 조회 ====================
    @RequestMapping(value = "/admin/order/list.dox", method = RequestMethod.POST)
    @ResponseBody
    public HashMap<String, Object> adminOrderList(
            @RequestParam HashMap<String, Object> map,
            HttpSession session) {

        HashMap<String, Object> result = new HashMap<>();

        try {
            // 관리자 권한 확인
            if (!"ADMIN".equals(session.getAttribute("sessionRole"))) {
                result.put("result", "fail");
                result.put("message", "관리자 권한이 필요합니다.");
                return result;
            }

            result = orderService.getAdminOrderList(map);

        } catch (Exception e) {
            e.printStackTrace();
            result.put("result", "fail");
            result.put("message", "관리자 주문 목록 조회 중 오류가 발생했습니다.");
        }

        return result;
    }
}
