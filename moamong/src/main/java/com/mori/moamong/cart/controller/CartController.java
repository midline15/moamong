package com.mori.moamong.cart.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.cart.service.CartService;

@RequiredArgsConstructor
@Controller
public class CartController {
    private final CartService cartService;

}
