package com.mori.moamong.cart.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.cart.mapper.CartMapper;

@RequiredArgsConstructor
@Service
public class CartService {
    private final CartMapper cartMapper;

}
