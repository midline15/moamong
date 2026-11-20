package com.mori.moamong.dto;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import lombok.Data;

@Data
public class CartItem {
	private Long cartItemId;
	private Long cartId;
	private Long productId;
	private Long packageId;
	private Integer quantity;
	private String createdAt;

	// 상품 / 패키지 공통 정보
	private String itemType; // "PRODUCT" or "PACKAGE"
	private String productName; // 상품명 또는 패키지명
	private Integer price; // 기본 단가 (product.price 또는 package.package_price)
	private String itemStatus; // SELLING / SOLD_OUT / HIDDEN
	private Integer stockQuantity; // 단품 재고수량 (패키지는 구성품 재고로 별도 체크)
	private String packageGrade; // BASIC / STANDARD / PREMIUM / LUXURY
	private String thumbnailUrl; // THUMBNAIL 이미지 URL

	// 패키지 상세 옵션 목록 및 계산 금액
	private List<HashMap<String, Object>> packageItems = new ArrayList<>();
	private List<HashMap<String, Object>> packageExtras = new ArrayList<>();
	private Integer unitTotalPrice; // 개당 최종 단가 (기본가 + 구성품 추가금 + 옵션 추가금)
	private Integer lineTotalPrice; // 항목 총액 (unitTotalPrice * quantity)
	private Boolean available; // 주문 가능 여부 (판매중 & 재고 충분)
	private String unavailableReason; // 주문 불가 사유
}
