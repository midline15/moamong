package com.mori.moamong.order.mapper;

import java.util.HashMap;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface OrderMapper {

	// ==================== 1. 주문서(Checkout) 조회 ====================

	// 선택한 장바구니 항목 목록 조회 (단품/패키지 기본 정보)
	List<HashMap<String, Object>> selectCheckoutCartItems(@Param("memberId") Long memberId,
			@Param("cartItemIds") List<Long> cartItemIds);

	// 장바구니 패키지 1건의 선택 구성 상품 목록 조회
	List<HashMap<String, Object>> selectCheckoutPackageItems(Long cartItemId);

	// 장바구니 패키지 1건의 선택 추가 옵션(박스/카드) 목록 조회
	List<HashMap<String, Object>> selectCheckoutPackageExtras(Long cartItemId);

	// ==================== 2. 주문 생성 및 재고 차감 ====================

	// 주문 마스터(ORDERS) 1건 저장
	int insertOrder(HashMap<String, Object> map);

	// 주문 상품 항목(ORDER_ITEM) 1건 저장
	int insertOrderItem(HashMap<String, Object> map);

	// 주문 패키지 구성품 스냅샷(ORDER_PACKAGE_ITEM) 1건 저장
	int insertOrderPackageItem(HashMap<String, Object> map);

	// 주문 패키지 추가 옵션 스냅샷(ORDER_PACKAGE_EXTRA) 1건 저장
	int insertOrderPackageExtra(HashMap<String, Object> map);

	// 상품 재고 차감 (재고 0이 되면 SOLD_OUT 자동 전환)
	int decreaseProductStock(@Param("productId") Long productId, @Param("deductQty") int deductQty);

	// 주문 완료된 장바구니 항목 일괄 삭제
	int deleteOrderedCartItems(@Param("memberId") Long memberId, @Param("cartItemIds") List<Long> cartItemIds);

	// ==================== 3. 주문 내역 조회 및 주문 취소 ====================

	// 내 주문 마스터 목록 조회
	List<HashMap<String, Object>> selectOrderList(Long memberId);

	// 주문 단건 조회 (본인 주문인지 확인용)
	HashMap<String, Object> selectOrderOne(@Param("orderId") Long orderId, @Param("memberId") Long memberId);

	// 주문 1건에 포함된 상품 항목 목록 조회
	List<HashMap<String, Object>> selectOrderItems(Long orderId);

	// 주문 패키지 항목의 구성품 스냅샷 조회
	List<HashMap<String, Object>> selectOrderPackageItems(Long orderItemId);

	// 주문 패키지 항목의 추가 옵션 스냅샷 조회
	List<HashMap<String, Object>> selectOrderPackageExtras(Long orderItemId);

	// 주문 상태 변경 (예: PAID -> CANCELED)
	int updateOrderStatus(@Param("orderId") Long orderId, @Param("memberId") Long memberId,
			@Param("orderStatus") String orderStatus);

	// 주문 취소 시 상품 재고 복구
	int increaseProductStock(@Param("productId") Long productId, @Param("restoreQty") int restoreQty);

	// 주문 취소 이력(ORDER_CANCEL) 저장
	int insertOrderCancel(HashMap<String, Object> map);

	// 주문 취소 이력 단건 조회
	HashMap<String, Object> selectOrderCancel(Long orderId);

	// 주문 결제 내역 단건 조회
	HashMap<String, Object> selectOrderPayment(Long orderId);
}
