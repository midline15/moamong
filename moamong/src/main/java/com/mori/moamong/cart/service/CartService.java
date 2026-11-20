package com.mori.moamong.cart.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mori.moamong.cart.mapper.CartMapper;
import com.mori.moamong.dto.Cart;
import com.mori.moamong.dto.CartItem;

import lombok.RequiredArgsConstructor;

/**
 * 장바구니 핵심 비즈니스 로직 1) 단품/패키지 목록 조회 및 실제 결제 금액(기본가 + 옵션추가금) 서버 검증 계산 2) 중복 담기 판별
 * (단품은 productId 기준, 패키지는 구성품+옵션 조합 지문 기준) 3) 품절 및 재고 수량 초과 방어
 */
@RequiredArgsConstructor
@Service
public class CartService {

	private final CartMapper cartMapper;

	// 1. 장바구니 목록 조회 및 단가·총액·주문가능여부 계산
	public HashMap<String, Object> getCartListWithSummary(Long memberId) {
		HashMap<String, Object> res = new HashMap<>();

		// 회원의 장바구니 상자(CART)가 없으면 빈 리스트 반환
		Cart cart = cartMapper.selectCartByMemberId(memberId);
		if (cart == null) {
			res.put("result", "success");
			res.put("list", List.of());
			res.put("totalAmount", 0);
			return res;
		}

		// 장바구니 상자 안의 모든 항목(단품 + 패키지) 조회
		List<CartItem> list = cartMapper.selectCartItems(cart.getCartId());
		int totalAmount = 0; // 주문 가능한 항목들의 전체 합계 금액

		for (CartItem item : list) {
			int basePrice = item.getPrice() != null ? item.getPrice() : 0; // 기본 단가
			int quantity = item.getQuantity() != null ? item.getQuantity() : 1; // 담은 수량
			int optionAdditionalSum = 0; // 패키지 옵션 추가금 합계 (단품은 0원)

			// 상품/패키지 자체가 판매중(SELLING)인지 먼저 확인
			boolean isAvailable = "SELLING".equals(item.getItemStatus());
			String reason = isAvailable ? null : "현재 판매 중인 상품이 아닙니다.";

			if ("PRODUCT".equals(item.getItemType())) {
				// [단품] 현재 재고량과 담은 수량 비교
				int stock = item.getStockQuantity() != null ? item.getStockQuantity() : 0;
				if (isAvailable && (stock <= 0 || stock < quantity)) {
					isAvailable = false;
					reason = stock <= 0 ? "품절된 상품입니다." : "재고가 부족합니다. (현재 재고: " + stock + "개)";
				}
			} else {
				// [패키지 1] 선택한 구성 상품 목록 조회 & 교체 추가금 합산 & 구성품 재고 확인
				List<HashMap<String, Object>> pkgItems = cartMapper.selectCartPackageItems(item.getCartItemId());
				for (HashMap<String, Object> pi : pkgItems) {
					optionAdditionalSum += toInt(pi.get("additionalPrice"));
					String subStatus = String.valueOf(pi.get("selectedProductStatus"));
					int subStock = toInt(pi.get("selectedProductStock"));
					int reqQty = toInt(pi.get("itemQuantity")) * quantity; // 구성품 1세트 수량 * 패키지 수량
					if (isAvailable && (!"SELLING".equals(subStatus) || subStock < reqQty)) {
						isAvailable = false;
						reason = "패키지 구성 상품 중 품절 또는 재고 부족 상품이 있습니다.";
					}
				}

				// [패키지 2] 선택한 추가 옵션(박스 색상/카드) 조회 & 추가금 합산
				List<HashMap<String, Object>> pkgExtras = cartMapper.selectCartPackageExtras(item.getCartItemId());
				for (HashMap<String, Object> pe : pkgExtras) {
					optionAdditionalSum += toInt(pe.get("additionalPrice"));
				}

				item.setPackageItems(pkgItems);
				item.setPackageExtras(pkgExtras);
			}

			// 1개당 최종 단가 = 기본가 + 옵션 추가금 합
			int unitTotal = basePrice + optionAdditionalSum;
			// 해당 줄 총 금액 = 개당 최종 단가 * 수량
			int lineTotal = unitTotal * quantity;

			item.setUnitTotalPrice(unitTotal);
			item.setLineTotalPrice(lineTotal);
			item.setAvailable(isAvailable);
			item.setUnavailableReason(reason);

			// 주문 가능한 상품만 전체 합계 금액에 누적
			if (isAvailable) {
				totalAmount += lineTotal;
			}
		}

		res.put("result", "success");
		res.put("list", list);
		res.put("totalAmount", totalAmount);
		return res;
	}

