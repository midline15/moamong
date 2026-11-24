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

/**
 * 주문 컨트롤러 - .do : 주문서(checkout.jsp) 및 주문내역(orderList.jsp) 화면 이동 - .dox : AJAX
 * 비동기 요청을 받아 JSON(HashMap)으로 응답
 */
@RequiredArgsConstructor
@Controller
public class OrderController {
	@org.springframework.beans.factory.annotation.Value("${portone.imp.code}")
	private String impCode;
	private final OrderService orderService;

	// 1. 주문서 페이지 이동 (/order/checkout.do?cartItemIds=1,2,3)
	@RequestMapping(value = "/order/checkout.do")
	public String checkoutPage(@RequestParam(value = "cartItemIds", required = false) String cartItemIds,
			HttpSession session, Model model) {
		if (session.getAttribute("sessionId") == null) {
			return "redirect:/member/login.do";
		}
		if (cartItemIds == null || cartItemIds.trim().isEmpty()) {
			return "redirect:/cart/list.do";
		}
		model.addAttribute("cartItemIds", cartItemIds);
		model.addAttribute("impCode", impCode);
		return "order/checkout";
	}

	// 2. 주문서 초기 데이터 조회 (선택 상품 + 기본 배송지 + 금액 계산)
	@RequestMapping(value = "/order/checkout.dox", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String, Object> checkoutData(@RequestParam("cartItemIds") String cartItemIdsStr,
			HttpSession session) {
		Long memberId = getMemberId(session);
		if (memberId == null)
			return noLoginMap();

		List<Long> ids = parseIdList(cartItemIdsStr);
		return orderService.getCheckoutData(memberId, ids);
	}

	// 3. 주문 생성 (스냅샷 저장 + 재고 차감 + 장바구니 비우기)
	@RequestMapping(value = "/order/create.dox", method = RequestMethod.POST, consumes = "application/json")
	@ResponseBody
	public HashMap<String, Object> createOrder(@RequestBody Map<String, Object> payload, HttpSession session) {
		Long memberId = getMemberId(session);
		if (memberId == null)
			return noLoginMap();

		try {
			return orderService.createOrder(memberId, payload);
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
}
