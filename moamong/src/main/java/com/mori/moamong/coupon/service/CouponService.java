package com.mori.moamong.coupon.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.mori.moamong.coupon.mapper.CouponMapper;
import com.mori.moamong.dto.Coupon;

@Service
public class CouponService {

	@Autowired
	CouponMapper couponMapper;

	// 마이페이지 쿠폰 조회 - 수정하지 않음
	public HashMap<String, Object> geCouponList(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		List<Coupon> list = couponMapper.selectCouponList(map);

		result.put("list", list);
		result.put("result", "success");

		return result;
	}

	// 관리자 쿠폰 목록
	public HashMap<String, Object> getCouponList(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		List<Coupon> list = couponMapper.selectAdminCouponList(map);
		int count = couponMapper.selectAdminCouponCount(map);

		result.put("list", list);
		result.put("count", count);
		result.put("result", "success");

		return result;
	}

	// 관리자 쿠폰 상세
	public HashMap<String, Object> getCoupon(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		Coupon coupon = couponMapper.selectAdminCoupon(map);

		if (coupon == null) {
			result.put("result", "fail");
			result.put("message", "쿠폰 정보를 찾을 수 없습니다.");
			return result;
		}

		result.put("coupon", coupon);
		result.put("result", "success");

		return result;
	}

	// 쿠폰 등록
	public HashMap<String, Object> addCoupon(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		if ("FIXED".equals(map.get("discountType"))) {
			map.put("maximumDiscountAmount", null);
		}

		map.put("issueType", "MANUAL");
		map.put("issueStatus", "ACTIVE");

		int count = couponMapper.insertCoupon(map);

		result.put("result", count > 0 ? "success" : "fail");
		result.put("message", count > 0 ? "쿠폰이 등록되었습니다." : "쿠폰 등록에 실패했습니다.");

		return result;
	}

	// 쿠폰 삭제 - 발급 이력이 없어야 삭제 가능
	@Transactional(rollbackFor = Exception.class)
	public HashMap<String, Object> removeCoupon(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		int issuedCount = couponMapper.selectIssuedMemberCount(map);

		if (issuedCount > 0) {
			result.put("result", "fail");
			result.put("message", "발급 이력이 있는 쿠폰은 삭제할 수 없습니다. 회수 관리 화면을 이용하세요.");
			return result;
		}

		int count = couponMapper.deleteCoupon(map);

		result.put("result", count > 0 ? "success" : "fail");
		result.put("message", count > 0 ? "쿠폰이 삭제되었습니다." : "쿠폰 삭제에 실패했습니다.");

		return result;
	}

	// 쿠폰 수정 - 발급 이력이 없어야 수정 가능
	@Transactional(rollbackFor = Exception.class)
	public HashMap<String, Object> editCoupon(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		int issuedCount = couponMapper.selectIssuedMemberCount(map);

		if (issuedCount > 0) {
			result.put("result", "fail");
			result.put("message", "발급 이력이 있는 쿠폰은 수정할 수 없습니다.");
			return result;
		}

		if ("FIXED".equals(map.get("discountType"))) {
			map.put("maximumDiscountAmount", null);
		}

		int count = couponMapper.updateCoupon(map);

		result.put("result", count > 0 ? "success" : "fail");
		result.put("message", count > 0 ? "쿠폰이 수정되었습니다." : "쿠폰 수정에 실패했습니다.");

		return result;
	}

	// 회원 검색
	public HashMap<String, Object> searchMember(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		List<HashMap<String, Object>> list = couponMapper.selectMemberList(map);

		result.put("list", list);
		result.put("result", "success");

		return result;
	}

	// 쿠폰 발급

