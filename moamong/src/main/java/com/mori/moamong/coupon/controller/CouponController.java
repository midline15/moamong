package com.mori.moamong.coupon.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.coupon.service.CouponService;

@RequiredArgsConstructor
@Controller
public class CouponController {
    private final CouponService couponService;

}
