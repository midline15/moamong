package com.mori.moamong.coupon.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Coupon;

@Mapper
public interface CouponMapper {
	List<Coupon> selectCouponList (HashMap<String, Object>map);
}
