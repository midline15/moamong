package com.mori.moamong.cart.service;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mori.moamong.cart.mapper.CartMapper;
import com.mori.moamong.dto.Cart;
import com.mori.moamong.dto.CartItem;

@RequiredArgsConstructor
@Service
public class CartService {
    private final CartMapper cartMapper;

    // 장바구니 리스트 조회
    public List<CartItem> getCartItems(HashMap<String, Object> map) {

        // 회원 장바구니 조회
        Cart cart = cartMapper.selectCartByMemberId(map);

        if (cart == null) {
            return List.of();
        }

        // 장바구니 상품 목록 조회
        map.put("cartId", cart.getCartId());

        List<CartItem> list = cartMapper.selectCartItems(map);

        return list;
    }

    // 장바구니 상품 삭제
    public int removeCart(HashMap<String, Object> map) {
        return cartMapper.deleteCartItem(map);
    }

    // 장바구니 수량 변경
    public int updateCart(HashMap<String, Object> map) {
        return cartMapper.updateCartItem(map);
    }

    // 장바구니 상품 추가
    public int addCart(HashMap<String, Object> map) {

        // 회원 장바구니 조회
        Cart cart = cartMapper.selectCartByMemberId(map);

        // 장바구니가 없으면 생성
        if (cart == null) {
            cartMapper.insertCart(map);
            cart = cartMapper.selectCartByMemberId(map);
        }

        map.put("cartId", cart.getCartId());

        // 이미 담긴 상품인지 확인
        CartItem item = cartMapper.selectCartItemByProductId(map);

        if (item != null) {
            // 기존 상품이면 수량 증가
            map.put("cartItemId", item.getCartItemId());
            return cartMapper.addCartItemQuantity(map);
        } else {
            // 새로운 상품이면 추가
            return cartMapper.insertCartItem(map);
        }
    }


    // 장바구니 비우기
    public int deleteAllCartItems(HashMap<String, Object> map) {

        // 회원의 장바구니 조회
        Cart cart = cartMapper.selectCartByMemberId(map);

        if (cart == null) {
            return 0;
        }

        map.put("cartId", cart.getCartId());

        return cartMapper.deleteAllCartItems(map);
    }





}
