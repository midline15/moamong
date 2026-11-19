package com.mori.moamong.cart.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Cart;
import com.mori.moamong.dto.CartItem;

@Mapper
public interface CartMapper {

    // 회원 장바구니 정보 조회
    Cart selectCartByMemberId(HashMap<String, Object> map);

    // 장바구니 상품 목록 조회
    List<CartItem> selectCartItems(HashMap<String, Object> map);

    // 장바구니 상품 삭제
    int deleteCartItem(HashMap<String, Object> map);

    // 장바구니 수량 변경
    int updateCartItem(HashMap<String, Object> map);

    // 상품이 이미 장바구니에 있는지 조회
    CartItem selectCartItemByProductId(HashMap<String, Object> map);

    // 장바구니 상품 추가
    int insertCartItem(HashMap<String, Object> map);

    // 이미 담긴 상품이면 수량 합산
    int addCartItemQuantity(HashMap<String, Object> map);

    // 회원 장바구니 생성
    int insertCart(HashMap<String, Object> map);

    // 장바구니 비우기
    int deleteAllCartItems(HashMap<String, Object> map);


}
