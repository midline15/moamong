package com.mori.moamong.order.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mori.moamong.member.mapper.AddressMapper;
import com.mori.moamong.notification.service.NotificationService;
import com.mori.moamong.order.mapper.OrderMapper;
import com.mori.moamong.payment.service.PaymentService;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class OrderService {

	private final OrderMapper orderMapper;
	private final AddressMapper addressMapper;
	private final PaymentService paymentService;
	private final NotificationService notificationService;

	private static final int FREE_SHIPPING_MIN = 30000;
	private static final int BASIC_SHIPPING_FEE = 3000;

	// ==================== 1. 주문서(Checkout) 초기 데이터 조회 ====================
	public HashMap<String, Object> getCheckoutData(Long memberId, List<Long> cartItemIds) {
		HashMap<String, Object> res = new HashMap<>();

		if (cartItemIds == null || cartItemIds.isEmpty()) {
			res.put("result", "fail");
			res.put("message", "주문할 상품이 선택되지 않았습니다.");
			return res;
		}

		List<HashMap<String, Object>> items = orderMapper.selectCheckoutCartItems(memberId, cartItemIds);
		if (items.isEmpty() || items.size() != cartItemIds.size()) {
			res.put("result", "fail");
			res.put("message", "유효하지 않거나 이미 삭제된 상품이 포함되어 있습니다.");
			return res;
		}
		int productTotal = 0;
		int optionTotal = 0;
		for (HashMap<String, Object> item : items) {
			String type = String.valueOf(item.get("itemType"));
			String status = String.valueOf(item.get("itemStatus"));
			int basePrice = toInt(item.get("basePrice"));
			int qty = toInt(item.get("quantity"));
			int extraPricePerOne = 0;

			if (!"SELLING".equals(status)) {
				res.put("result", "fail");
				res.put("message", "[" + item.get("itemName") + "] 상품은 현재 판매 중이 아닙니다.");
				return res;
			}

			if ("PRODUCT".equals(type)) {
				int stock = toInt(item.get("stockQuantity"));
				if (stock < qty) {
					res.put("result", "fail");
					res.put("message", "[" + item.get("itemName") + "] 재고가 부족합니다. (현재 재고: " + stock + "개)");
					return res;
				}
				item.put("packageItems", List.of());
				item.put("packageExtras", List.of());
			} else {
				Long cartItemId = toLong(item.get("cartItemId"));
				List<HashMap<String, Object>> pkgItems = orderMapper.selectCheckoutPackageItems(cartItemId);

				for (HashMap<String, Object> pi : pkgItems) {
					extraPricePerOne += toInt(pi.get("additionalPrice"));
					int needQty = toInt(pi.get("itemQuantity")) * qty;
					int subStock = toInt(pi.get("selectedProductStock"));
					String subStatus = String.valueOf(pi.get("selectedProductStatus"));

					if (!"SELLING".equals(subStatus) || subStock < needQty) {
						res.put("result", "fail");
						res.put("message", "[" + item.get("itemName") + "] 구성 상품 중 품절 또는 재고 부족 상품이 있습니다.");
						return res;
					}
				}

				List<HashMap<String, Object>> pkgExtras = orderMapper.selectCheckoutPackageExtras(cartItemId);
				for (HashMap<String, Object> pe : pkgExtras) {
					extraPricePerOne += toInt(pe.get("additionalPrice"));
					pe.put("optionValue", "");
				}
				item.put("packageItems", pkgItems);
				item.put("packageExtras", pkgExtras);
			}
			int unitPrice = basePrice + extraPricePerOne;
			int lineAmount = unitPrice * qty;
			item.put("unitPrice", unitPrice);
			item.put("lineAmount", lineAmount);

			productTotal += (basePrice * qty);
			optionTotal += (extraPricePerOne * qty);
		}
		int sumAmount = productTotal + optionTotal;
		int shippingFee = sumAmount >= FREE_SHIPPING_MIN ? 0 : BASIC_SHIPPING_FEE;
		int finalAmount = sumAmount + shippingFee;

		HashMap<String, Object> defaultAddr = addressMapper.selectDefaultAddress(memberId);
		List<HashMap<String, Object>> addrList = addressMapper.selectAddressList(memberId);

		res.put("result", "success");
		res.put("items", items);
		res.put("defaultAddress", defaultAddr);
		res.put("addressList", addrList);
		res.put("totalProductAmount", productTotal);
		res.put("totalAdditionalAmount", optionTotal);
		res.put("shippingFee", shippingFee);
		res.put("finalAmount", finalAmount);
		return res;
	}

	// ==================== 2. 주문 생성 (PG 검증 + 스냅샷 + 재고 차감) ====================
	@Transactional
	public HashMap<String, Object> createOrder(Long memberId, Map<String, Object> payload) {
		HashMap<String, Object> res = new HashMap<>();

		List<Long> cartItemIds = parseLongList(payload.get("cartItemIds"));
		String name = toStr(payload.get("recipientName"));
		String phone = toStr(payload.get("recipientPhone"));
		String zip = toStr(payload.get("postalCode"));
		String addr1 = toStr(payload.get("addressDefault"));
		String addr2 = toStr(payload.get("addressDetail"));
		String impUid = toStr(payload.get("impUid"));
		String payMethod = toStr(payload.get("payMethod"));

		@SuppressWarnings("unchecked")
		Map<String, Object> directPurchase = (Map<String, Object>) payload.get("directPurchase");
		boolean isDirect = (directPurchase != null && (cartItemIds.isEmpty() || cartItemIds.contains(-1L)));

		if (cartItemIds.isEmpty() && !isDirect) {

			res.put("result", "fail");
			res.put("message", "주문할 상품이 없습니다.");
			return res;
		}
		if (name.isEmpty() || phone.isEmpty() || zip.isEmpty() || addr1.isEmpty()) {
			res.put("result", "fail");
			res.put("message", "배송지 필수 정보를 모두 입력해주세요.");
			return res;
		}
		Map<String, Object> extraValues = toMap(payload.get("extraValues"));
		HashMap<String, Object> check = isDirect
				? getDirectCheckoutData(memberId, directPurchase)
				: getCheckoutData(memberId, cartItemIds);
		if (!"success".equals(check.get("result"))) {
			if (!impUid.isEmpty()) {
				paymentService.cancelPortOnePayment(impUid, "주문 검증 실패 자동취소");
			}
			return check;
		}
		@SuppressWarnings("unchecked")
		List<HashMap<String, Object>> items = (List<HashMap<String, Object>>) check.get("items");
		long finalAmount = toInt(check.get("finalAmount"));

		String orderNumber = makeOrderNumber();
		HashMap<String, Object> orderMap = new HashMap<>();
		orderMap.put("memberId", memberId);
		orderMap.put("orderNumber", orderNumber);
		orderMap.put("recipientName", name);
		orderMap.put("recipientPhone", phone);
		orderMap.put("postalCode", zip);
		orderMap.put("addressDefault", addr1);
		orderMap.put("addressDetail", addr2);
		orderMap.put("totalProductAmount", toInt(check.get("totalProductAmount")));
		orderMap.put("totalAdditionalAmount", toInt(check.get("totalAdditionalAmount")));
		orderMap.put("discountAmount", 0);
		orderMap.put("usedPoint", 0);
		orderMap.put("shippingFee", toInt(check.get("shippingFee")));
		orderMap.put("finalAmount", finalAmount);
		orderMap.put("orderStatus", "PAID");

		try {
			orderMapper.insertOrder(orderMap);
			Long orderId = toLong(orderMap.get("orderId"));

			// [테스트결제용] PG 검증 금액 1원 고정 (원복 시 아래 1줄 삭제)
			long testPayAmount = 1L;
			if (!impUid.isEmpty()) {
				// [테스트결제용] 원복 시 testPayAmount -> finalAmount 로 변경
				paymentService.verifyAndSavePayment(orderId, impUid, payMethod, testPayAmount);
			}

			for (HashMap<String, Object> item : items) {
				String type = String.valueOf(item.get("itemType"));
				Long productId = toLong(item.get("productId"));
				Long packageId = toLong(item.get("packageId"));
				int qty = toInt(item.get("quantity"));

				HashMap<String, Object> itemMap = new HashMap<>();
				itemMap.put("orderId", orderId);
				itemMap.put("productId", productId);
				itemMap.put("packageId", packageId);
				itemMap.put("itemNameSnapshot", item.get("itemName"));
				itemMap.put("unitPrice", toInt(item.get("unitPrice")));
				itemMap.put("quantity", qty);
				itemMap.put("lineAmount", toInt(item.get("lineAmount")));

				orderMapper.insertOrderItem(itemMap);
				Long orderItemId = toLong(itemMap.get("orderItemId"));
				if ("PRODUCT".equals(type)) {
					int ok = orderMapper.decreaseProductStock(productId, qty);
					if (ok == 0) {
						throw new IllegalStateException("[" + item.get("itemName") + "] 재고가 부족하여 주문을 완료할 수 없습니다.");
					}
				} else {
					@SuppressWarnings("unchecked")
					List<HashMap<String, Object>> pkgItems = (List<HashMap<String, Object>>) item.get("packageItems");
					for (HashMap<String, Object> pi : pkgItems) {
						Long subProdId = toLong(pi.get("selectedProductId"));
						int setQty = toInt(pi.get("itemQuantity"));

						HashMap<String, Object> piMap = new HashMap<>();
						piMap.put("orderItemId", orderItemId);
						piMap.put("sourcePackageItemId", toLong(pi.get("packageItemId")));
						piMap.put("productId", subProdId);
						piMap.put("productNameSnapshot", pi.get("selectedProductName"));
						piMap.put("itemRole", pi.get("itemRole"));
						piMap.put("quantity", setQty);
						piMap.put("additionalPrice", toInt(pi.get("additionalPrice")));
						orderMapper.insertOrderPackageItem(piMap);

						int ok = orderMapper.decreaseProductStock(subProdId, setQty * qty);
						if (ok == 0) {
							throw new IllegalStateException(
									"구성 상품 [" + pi.get("selectedProductName") + "]의 재고가 부족합니다.");
						}
					}

					@SuppressWarnings("unchecked")
					List<HashMap<String, Object>> pkgExtras = (List<HashMap<String, Object>>) item.get("packageExtras");
					for (HashMap<String, Object> pe : pkgExtras) {
						String extraKey = String.valueOf(pe.get("cartPackageExtraId"));
						String msg = extraValues.containsKey(extraKey) ? toStr(extraValues.get(extraKey)) : "";

						HashMap<String, Object> peMap = new HashMap<>();
						peMap.put("orderItemId", orderItemId);
						peMap.put("sourcePackageExtraOptionId", toLong(pe.get("packageExtraOptionId")));
						peMap.put("extraTypeSnapshot", pe.get("extraType"));
						peMap.put("optionNameSnapshot", pe.get("optionName"));
						peMap.put("optionValue", msg.isEmpty() ? null : msg);
						peMap.put("additionalPrice", toInt(pe.get("additionalPrice")));
						orderMapper.insertOrderPackageExtra(peMap);
					}
				}
			}

			if (!isDirect) {
				orderMapper.deleteOrderedCartItems(memberId, cartItemIds);
			}
			res.put("result", "success");
			res.put("orderId", orderId);
			res.put("orderNumber", orderNumber);
			res.put("message", "결제 및 주문이 정상적으로 완료되었습니다.");

			notificationService.sendNotification(
					memberId,
					"ORDER",
					"주문이 정상 완료되었습니다.",
					"주문번호 [" + orderNumber + "] 결제가 완료되었습니다.",
					orderId
			);

			return res;
		} catch (Exception e) {
			if (!impUid.isEmpty()) {
				paymentService.cancelPortOnePayment(impUid, "주문 처리 오류 자동취소");
			}
			throw new IllegalStateException(e.getMessage());
		}
	}


	// ==================== 3. 내 주문 내역 조회 ====================
	public HashMap<String, Object> getOrderList(Long memberId) {
		HashMap<String, Object> res = new HashMap<>();
		List<HashMap<String, Object>> orders = orderMapper.selectOrderList(memberId);
		for (HashMap<String, Object> order : orders) {
			Long orderId = toLong(order.get("orderId"));
			order.put("items", loadOrderItemsWithSnapshots(orderId));
			if ("CANCELED".equals(order.get("orderStatus"))) {
				order.put("cancelInfo", orderMapper.selectOrderCancel(orderId));
			}
		}
		res.put("result", "success");
		res.put("list", orders);
		return res;
	}

	// ==================== 3-1. 주문 상세 단건 조회 ====================
	public HashMap<String, Object> getOrderDetail(Long memberId, Long orderId) {
		HashMap<String, Object> res = new HashMap<>();
		HashMap<String, Object> order = orderMapper.selectOrderOne(orderId, memberId);
		if (order == null) {
			res.put("result", "fail");
			res.put("message", "존재하지 않거나 접근 권한이 없는 주문입니다.");
			return res;
		}
		res.put("result", "success");
		res.put("order", order);
		res.put("items", loadOrderItemsWithSnapshots(orderId));
		res.put("payment", orderMapper.selectOrderPayment(orderId));
		if ("CANCELED".equals(order.get("orderStatus"))) {
			res.put("cancelInfo", orderMapper.selectOrderCancel(orderId));
		}
		return res;
	}

	// ==================== 4. 주문 취소 (PG 결제취소 + 재고복구 + 이력기록) ====================
	@Transactional
	public HashMap<String, Object> cancelOrder(Long memberId, Long orderId, String cancelReason) {
		HashMap<String, Object> res = new HashMap<>();
		HashMap<String, Object> order = orderMapper.selectOrderOne(orderId, memberId);
		if (order == null) {
			res.put("result", "fail");
			res.put("message", "존재하지 않거나 접근 권한이 없는 주문입니다.");
			return res;
		}
		String status = String.valueOf(order.get("orderStatus"));
		if (!"PAYMENT_PENDING".equals(status) && !"PAID".equals(status)) {
			res.put("result", "fail");
			res.put("message", "현재 주문 상태(" + status + ")에서는 취소할 수 없습니다.");
			return res;
		}
		restoreStockByOrder(orderId);

		String reason = (cancelReason == null || cancelReason.trim().isEmpty()) ? "구매자 단순 변심" : cancelReason.trim();
		paymentService.cancelPaymentByOrderId(orderId, reason);
		orderMapper.updateOrderStatus(orderId, memberId, "CANCELED");

		HashMap<String, Object> cancelMap = new HashMap<>();
		cancelMap.put("orderId", orderId);
		cancelMap.put("cancelReason", reason);
		cancelMap.put("cancelStatus", "COMPLETED");
		cancelMap.put("cancelAmount", toInt(order.get("finalAmount")));
		orderMapper.insertOrderCancel(cancelMap);

		res.put("result", "success");
		res.put("message", "결제 및 주문이 취소되었으며 재고가 복구되었습니다.");
		
		notificationService.sendNotification(
				memberId,
				"RETURN",
				"주문 취소가 완료되었습니다.",
				"주문번호 [" + order.get("orderNumber") + "] 취소가 정상 처리되었습니다.",
				orderId
			);

		return res;
	}

	// ==================== 5. 사용자 전용 취소/환불 통합 내역 조회 ====================
	public HashMap<String, Object> getCancelRefundList(Long memberId) {
		HashMap<String, Object> res = new HashMap<>();
		res.put("result", "success");
		res.put("list", orderMapper.selectCancelRefundList(memberId));
		return res;
	}

	// ==================== 5-1. 취소/환불 단건 상세 내역 조회 ====================
	public HashMap<String, Object> getCancelRefundDetail(Long memberId, String claimType, Long claimId, Long orderId) {
		HashMap<String, Object> detail = getOrderDetail(memberId, orderId);
		if (!"success".equals(detail.get("result")))
			return detail;
		detail.put("claimType", claimType);
		if ("RETURN".equals(claimType)) {
			detail.put("returnInfo", orderMapper.selectReturnRefundDetail(claimId, memberId));
		} else {
			detail.put("cancelInfo", orderMapper.selectOrderCancel(orderId));
		}
		return detail;
	}

	// ==================== 5-2. 반품 및 환불 신청 (+ 임시 관리자 자동 승인 처리) ====================
	@Transactional
	public HashMap<String, Object> requestReturnAndRefund(Long memberId, Map<String, Object> payload) {
		HashMap<String, Object> res = new HashMap<>();
		Long orderId = toLong(payload.get("orderId"));
		Long productId = toLong(payload.get("productId"));
		int returnQty = Math.max(1, toInt(payload.get("returnQuantity")));
		long refundAmount = toInt(payload.get("refundAmount"));
		String reason = toStr(payload.get("returnReason")).isEmpty() ? "단순 변심" : toStr(payload.get("returnReason"));
		String content = toStr(payload.get("returnContent"));

		if (orderMapper.selectOrderOne(orderId, memberId) == null) {
			res.put("result", "fail");
			res.put("message", "유효하지 않은 주문입니다.");
			return res;
		}

		// [STEP 1] 사용자 반품/환불 신청 등록 (초기 상태: REQUESTED / WAITING)
		HashMap<String, Object> retMap = new HashMap<>();
		retMap.put("orderId", orderId);
		retMap.put("productId", productId);
		retMap.put("memberId", memberId);
		retMap.put("returnReason", reason);
		retMap.put("returnContent", content.isEmpty() ? null : content);
		retMap.put("refundAmount", refundAmount);
		retMap.put("returnQuantity", returnQty);
		orderMapper.insertReturn(retMap);
		Long returnId = toLong(retMap.get("returnId"));

		HashMap<String, Object> refMap = new HashMap<>();
		refMap.put("returnId", returnId);
		refMap.put("orderId", orderId);
		refMap.put("memberId", memberId);
		refMap.put("refundAmount", refundAmount);
		refMap.put("refundMethod", "CARD");
		refMap.put("refundReason", reason);
		orderMapper.insertRefund(refMap);

		// =========================================================================
		// [STEP 2] ⚠️ 임시 관리자 자동 승인 처리 블록 (추후 관리자 기능 분리 시 이동 대상)
		// - 현재는 관리자 승인 페이지 구현 전이므로 신청 즉시 승인(COMPLETED) 처리함
		// - 추후 분리 시: 아래 approveAdminRefund(...) 호출 1줄을 주석 처리하고,
		// AdminOrderController(/admin/refund/approve.dox)에서 approveAdminRefund를 호출할 것
		// =========================================================================
		approveAdminRefund(returnId, orderId, productId, returnQty, memberId);

		res.put("result", "success");
		res.put("message", "반품 및 환불 처리가 완료되었습니다.");
		
		notificationService.sendNotification(
				memberId, 
				"RETURN", 
				"반품 처리가 완료되었습니다.", 
				"신청하신 상품의 반품 및 환불 처리가 완료되었습니다.", 
				returnId
			);
		
		return res;
	}

	/**
	 * [관리자 승인 전용 로직] 반품/환불 최종 승인 + 재고 복구 + PG 환불 연동 추후 관리자 페이지 [환불 승인] 버튼 클릭 시 이
	 * 메서드만 단독 호출하면 됩니다.
	 */
	@Transactional
	public void approveAdminRefund(Long returnId, Long orderId, Long productId, int restoreQty, Long adminId) {
		HashMap<String, Object> approveMap = new HashMap<>();
		approveMap.put("returnId", returnId);
		approveMap.put("adminId", adminId); // 추후 실제 관리자 sessionId 전달
		approveMap.put("refundContent", "관리자 승인 완료 (시스템 자동 승인 처리)");
		orderMapper.approveReturnAndRefund(approveMap);

		if (productId != null && restoreQty > 0) {
			orderMapper.increaseProductStock(productId, restoreQty);
		}
		paymentService.cancelPaymentByOrderId(orderId, "반품 승인 환불 완료");
	}

	// [내부 공통] 주문 상품 및 패키지 스냅샷 로딩
	private List<HashMap<String, Object>> loadOrderItemsWithSnapshots(Long orderId) {
		List<HashMap<String, Object>> items = orderMapper.selectOrderItems(orderId);
		for (HashMap<String, Object> item : items) {
			Long orderItemId = toLong(item.get("orderItemId"));
			if ("PACKAGE".equals(item.get("itemType"))) {
				item.put("packageItems", orderMapper.selectOrderPackageItems(orderItemId));
				item.put("packageExtras", orderMapper.selectOrderPackageExtras(orderItemId));
			} else {
				item.put("packageItems", List.of());
				item.put("packageExtras", List.of());
			}
		}
		return items;
	}

	// [내부 공통] 주문 취소 시 단품 및 패키지 구성품 재고 복구
	private void restoreStockByOrder(Long orderId) {
		for (HashMap<String, Object> item : orderMapper.selectOrderItems(orderId)) {
			int qty = toInt(item.get("quantity"));
			if ("PRODUCT".equals(item.get("itemType"))) {
				Long productId = toLong(item.get("productId"));
				if (productId != null)
					orderMapper.increaseProductStock(productId, qty);
			} else {
				Long orderItemId = toLong(item.get("orderItemId"));
				for (HashMap<String, Object> pi : orderMapper.selectOrderPackageItems(orderItemId)) {
					Long subProdId = toLong(pi.get("productId"));
					int setQty = toInt(pi.get("quantity"));
					if (subProdId != null)
						orderMapper.increaseProductStock(subProdId, setQty * qty);
				}
			}
		}
	}

	private String makeOrderNumber() {
		return "ORD" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
				+ ThreadLocalRandom.current().nextInt(1000, 9999);
	}

	private int toInt(Object val) {
		return val == null ? 0 : Integer.parseInt(String.valueOf(val));
	}

	private Long toLong(Object val) {
		return (val == null || String.valueOf(val).trim().isEmpty()) ? null : Long.parseLong(String.valueOf(val));
	}

	private String toStr(Object val) {
		return val == null ? "" : String.valueOf(val).trim();
	}

	private List<Long> parseLongList(Object obj) {
		List<Long> list = new ArrayList<>();
		if (obj instanceof List<?> raw) {
			for (Object o : raw) {
				Long id = toLong(o);
				if (id != null)
					list.add(id);
			}
		}
		return list;
	}

	@SuppressWarnings("unchecked")
	private Map<String, Object> toMap(Object obj) {
		return obj instanceof Map<?, ?> ? (Map<String, Object>) obj : Map.of();
	}
  
  // ==================== 바로 구매 주문서 초기 데이터 조회 ====================
    public HashMap<String, Object> getDirectCheckoutData(
            Long memberId, Map<String, Object> directPurchase) {

        HashMap<String, Object> res = new HashMap<>();

        String itemType = String.valueOf(directPurchase.get("itemType"));

        // 구매 유형 확인
        if (!"PRODUCT".equals(itemType) && !"PACKAGE".equals(itemType)) {
            res.put("result", "fail");
            res.put("message", "올바르지 않은 구매 정보입니다.");
            return res;
        }

        // 구매 수량 확인
        int quantity;

        try {
            quantity = Integer.parseInt(
                    String.valueOf(directPurchase.get("quantity")));
        } catch (Exception e) {
            res.put("result", "fail");
            res.put("message", "올바르지 않은 구매 수량입니다.");
            return res;
        }

        if (quantity < 1) {
            res.put("result", "fail");
            res.put("message", "구매 수량은 1개 이상이어야 합니다.");
            return res;
        }

        // 현재는 단품 바로 구매만 처리
        if ("PRODUCT".equals(itemType)) {

            Long productId = Long.valueOf(
                    String.valueOf(directPurchase.get("productId")));

            HashMap<String, Object> item = orderMapper.selectDirectProduct(productId);

            if (item == null) {
                res.put("result", "fail");
                res.put("message", "상품 정보를 찾을 수 없습니다.");
                return res;
            }

            // 판매 상태 확인
            if (!"SELLING".equals(item.get("itemStatus"))) {
                res.put("result", "fail");
                res.put("message", "현재 구매할 수 없는 상품입니다.");
                return res;
            }

            // 재고 확인
            int stockQuantity = Integer.parseInt(
                    String.valueOf(item.get("stockQuantity")));

            if (stockQuantity < quantity) {
                res.put("result", "fail");
                res.put("message", "상품 재고가 부족합니다.");
                return res;
            }

            // 주문서에서 사용하는 데이터 형태에 맞춤
            item.put("cartItemId", -1L);
            item.put("quantity", quantity);
            item.put("packageItems", new ArrayList<>());
            item.put("packageExtras", new ArrayList<>());

            BigDecimal unitPrice = new BigDecimal(
                    String.valueOf(item.get("basePrice")));

            BigDecimal lineAmount = unitPrice.multiply(
                    BigDecimal.valueOf(quantity));

            item.put("unitPrice", unitPrice);
            item.put("lineAmount", lineAmount);

            List<HashMap<String, Object>> items = new ArrayList<>();
            items.add(item);

            // 금액 계산
            BigDecimal totalProductAmount = lineAmount;
            BigDecimal totalAdditionalAmount = BigDecimal.ZERO;

            BigDecimal shippingFee = totalProductAmount.compareTo(
                    BigDecimal.valueOf(FREE_SHIPPING_MIN)) >= 0
                            ? BigDecimal.ZERO
                            : BigDecimal.valueOf(BASIC_SHIPPING_FEE);

            BigDecimal finalAmount = totalProductAmount
                    .add(totalAdditionalAmount)
                    .add(shippingFee);

            // 주문서 데이터 반환
            res.put("result", "success");
            res.put("items", items);
            res.put("defaultAddress",
                    addressMapper.selectDefaultAddress(memberId));
            res.put("addressList",
                    addressMapper.selectAddressList(memberId));
            res.put("totalProductAmount", totalProductAmount);
            res.put("totalAdditionalAmount", totalAdditionalAmount);
            res.put("shippingFee", shippingFee);
            res.put("finalAmount", finalAmount);

            return res;
        }

        // ==================== 패키지 바로 구매 조회 ====================
        if ("PACKAGE".equals(itemType)) {

            Long packageId = Long.valueOf(
                    String.valueOf(directPurchase.get("packageId")));

            // 패키지 기본 정보 조회
            HashMap<String, Object> item = orderMapper.selectDirectPackage(packageId);

            if (item == null) {
                res.put("result", "fail");
                res.put("message", "패키지 정보를 찾을 수 없습니다.");
                return res;
            }

            // 패키지 판매 상태 확인
            if (!"SELLING".equals(item.get("itemStatus"))) {
                res.put("result", "fail");
                res.put("message", "현재 구매할 수 없는 패키지입니다.");
                return res;
            }

            BigDecimal basePrice = new BigDecimal(
                    String.valueOf(item.get("basePrice")));

            BigDecimal totalAdditionalAmount = BigDecimal.ZERO;

            List<HashMap<String, Object>> packageItems = new ArrayList<>();
            List<HashMap<String, Object>> packageExtras = new ArrayList<>();

            // 선택한 구성 상품 목록
            Object packageItemsObj = directPurchase.get("packageItems");

            if (!(packageItemsObj instanceof List<?>)) {
                res.put("result", "fail");
                res.put("message", "패키지 구성 상품 정보가 올바르지 않습니다.");
                return res;
            }

            List<?> selectedItems = (List<?>) packageItemsObj;

            for (Object obj : selectedItems) {

                if (!(obj instanceof Map<?, ?>)) {
                    res.put("result", "fail");
                    res.put("message", "구성 상품 정보가 올바르지 않습니다.");
                    return res;
                }

                Map<?, ?> selectedItem = (Map<?, ?>) obj;

                Long packageItemId = Long.valueOf(
                        String.valueOf(selectedItem.get("packageItemId")));

                Long selectedProductId = Long.valueOf(
                        String.valueOf(selectedItem.get("selectedProductId")));

                HashMap<String, Object> packageItem = orderMapper.selectDirectPackageItem(
                        packageId, packageItemId, selectedProductId);

                if (packageItem == null) {
                    res.put("result", "fail");
                    res.put("message", "선택한 구성 상품을 확인할 수 없습니다.");
                    return res;
                }

                // 구성 상품 판매 상태 확인
                if (!"SELLING".equals(packageItem.get("selectedProductStatus"))) {
                    res.put("result", "fail");
                    res.put("message", "구성 상품 중 구매할 수 없는 상품이 있습니다.");
                    return res;
                }

                int itemQuantity = Integer.parseInt(
                        String.valueOf(packageItem.get("itemQuantity")));

                int stockQuantity = Integer.parseInt(
                        String.valueOf(packageItem.get("selectedProductStock")));

                // 패키지 구매 수량까지 고려한 재고 확인
                if (stockQuantity < itemQuantity * quantity) {
                    res.put("result", "fail");
                    res.put("message", "구성 상품의 재고가 부족합니다.");
                    return res;
                }

                // 주문서 JSP에서 사용하는 데이터 형태에 맞춤
                packageItem.put("cartPackageItemId", packageItemId);

                BigDecimal additionalPrice = new BigDecimal(
                        String.valueOf(packageItem.get("additionalPrice")));

                totalAdditionalAmount = totalAdditionalAmount.add(
                        additionalPrice.multiply(BigDecimal.valueOf(itemQuantity))
                                .multiply(BigDecimal.valueOf(quantity)));

                packageItems.add(packageItem);
            }

            // 선택한 추가 옵션 목록
            Object packageExtrasObj = directPurchase.get("packageExtras");

            if (!(packageExtrasObj instanceof List<?>)) {
                res.put("result", "fail");
                res.put("message", "패키지 추가 옵션 정보가 올바르지 않습니다.");
                return res;
            }

            List<?> selectedExtras = (List<?>) packageExtrasObj;

            // 패키지 필수 추가 옵션 그룹 개수 확인
            int requiredExtraCount = orderMapper.selectRequiredPackageExtraCount(packageId);

            if (selectedExtras.size() < requiredExtraCount) {
                res.put("result", "fail");
                res.put("message", "필수 추가 옵션을 모두 선택해 주세요.");
                return res;
            }

            for (Object obj : selectedExtras) {

                if (!(obj instanceof Map<?, ?>)) {
                    res.put("result", "fail");
                    res.put("message", "추가 옵션 정보가 올바르지 않습니다.");
                    return res;
                }

                Map<?, ?> selectedExtra = (Map<?, ?>) obj;

                Long packageExtraOptionId = Long.valueOf(
                        String.valueOf(selectedExtra.get("packageExtraOptionId")));

                HashMap<String, Object> packageExtra = orderMapper.selectDirectPackageExtra(
                        packageId, packageExtraOptionId);

                if (packageExtra == null) {
                    res.put("result", "fail");
                    res.put("message", "선택한 추가 옵션을 확인할 수 없습니다.");
                    return res;
                }

                // 주문서 JSP에서 사용하는 데이터 형태에 맞춤
                packageExtra.put("cartPackageExtraId", packageExtraOptionId);
                packageExtra.put("optionValue", "");

                BigDecimal additionalPrice = new BigDecimal(
                        String.valueOf(packageExtra.get("additionalPrice")));

                totalAdditionalAmount = totalAdditionalAmount.add(
                        additionalPrice.multiply(BigDecimal.valueOf(quantity)));

                packageExtras.add(packageExtra);
            }

            // 주문서 데이터 구성
            item.put("cartItemId", -1L);
            item.put("quantity", quantity);
            item.put("packageItems", packageItems);
            item.put("packageExtras", packageExtras);

            BigDecimal unitPrice = basePrice.add(
                    totalAdditionalAmount.divide(
                            BigDecimal.valueOf(quantity),
                            2,
                            RoundingMode.HALF_UP));

            BigDecimal lineAmount = basePrice
                    .multiply(BigDecimal.valueOf(quantity))
                    .add(totalAdditionalAmount);

            item.put("unitPrice", unitPrice);
            item.put("lineAmount", lineAmount);

            List<HashMap<String, Object>> items = new ArrayList<>();
            items.add(item);

            // 배송비 계산
            BigDecimal shippingFee = lineAmount.compareTo(
                    BigDecimal.valueOf(FREE_SHIPPING_MIN)) >= 0
                            ? BigDecimal.ZERO
                            : BigDecimal.valueOf(BASIC_SHIPPING_FEE);

            BigDecimal finalAmount = lineAmount.add(shippingFee);

            // 주문서 데이터 반환
            res.put("result", "success");
            res.put("items", items);
            res.put("defaultAddress",
                    addressMapper.selectDefaultAddress(memberId));
            res.put("addressList",
                    addressMapper.selectAddressList(memberId));
            res.put("totalProductAmount",
                    basePrice.multiply(BigDecimal.valueOf(quantity)));
            res.put("totalAdditionalAmount", totalAdditionalAmount);
            res.put("shippingFee", shippingFee);
            res.put("finalAmount", finalAmount);

            return res;
        }
        res.put("result", "fail");
        res.put("message", "올바르지 않은 구매 정보입니다.");
        return res;
    }

    // 주문 상품 리뷰 작성 여부 변경
    public void toggleOrderItemReviewed(Long orderItemId) {
        orderMapper.toggleOrderItemReviewed(orderItemId);
    }
}
