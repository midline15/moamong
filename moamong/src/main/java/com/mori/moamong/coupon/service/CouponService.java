package com.mori.moamong.coupon.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.mori.moamong.coupon.mapper.CouponMapper;
import com.mori.moamong.dto.Coupon;

@Service
public class CouponService {

	@Autowired
	CouponMapper couponMapper;


	// 마이페이지 - 회원별 쿠폰 내역 조회
	

	public HashMap<String, Object> geCouponList(HashMap<String, Object> map) {

		// 화면에 전달할 데이터를 담을 공간입니다.
		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			// 회원 번호를 기준으로 해당 회원이 발급받은 쿠폰 목록을 조회합니다.
			List<Coupon> list = couponMapper.selectCouponList(map);

			// 조회한 쿠폰 목록을 화면에 전달합니다.
			resultMap.put("list", list);

			// 조회 성공 상태를 전달합니다.
			resultMap.put("result", "success");

		} catch (Exception e) {

			// 조회 중 오류가 발생하면 실패 상태를 전달합니다.
			resultMap.put("result", "fail");

			// 화면에서 확인할 오류 메시지를 전달합니다.
			resultMap.put("message", "내 쿠폰 목록 조회에 실패했습니다.");

			// 개발자가 오류 원인을 확인할 수 있도록 출력합니다.
			e.printStackTrace();

		}

		return resultMap;
	}

	
	// 관리자 - 전체 쿠폰 목록 조회


	public HashMap<String, Object> getCouponList(HashMap<String, Object> map) {

		// 화면에 전달할 데이터를 담을 공간입니다.
		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			// COUPON 테이블에 등록된 전체 쿠폰을 조회합니다.
			List<Coupon> list = couponMapper.selectAdminCouponList(map);

			// 조회한 쿠폰 목록을 화면에 전달합니다.
			resultMap.put("list", list);

			// 전체 쿠폰 개수를 조회합니다.
			int count = couponMapper.selectAdminCouponCount(map);

			// 전체 쿠폰 개수를 전달합니다.
			resultMap.put("count", count);

			// 조회 성공 상태를 전달합니다.
			resultMap.put("result", "success");

		} catch (Exception e) {

			resultMap.put("result", "fail");

			resultMap.put("message", "쿠폰 목록 조회에 실패했습니다.");

			e.printStackTrace();

		}

		return resultMap;
	}


	// 관리자 - 쿠폰 상세 조회


	public HashMap<String, Object> getCoupon(HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			// 전달받은 쿠폰 번호를 기준으로 쿠폰 정보를 조회합니다.
			Coupon info = couponMapper.selectAdminCoupon(map);

			// 조회한 쿠폰 정보를 화면에 전달합니다.
			resultMap.put("info", info);
			resultMap.put("result", "success");

		} catch (Exception e) {

			resultMap.put("result", "fail");

			resultMap.put("message", "쿠폰 상세 조회에 실패했습니다.");

			e.printStackTrace();

		}

		return resultMap;
	}

	
	// 관리자 - 쿠폰 등록
	

	public HashMap<String, Object> addCoupon(HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = new HashMap<>();

		try {
			
			// 최대 할인 금액을 입력하지 않았다면 빈 문자열이 전달됩니다.
			// MySQL에는 빈 문자열을 숫자로 저장할 수 없으므로 null로 변경합니다.
			if (map.get("maximumDiscountAmount") == null
					|| map.get("maximumDiscountAmount").toString().trim().isEmpty()) {

				map.put("maximumDiscountAmount", null);

			}
			int cnt = couponMapper.insertCoupon(map);

			// 실제로 등록된 데이터가 있는지 확인합니다.
			if (cnt > 0) {

				// DB에서 자동 생성된 쿠폰 번호를 화면에 전달합니다.
				resultMap.put("couponId", map.get("couponId"));

				resultMap.put("message", "쿠폰이 등록되었습니다.");

				resultMap.put("result", "success");

			} else {

				resultMap.put("message", "쿠폰 등록에 실패했습니다.");

				resultMap.put("result", "fail");

			}

		} catch (Exception e) {

			resultMap.put("result", "fail");

			resultMap.put("message", "쿠폰 등록 중 오류가 발생했습니다.");

			e.printStackTrace();

		}

		return resultMap;
	}

	
	// 관리자 - 쿠폰 삭제
	
	public HashMap<String, Object> removeCoupon(HashMap<String, Object> map) {

		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			// 전달받은 쿠폰 번호에 해당하는 데이터를 삭제합니다.
			int cnt = couponMapper.deleteCoupon(map);

			// 실제 삭제된 데이터가 있는지 확인합니다.
			if (cnt > 0) {

				resultMap.put("message", "쿠폰이 삭제되었습니다.");

				resultMap.put("result", "success");

			} else {

				resultMap.put("message", "삭제할 쿠폰이 존재하지 않습니다.");

				resultMap.put("result", "fail");

			}

		} catch (Exception e) {

			resultMap.put("result", "fail");

			resultMap.put("message", "쿠폰 삭제 중 오류가 발생했습니다.");

			e.printStackTrace();

		}

		return resultMap;
	}

	public HashMap<String, Object> editCoupon(HashMap<String, Object> map) {

		// Controller에 전달할 결과 데이터를 담을 공간입니다.
		HashMap<String, Object> resultMap = new HashMap<>();

		try {

			
			if (map.get("maximumDiscountAmount") == null
					|| map.get("maximumDiscountAmount").toString().trim().isEmpty()) {

				map.put("maximumDiscountAmount", null);
			}

			
	

			// 쿠폰 수정 SQL 실행
			int cnt = couponMapper.updateCoupon(map);

			
			resultMap.put("couponId", map.get("couponId"));
			resultMap.put("message", "쿠폰이 수정되었습니다.");
			resultMap.put("result", "success");
			

			// 실제 변경된 데이터가 몇 건인지 화면에 전달합니다.
			resultMap.put("cnt", cnt);

		} catch (Exception e) {

			
			resultMap.put("result", "fail");

			resultMap.put("message", "쿠폰 수정 중 오류가 발생했습니다.");

			e.printStackTrace();
		}

	
		return resultMap;
	}
}
