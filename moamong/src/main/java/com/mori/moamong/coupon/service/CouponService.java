package com.mori.moamong.coupon.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.coupon.mapper.CouponMapper;

@RequiredArgsConstructor
@Service
public class CouponService {
    private final CouponMapper couponMapper;

}