	// 쿠폰 발급
	@Transactional(rollbackFor = Exception.class)
	public HashMap<String, Object> issueCoupon(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		if (map.get("couponId") == null || map.get("couponId").toString().isBlank()) {
			result.put("result", "fail");
			result.put("message", "쿠폰을 선택하세요.");
			return result;
		}

		Coupon coupon = couponMapper.selectAdminCoupon(map);

		if (coupon == null || !"ACTIVE".equals(coupon.getIssueStatus())) {
			result.put("result", "fail");
			result.put("message", "발급할 수 없는 쿠폰입니다.");
			return result;
		}

		if (coupon.getValidUntil() == null || coupon.getValidUntil().isBefore(LocalDateTime.now())) {
			result.put("result", "fail");
			result.put("message", "사용 기간이 만료된 쿠폰입니다.");
			return result;
		}

		int targetCount = 0;
		int issuedCount = 0;

		if ("ALL".equals(map.get("issueType"))) {

			// 전체 회원 발급
			targetCount = couponMapper.selectMemberCount();

			if (targetCount == 0) {
				result.put("result", "fail");
				result.put("message", "발급 대상 회원이 없습니다.");
				return result;
			}

			issuedCount = couponMapper.insertCouponAllMember(map);

		} else if ("SELECT".equals(map.get("issueType"))) {

			// 선택 회원 발급
			List<Long> memberIds = new ArrayList<>();

			Object memberIdsObj = map.get("memberIds");

			if (memberIdsObj instanceof List<?>) {
				for (Object id : (List<?>) memberIdsObj) {
					if (id != null) {
						memberIds.add(Long.parseLong(id.toString()));
					}
				}
			} else if (memberIdsObj != null) {
				String[] ids = memberIdsObj.toString().split(",");

				for (String id : ids) {
					if (!id.trim().isEmpty()) {
						memberIds.add(Long.parseLong(id.trim()));
					}
				}
			}

			memberIds = memberIds.stream().distinct().collect(Collectors.toList());

			if (memberIds.isEmpty()) {
				result.put("result", "fail");
				result.put("message", "발급할 회원을 선택하세요.");
				return result;
			}

			map.put("memberIds", memberIds);

			targetCount = couponMapper.selectSelectedMemberCount(map);

			if (targetCount == 0) {
				result.put("result", "fail");
				result.put("message", "발급 대상 회원이 없습니다.");
				return result;
			}

			issuedCount = couponMapper.insertCouponSelectedMember(map);

		} else {
			result.put("result", "fail");
			result.put("message", "발급 대상을 확인하세요.");
			return result;
		}

		// 발급되지 않은 회원 수
		int duplicateCount = Math.max(0, targetCount - issuedCount);

		result.put("issuedCount", issuedCount);
		result.put("duplicateCount", duplicateCount);

		// 신규 발급 건수가 없는 경우
		if (issuedCount == 0) {
			result.put("result", "fail");
			result.put("message", "발급 가능한 회원이 없습니다. 이미 발급했거나 회수한 쿠폰은 재발급할 수 없습니다.");
			return result;
		}

		result.put("result", "success");

		if (duplicateCount > 0) {
			result.put("message", issuedCount + "건 발급 완료, " + duplicateCount + "건은 기존 발급 이력으로 제외되었습니다.");
		} else {
			result.put("message", issuedCount + "건의 쿠폰 발급이 완료되었습니다.");
		}

		return result;
	}

	// 쿠폰 발급 회원 목록
	public HashMap<String, Object> getIssuedMemberList(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		List<Coupon> list = couponMapper.selectIssuedMemberList(map);
		Coupon coupon = couponMapper.selectAdminCoupon(map);

		if (coupon == null) {
			result.put("result", "fail");
			result.put("message", "쿠폰 정보를 찾을 수 없습니다.");
			return result;
		}

		result.put("coupon", coupon);
		result.put("list", list);
		result.put("result", "success");

		return result;
	}

	// 회원 쿠폰 개별 회수
	@Transactional(rollbackFor = Exception.class)
	public HashMap<String, Object> revokeMemberCoupon(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		int count = couponMapper.revokeMemberCoupon(map);

		result.put("result", count > 0 ? "success" : "fail");
		result.put("message", count > 0 ? "쿠폰이 회수되었습니다." : "회수할 수 없는 쿠폰입니다.");

		return result;
	}

	// 사용 가능한 쿠폰 일괄 회수
	@Transactional(rollbackFor = Exception.class)
	public HashMap<String, Object> revokeAllMemberCoupon(HashMap<String, Object> map) {

		HashMap<String, Object> result = new HashMap<>();

		int count = couponMapper.revokeAllMemberCoupon(map);

		result.put("result", "success");
		result.put("revokedCount", count);
		result.put("message", count + "건의 쿠폰이 회수되었습니다.");

		return result;
	}
}