	// 2. 장바구니 담기 (단품 및 패키지 공용)
	@Transactional
	public HashMap<String, Object> addCart(Long memberId, Map<String, Object> payload) {
		HashMap<String, Object> res = new HashMap<>();

		Long productId = toNullableLong(payload.get("productId"));
		Long packageId = toNullableLong(payload.get("packageId"));
		int quantity = payload.get("quantity") != null ? Integer.parseInt(payload.get("quantity").toString()) : 1;

		// 1) 기본 입력값 방어 (수량 1 이상, 단품/패키지 중 정확히 하나만 존재해야 함)
		if (quantity < 1) {
			res.put("result", "fail");
			res.put("message", "수량은 1개 이상이어야 합니다.");
			return res;
		}
		if ((productId == null && packageId == null) || (productId != null && packageId != null)) {
			res.put("result", "fail");
			res.put("message", "단품 또는 패키지 중 하나만 지정해야 합니다.");
			return res;
		}

		// 2) 회원 장바구니 상자(CART) 조회 -> 없으면 새로 생성
		Cart cart = cartMapper.selectCartByMemberId(memberId);
		if (cart == null) {
			HashMap<String, Object> cartParam = new HashMap<>();
			cartParam.put("memberId", memberId);
			cartMapper.insertCart(cartParam);
			cart = cartMapper.selectCartByMemberId(memberId);
		}
		Long cartId = cart.getCartId();

		// ================= [CASE A] 단품 상품 담기 =================
		if (productId != null) {
			HashMap<String, Object> product = cartMapper.selectProductInfo(productId);
			if (product == null) {
				res.put("result", "fail");
				res.put("message", "존재하지 않는 상품입니다.");
				return res;
			}
			if (!"SELLING".equals(String.valueOf(product.get("productStatus")))) {
				res.put("result", "fail");
				res.put("message", "현재 판매 중인 상품이 아닙니다.");
				return res;
			}
			int stock = toInt(product.get("stockQuantity"));

			// 이미 장바구니에 같은 단품이 담겨 있는지 확인 (기존 수량 + 새 수량 <= 재고)
			CartItem existing = cartMapper.selectCartItemByProductId(cartId, productId);
			int finalQty = quantity + (existing != null ? existing.getQuantity() : 0);
			if (finalQty > stock) {
				res.put("result", "fail");
				res.put("message", "재고 수량을 초과하여 담을 수 없습니다. (현재 재고: " + stock + "개)");
				return res;
			}

			if (existing != null) {
				// 이미 있으면 수량만 합산(UPDATE)
				cartMapper.addCartItemQuantity(existing.getCartItemId(), quantity);
			} else {
				// 처음 담는 상품이면 새 행 추가(INSERT)
				HashMap<String, Object> insertParam = new HashMap<>();
				insertParam.put("cartId", cartId);
				insertParam.put("productId", productId);
				insertParam.put("packageId", null);
				insertParam.put("quantity", quantity);
				cartMapper.insertCartItem(insertParam);
			}

			res.put("result", "success");
			res.put("message", "장바구니에 상품이 담겼습니다.");
			return res;
		}

		// ================= [CASE B] 패키지 상품 담기 =================
		HashMap<String, Object> pkg = cartMapper.selectPackageInfo(packageId);
		if (pkg == null) {
			res.put("result", "fail");
			res.put("message", "존재하지 않는 패키지입니다.");
			return res;
		}
		if (!"SELLING".equals(String.valueOf(pkg.get("packageStatus")))) {
			res.put("result", "fail");
			res.put("message", "현재 판매 중인 패키지가 아닙니다.");
			return res;
		}

		// 1) 패키지 구성 상품 옵션 유효성 검증 및 DB 기준 추가금 조회
		List<Map<String, Object>> rawPkgItems = castListOfMap(payload.get("packageItems"));
		List<HashMap<String, Object>> validPkgItems = new ArrayList<>();
		for (Map<String, Object> raw : rawPkgItems) {
			Long pkgItemId = toNullableLong(raw.get("packageItemId"));
			Long selectedProdId = toNullableLong(raw.get("selectedProductId"));
			if (pkgItemId == null || selectedProdId == null)
				continue;

			HashMap<String, Object> optInfo = cartMapper.selectPackageItemOptionInfo(pkgItemId, selectedProdId);
			if (optInfo == null) {
				res.put("result", "fail");
				res.put("message", "유효하지 않은 패키지 구성 상품 옵션입니다.");
				return res;
			}
			HashMap<String, Object> clean = new HashMap<>();
			clean.put("packageItemId", pkgItemId);
			clean.put("selectedProductId", selectedProdId);
			clean.put("itemRole", optInfo.get("itemRole"));
			clean.put("additionalPrice", toInt(optInfo.get("additionalPrice")));
			validPkgItems.add(clean);
		}

		// 2) 패키지 추가 옵션(박스 색상/카드) 유효성 검증 및 DB 기준 추가금 조회
		List<Map<String, Object>> rawPkgExtras = castListOfMap(payload.get("packageExtras"));
		List<HashMap<String, Object>> validPkgExtras = new ArrayList<>();
		for (Map<String, Object> raw : rawPkgExtras) {
			Long extraOptId = toNullableLong(raw.get("packageExtraOptionId"));
			if (extraOptId == null)
				continue;

			HashMap<String, Object> extraInfo = cartMapper.selectPackageExtraOptionInfo(extraOptId);
			if (extraInfo == null || !packageId.equals(toNullableLong(extraInfo.get("packageId")))) {
				res.put("result", "fail");
				res.put("message", "유효하지 않은 패키지 추가 옵션입니다.");
				return res;
			}
			HashMap<String, Object> clean = new HashMap<>();
			clean.put("packageExtraOptionId", extraOptId);
			clean.put("additionalPrice", toInt(extraInfo.get("additionalPrice")));
			validPkgExtras.add(clean);
		}

		// 3) 옵션 지문(Signature) 비교 -> 동일 패키지 + 동일 옵션 조합이면 수량만 합산
		String newSignature = buildPackageSignature(validPkgItems, validPkgExtras);
		List<CartItem> existingPkgItems = cartMapper.selectCartItemsByPackageId(cartId, packageId);
		for (CartItem candidate : existingPkgItems) {
			List<HashMap<String, Object>> existItems = cartMapper.selectCartPackageItems(candidate.getCartItemId());
			List<HashMap<String, Object>> existExtras = cartMapper.selectCartPackageExtras(candidate.getCartItemId());

			if (newSignature.equals(buildPackageSignature(existItems, existExtras))) {
				cartMapper.addCartItemQuantity(candidate.getCartItemId(), quantity);
				res.put("result", "success");
				res.put("message", "장바구니에 패키지가 담겼습니다.");
				return res;
			}
		}

		// 4) 옵션 조합이 다르면 신규 CART_ITEM + 하위 옵션 스냅샷 테이블 2개에 각각 INSERT
		HashMap<String, Object> insertParam = new HashMap<>();
		insertParam.put("cartId", cartId);
		insertParam.put("productId", null);
		insertParam.put("packageId", packageId);
		insertParam.put("quantity", quantity);
		cartMapper.insertCartItem(insertParam);

		Long newCartItemId = toNullableLong(insertParam.get("cartItemId"));
		for (HashMap<String, Object> pi : validPkgItems) {
			pi.put("cartItemId", newCartItemId);
			cartMapper.insertCartPackageItem(pi);
		}
		for (HashMap<String, Object> pe : validPkgExtras) {
			pe.put("cartItemId", newCartItemId);
			cartMapper.insertCartPackageExtra(pe);
		}

		res.put("result", "success");
		res.put("message", "장바구니에 패키지가 담겼습니다.");
		return res;
	}

