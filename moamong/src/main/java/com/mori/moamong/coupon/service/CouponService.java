package com.mori.moamong.coupon.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.mori.moamong.coupon.mapper.CouponMapper;
import com.mori.moamong.dto.Coupon;

@Service
public class CouponService {

    @Autowired
    CouponMapper couponMapper;

    // 회원별 쿠폰 내역 조회
    public HashMap<String, Object> geCouponList(HashMap<String, Object> map) {
    	HashMap<String, Object> resultMap = new HashMap();
        List<Coupon> list = couponMapper.selectCouponList(map);
        resultMap.put("list", list);
        resultMap.put("result", "success");
        return resultMap;
    }
}
