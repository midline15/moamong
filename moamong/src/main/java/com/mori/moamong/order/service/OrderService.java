package com.mori.moamong.order.service;

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
import com.mori.moamong.order.mapper.OrderMapper;

import lombok.RequiredArgsConstructor;

/**
 * 주문 핵심 비즈니스 로직 1) 주문서(Checkout) 데이터 조회 및 금액·재고 서버 검증 2) 주문 생성 (스냅샷 저장 + 재고 차감
 * + 장바구니 비우기) 3) 주문 내역 조회 및 주문 취소 (상태 변경 + 재고 복구)
 */
@RequiredArgsConstructor
@Service
public class OrderService {

	private final OrderMapper orderMapper;
	private final AddressMapper addressMapper;

	// 배송비 정책 상수 (30,000원 이상 무료배송, 미만 시 3,000원)
	private static final int FREE_SHIPPING_MIN = 30000;
	private static final int BASIC_SHIPPING_FEE = 3000;

	// ==================== 1. 주문서(Checkout) 초기 데이터 조회 ====================
	public HashMap<String, Object> getCheckoutData(Long memberId, List<Long> cartItemIds) {
		HashMap<String, Object> res = new HashMap<>();

		// 1) 선택된 장바구니 번호가 없으면 실패 반환
		if (cartItemIds == null || cartItemIds.isEmpty()) {
			res.put("result", "fail");
			res.put("message", "주문할 상품이 선택되지 않았습니다.");
			return res;
		}

		// 2) 본인 장바구니에서 선택한 항목 목록 조회
		List<HashMap<String, Object>> items = orderMapper.selectCheckoutCartItems(memberId, cartItemIds);
		if (items.isEmpty() || items.size() != cartItemIds.size()) {
			res.put("result", "fail");
			res.put("message", "유효하지 않거나 이미 삭제된 상품이 포함되어 있습니다.");
			return res;
		}

		int productTotal = 0; // 기본 상품/패키지 금액 합계
		int optionTotal = 0; // 패키지 옵션 추가 금액 합계

		// 3) 각 항목의 판매상태·재고 검증 및 금액 계산
		for (HashMap<String, Object> item : items) {
			String type = String.valueOf(item.get("itemType")); // PRODUCT 또는 PACKAGE
			String status = String.valueOf(item.get("itemStatus")); // SELLING 여부
			int basePrice = toInt(item.get("basePrice")); // 기본 단가
			int qty = toInt(item.get("quantity")); // 주문 수량
			int extraPricePerOne = 0; // 1개당 옵션 추가금

			if (!"SELLING".equals(status)) {
				res.put("result", "fail");
				res.put("message", "[" + item.get("itemName") + "] 상품은 현재 판매 중이 아닙니다.");
				return res;
			}

			if ("PRODUCT".equals(type)) {
				// [단품] 현재 재고량 확인
				int stock = toInt(item.get("stockQuantity"));
				if (stock < qty) {
					res.put("result", "fail");
					res.put("message", "[" + item.get("itemName") + "] 재고가 부족합니다. (현재 재고: " + stock + "개)");
					return res;
				}
				item.put("packageItems", List.of());
				item.put("packageExtras", List.of());
			} else {
				// [패키지] 구성품 목록 조회 + 추가금 합산 + 구성품별 재고 확인
				Long cartItemId = toLong(item.get("cartItemId"));
				List<HashMap<String, Object>> pkgItems = orderMapper.selectCheckoutPackageItems(cartItemId);

				for (HashMap<String, Object> pi : pkgItems) {
					extraPricePerOne += toInt(pi.get("additionalPrice"));
					int needQty = toInt(pi.get("itemQuantity")) * qty; // 1세트 수량 * 패키지 주문 수량
					int subStock = toInt(pi.get("selectedProductStock"));
					String subStatus = String.valueOf(pi.get("selectedProductStatus"));

					if (!"SELLING".equals(subStatus) || subStock < needQty) {
						res.put("result", "fail");
						res.put("message", "[" + item.get("itemName") + "] 구성 상품 중 품절 또는 재고 부족 상품이 있습니다.");
						return res;
					}
				}

				// [패키지] 추가 옵션(박스 색상/카드) 조회 + 추가금 합산
				List<HashMap<String, Object>> pkgExtras = orderMapper.selectCheckoutPackageExtras(cartItemId);
				for (HashMap<String, Object> pe : pkgExtras) {
					extraPricePerOne += toInt(pe.get("additionalPrice"));
					pe.put("optionValue", ""); // 주문서에서 입력받을 카드 메시지 초기화
				}

				item.put("packageItems", pkgItems);
				item.put("packageExtras", pkgExtras);
			}

			// 1개당 최종 단가 및 해당 줄 총액 세팅
			int unitPrice = basePrice + extraPricePerOne;
			int lineAmount = unitPrice * qty;
			item.put("unitPrice", unitPrice);
			item.put("lineAmount", lineAmount);

			productTotal += (basePrice * qty);
			optionTotal += (extraPricePerOne * qty);
		}

		// 4) 최종 배송비 및 총 결제 금액 계산
		int sumAmount = productTotal + optionTotal;
		int shippingFee = sumAmount >= FREE_SHIPPING_MIN ? 0 : BASIC_SHIPPING_FEE;
		int finalAmount = sumAmount + shippingFee;

		// 5) 회원의 기본 배송지 및 전체 배송지 목록 함께 조회
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

	// ==================== 2. 주문 생성 (스냅샷 저장 + 재고 차감 + 장바구니 비우기)
	// ====================
	@Transactional
	public HashMap<String, Object> createOrder(Long memberId, Map<String, Object> payload) {
		HashMap<String, Object> res = new HashMap<>();

		// 1) 화면에서 넘어온 배송지 및 선택 장바구니 ID 추출
		List<Long> cartItemIds = parseLongList(payload.get("cartItemIds"));
		String name = toStr(payload.get("recipientName"));
		String phone = toStr(payload.get("recipientPhone"));
		String zip = toStr(payload.get("postalCode"));
		String addr1 = toStr(payload.get("addressDefault"));
		String addr2 = toStr(payload.get("addressDetail"));

		if (cartItemIds.isEmpty()) {
			res.put("result", "fail");
			res.put("message", "주문할 상품이 없습니다.");
			return res;
		}
		if (name.isEmpty() || phone.isEmpty() || zip.isEmpty() || addr1.isEmpty()) {
			res.put("result", "fail");
			res.put("message", "배송지 필수 정보를 모두 입력해주세요.");
			return res;
		}

		// 카드 메시지 사용자 입력값 (key: cartPackageExtraId, value: 메시지 문자열)
		Map<String, Object> extraValues = toMap(payload.get("extraValues"));

		// 2) 서버 기준으로 장바구니 품목·가격·재고 다시 한 번 검증
		HashMap<String, Object> check = getCheckoutData(memberId, cartItemIds);
		if (!"success".equals(check.get("result"))) {
			return check;
		}

		@SuppressWarnings("unchecked")
		List<HashMap<String, Object>> items = (List<HashMap<String, Object>>) check.get("items");

		// 3) ORDERS(주문 마스터) 1건 생성
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
		orderMap.put("finalAmount", toInt(check.get("finalAmount")));
		orderMap.put("orderStatus", "PAID"); // PG 연동 전이므로 결제완료(PAID)로 저장

		orderMapper.insertOrder(orderMap);
		Long orderId = toLong(orderMap.get("orderId"));

		// 4) ORDER_ITEM 및 패키지 하위 스냅샷 저장 + 재고 차감
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
				// [단품] 재고 차감 (부족 시 예외 발생시켜 전체 트랜잭션 롤백)
				int ok = orderMapper.decreaseProductStock(productId, qty);
				if (ok == 0) {
					throw new IllegalStateException("[" + item.get("itemName") + "] 재고가 부족하여 주문을 완료할 수 없습니다.");
				}
			} else {
				// [패키지] 구성 상품 스냅샷 복사 + 각 구성품 재고 차감
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
						throw new IllegalStateException("구성 상품 [" + pi.get("selectedProductName") + "]의 재고가 부족합니다.");
					}
				}