	// 3. 수량 변경 (본인 소유권 확인 + 단품 재고 초과 방어)
	@Transactional
	public HashMap<String, Object> updateCart(Long memberId, Long cartItemId, int quantity) {
		HashMap<String, Object> res = new HashMap<>();
		if (quantity < 1) {
			res.put("result", "fail");
			res.put("message", "수량은 1개 이상이어야 합니다.");
			return res;
		}
		HashMap<String, Object> item = cartMapper.selectCartItemForOwnerCheck(cartItemId, memberId);
		if (item == null) {
			res.put("result", "fail");
			res.put("message", "장바구니 항목을 찾을 수 없습니다.");
			return res;
		}
		if (item.get("productId") != null) {
			int stock = toInt(item.get("stockQuantity"));
			if (quantity > stock) {
				res.put("result", "fail");
				res.put("message", "재고 수량을 초과했습니다. (최대 " + stock + "개)");
				return res;
			}
		}
		cartMapper.updateCartItem(cartItemId, quantity);
		res.put("result", "success");
		return res;
	}

	// 4. 개별 삭제 / 선택 삭제 / 전체 비우기
	@Transactional
	public int removeCart(Long memberId, Long cartItemId) {
		return cartMapper.deleteCartItem(cartItemId, memberId);
	}

