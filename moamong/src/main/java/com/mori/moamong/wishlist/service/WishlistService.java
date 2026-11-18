package com.mori.moamong.wishlist.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.wishlist.mapper.WishlistMapper;

@RequiredArgsConstructor
@Service
public class WishlistService {
    private final WishlistMapper wishlistMapper;

}
