package com.mori.moamong.wishlist.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.wishlist.service.WishlistService;

@RequiredArgsConstructor
@Controller
public class WishlistController {
    private final WishlistService wishlistService;

}
