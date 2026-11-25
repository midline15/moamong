package com.mori.moamong.coupon.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Coupon;

@Mapper
public interface CouponMapper {

	// 마이페이지 쿠폰 조회 - 기존 기능 유지
	List<Coupon> selectCouponList(HashMap<String, Object> map);

	// 관리자 쿠폰
	List<Coupon> selectAdminCouponList(HashMap<String, Object> map);

	int selectAdminCouponCount(HashMap<String, Object> map);

	Coupon selectAdminCoupon(HashMap<String, Object> map);

	int insertCoupon(HashMap<String, Object> map);

	int deleteCoupon(HashMap<String, Object> map);

	int updateCoupon(HashMap<String, Object> map);

	// 회원 조회 및 발급
	List<HashMap<String, Object>> selectMemberList(HashMap<String, Object> map);

	int selectMemberCount();

	int selectSelectedMemberCount(HashMap<String, Object> map);

	int selectIssuedMemberCount(HashMap<String, Object> map);

	int insertCouponAllMember(HashMap<String, Object> map);

	int insertCouponSelectedMember(HashMap<String, Object> map);

	// 발급 회원 관리
	List<Coupon> selectIssuedMemberList(HashMap<String, Object> map);

	int revokeMemberCoupon(HashMap<String, Object> map);

	int revokeAllMemberCoupon(HashMap<String, Object> map);
}