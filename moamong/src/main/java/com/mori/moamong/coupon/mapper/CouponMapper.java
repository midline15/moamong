
package com.mori.moamong.coupon.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Coupon;

@Mapper
public interface CouponMapper {

	// 마이페이지 - 회원별 쿠폰 목록 조회

	List<Coupon> selectCouponList(HashMap<String, Object> map);

	// 관리자 - 전체 쿠폰 목록 조회

	List<Coupon> selectAdminCouponList(HashMap<String, Object> map);

	// 관리자 - 전체 쿠폰 개수 조회

	int selectAdminCouponCount(HashMap<String, Object> map);

	// 관리자 - 쿠폰 상세 조회

	Coupon selectAdminCoupon(HashMap<String, Object> map);

	// 관리자 - 쿠폰 등록

	int insertCoupon(HashMap<String, Object> map);

	// 관리자 - 쿠폰 삭제

	int deleteCoupon(HashMap<String, Object> map);
	
	// 관리자 - 쿠폰 수정

	int updateCoupon(HashMap<String, Object> map);

}