	@Transactional
	public int removeSelectedCartItems(Long memberId, List<Long> cartItemIds) {
		if (cartItemIds == null || cartItemIds.isEmpty())
			return 0;
		return cartMapper.deleteSelectedCartItems(memberId, cartItemIds);
	}

	@Transactional
	public int deleteAllCartItems(Long memberId) {
		Cart cart = cartMapper.selectCartByMemberId(memberId);
		if (cart == null)
			return 0;
		return cartMapper.deleteAllCartItems(cart.getCartId());
	}

	// [핵심 유틸] 패키지 구성품과 추가옵션을 정렬된 고유 문자열("지문")로 변환
	// 예: "10:3,11:5|2,7" -> 순서가 달라도 옵션 조합이 같으면 동일한 문자열이 생성됨
	private String buildPackageSignature(List<HashMap<String, Object>> items, List<HashMap<String, Object>> extras) {
		List<String> itemTokens = new ArrayList<>();
		if (items != null) {
			for (HashMap<String, Object> i : items) {
				itemTokens
						.add(toNullableLong(i.get("packageItemId")) + ":" + toNullableLong(i.get("selectedProductId")));
			}
			itemTokens.sort(Comparator.naturalOrder());
		}
		List<String> extraTokens = new ArrayList<>();
		if (extras != null) {
			for (HashMap<String, Object> e : extras) {
				extraTokens.add(String.valueOf(toNullableLong(e.get("packageExtraOptionId"))));
			}
			extraTokens.sort(Comparator.naturalOrder());
		}
		return String.join(",", itemTokens) + "|" + String.join(",", extraTokens);
	}

	private int toInt(Object val) {
		return val == null ? 0 : Integer.parseInt(String.valueOf(val));
	}

	private Long toNullableLong(Object val) {
		if (val == null || String.valueOf(val).trim().isEmpty())
			return null;
		return Long.parseLong(String.valueOf(val));
	}

	@SuppressWarnings("unchecked")
	private List<Map<String, Object>> castListOfMap(Object obj) {
		return obj instanceof List<?> ? (List<Map<String, Object>>) obj : List.of();
	}
}