				// [패키지] 추가 옵션(박스/카드) 스냅샷 복사
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

		// 5) 주문이 완료된 장바구니 항목 삭제
		orderMapper.deleteOrderedCartItems(memberId, cartItemIds);

		res.put("result", "success");
		res.put("orderId", orderId);
		res.put("orderNumber", orderNumber);
		res.put("message", "주문이 정상적으로 완료되었습니다.");
		return res;
	}

	// ==================== 3. 내 주문 내역 조회 ====================
	public HashMap<String, Object> getOrderList(Long memberId) {
		HashMap<String, Object> res = new HashMap<>();
		List<HashMap<String, Object>> orders = orderMapper.selectOrderList(memberId);

		for (HashMap<String, Object> order : orders) {
			Long orderId = toLong(order.get("orderId"));
			List<HashMap<String, Object>> items = orderMapper.selectOrderItems(orderId);

			// 패키지 항목이면 구성품·추가옵션 스냅샷도 함께 담기
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
			order.put("items", items);

			// 취소된 주문이면 취소 사유·일시 조회
			if ("CANCELED".equals(order.get("orderStatus"))) {
				order.put("cancelInfo", orderMapper.selectOrderCancel(orderId));
			}
		}

		res.put("result", "success");
		res.put("list", orders);
		return res;
	}

	// ==================== 4. 주문 취소 (상태 변경 + 재고 복구 + 취소이력 기록) ====================
	@Transactional
	public HashMap<String, Object> cancelOrder(Long memberId, Long orderId, String cancelReason) {
		HashMap<String, Object> res = new HashMap<>();

		// 1) 본인 주문 여부 및 취소 가능 상태 확인
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

		// 2) 차감되었던 단품/패키지 구성품 재고 복구
		List<HashMap<String, Object>> items = orderMapper.selectOrderItems(orderId);
		for (HashMap<String, Object> item : items) {
			int qty = toInt(item.get("quantity"));
			if ("PRODUCT".equals(item.get("itemType"))) {
				Long productId = toLong(item.get("productId"));
				if (productId != null) {
					orderMapper.increaseProductStock(productId, qty);
				}
			} else {
				Long orderItemId = toLong(item.get("orderItemId"));
				List<HashMap<String, Object>> pkgItems = orderMapper.selectOrderPackageItems(orderItemId);
				for (HashMap<String, Object> pi : pkgItems) {
					Long subProdId = toLong(pi.get("productId"));
					int setQty = toInt(pi.get("quantity"));
					if (subProdId != null) {
						orderMapper.increaseProductStock(subProdId, setQty * qty);
					}
				}
			}
		}

		// 3) 주문 상태 CANCELED 변경 및 ORDER_CANCEL 기록
		orderMapper.updateOrderStatus(orderId, memberId, "CANCELED");

		HashMap<String, Object> cancelMap = new HashMap<>();
		cancelMap.put("orderId", orderId);
		cancelMap.put("cancelReason",
				(cancelReason == null || cancelReason.trim().isEmpty()) ? "구매자 단순 변심" : cancelReason.trim());
		cancelMap.put("cancelStatus", "COMPLETED");
		cancelMap.put("cancelAmount", toInt(order.get("finalAmount")));
		orderMapper.insertOrderCancel(cancelMap);

		res.put("result", "success");
		res.put("message", "주문이 취소되었으며 재고가 복구되었습니다.");
		return res;
	}

	// ==================== [공통 변환 유틸] ====================
	private String makeOrderNumber() {
		String time = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
		int rand = ThreadLocalRandom.current().nextInt(1000, 9999);
		return "ORD" + time + rand;
	}

	private int toInt(Object val) {
		return val == null ? 0 : Integer.parseInt(String.valueOf(val));
	}

	private Long toLong(Object val) {
		if (val == null || String.valueOf(val).trim().isEmpty())
			return null;
		return Long.parseLong(String.valueOf(val));
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
}
