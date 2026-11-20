package com.mori.moamong.cart.mapper;

import java.util.HashMap;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.mori.moamong.dto.Cart;
import com.mori.moamong.dto.CartItem;

/**
 * 장바구니 MyBatis 매퍼 인터페이스 (CartMapper.xml과 1:1 매핑)
 */
@Mapper
public interface CartMapper {

    // ================= 1. 장바구니 마스터(CART) =================
    // 회원 번호로 내 장바구니 상자(CART) 조회
    Cart selectCartByMemberId(@Param("memberId") Long memberId);
    // 장바구니 상자가 없을 때 최초 1회 생성 (생성된 cartId를 map에 자동 세팅)
    int insertCart(HashMap<String, Object> map);

    // ================= 2. 장바구니 목록 및 옵션 상세 조회 =================
    // 장바구니에 담긴 단품 + 패키지 목록 조회 (상품명, 기본가격, 판매상태, 썸네일 포함)
    List<CartItem> selectCartItems(@Param("cartId") Long cartId);
    // 패키지 항목 1건에 연결된 선택 구성 상품 목록 조회 (CART_PACKAGE_ITEM)
    List<HashMap<String, Object>> selectCartPackageItems(@Param("cartItemId") Long cartItemId);
    // 패키지 항목 1건에 연결된 추가 옵션(박스/카드) 목록 조회 (CART_PACKAGE_EXTRA)
    List<HashMap<String, Object>> selectCartPackageExtras(@Param("cartItemId") Long cartItemId);

    // ================= 3. 담기 전 상품/패키지 유효성 및 가격 검증 =================
    // 단품 상품의 가격, 재고, 판매상태(SELLING 여부) 조회
    HashMap<String, Object> selectProductInfo(@Param("productId") Long productId);
    // 패키지 상품의 기본가격, 판매상태(SELLING 여부) 조회
    HashMap<String, Object> selectPackageInfo(@Param("packageId") Long packageId);
    // 패키지 구성품 교체 옵션이 유효한지 검증하고 교체 추가금(additional_price) 조회
    HashMap<String, Object> selectPackageItemOptionInfo(@Param("packageItemId") Long packageItemId,
                                                        @Param("selectedProductId") Long selectedProductId);
    // 패키지 추가 옵션(박스/카드)이 유효한지 검증하고 옵션 추가금(additional_price) 조회
    HashMap<String, Object> selectPackageExtraOptionInfo(@Param("packageExtraOptionId") Long packageExtraOptionId);

    // ================= 4. 중복 담기 체크용 조회 =================
    // 내 장바구니에 이미 같은 단품(productId)이 담겨 있는지 확인
    CartItem selectCartItemByProductId(@Param("cartId") Long cartId, @Param("productId") Long productId);
    // 내 장바구니에 같은 패키지(packageId)가 담겨 있는 행 목록 조회 (옵션 비교용)
    List<CartItem> selectCartItemsByPackageId(@Param("cartId") Long cartId, @Param("packageId") Long packageId);

    // ================= 5. 장바구니 항목 등록(INSERT) =================
    // CART_ITEM 테이블에 단품 또는 패키지 1건 추가
    int insertCartItem(HashMap<String, Object> map);
    // CART_PACKAGE_ITEM 테이블에 패키지 구성품 선택 스냅샷 추가
    int insertCartPackageItem(HashMap<String, Object> map);
    // CART_PACKAGE_EXTRA 테이블에 패키지 추가 옵션 스냅샷 추가
    int insertCartPackageExtra(HashMap<String, Object> map);

    // ================= 6. 수량 변경 및 삭제 (본인 장바구니 검증 포함) =================
    // 수정하려는 장바구니 항목이 진짜 로그인한 회원 본인 것인지 + 현재 재고량 조회
    HashMap<String, Object> selectCartItemForOwnerCheck(@Param("cartItemId") Long cartItemId,
                                                        @Param("memberId") Long memberId);
    // 수량을 지정한 숫자로 직접 변경 (UPDATE)
    int updateCartItem(@Param("cartItemId") Long cartItemId, @Param("quantity") int quantity);
    // 기존 수량에 +N 만큼 합산 (중복 담기 시 사용)
    int addCartItemQuantity(@Param("cartItemId") Long cartItemId, @Param("quantity") int quantity);
    // 개별 항목 1건 삭제 (본인 장바구니 항목만 삭제되도록 JOIN 검증)
    int deleteCartItem(@Param("cartItemId") Long cartItemId, @Param("memberId") Long memberId);
    // 체크박스로 선택한 여러 항목 일괄 삭제 (IN 절 사용)
    int deleteSelectedCartItems(@Param("memberId") Long memberId, @Param("cartItemIds") List<Long> cartItemIds);
    // 내 장바구니 안의 모든 항목 비우기
    int deleteAllCartItems(@Param("cartId") Long cartId);
}
