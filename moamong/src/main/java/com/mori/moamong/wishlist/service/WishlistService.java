package com.mori.moamong.wishlist.service;

import java.util.HashMap;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.mori.moamong.wishlist.mapper.WishlistMapper;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class WishlistService {

    private final WishlistMapper wishlistMapper;

    // 1. 내 찜 목록 조회 + 판매 가능 여부 가공
    public HashMap<String, Object> getWishlist(Long memberId) {
        HashMap<String, Object> res = new HashMap<>();
        List<HashMap<String, Object>> list = wishlistMapper.selectWishlistByMemberId(memberId);

        for (HashMap<String, Object> item : list) {
            boolean isAvailable = "SELLING".equals(String.valueOf(item.get("itemStatus")));
            if ("PRODUCT".equals(String.valueOf(item.get("itemType")))) {
                int stock = item.get("stockQuantity") != null
                        ? Integer.parseInt(String.valueOf(item.get("stockQuantity")))
                        : 0;
                if (stock <= 0)
                    isAvailable = false;
            }
            item.put("available", isAvailable);
        }

        res.put("result", "success");
        res.put("list", list);
        return res;
    }

    // 2. 찜하기 토글 (이미 찜한 상태면 해제, 아니면 등록)
    @Transactional
    public HashMap<String, Object> toggleWishlist(Long memberId, Long productId, Long packageId) {
        HashMap<String, Object> res = new HashMap<>();

        if ((productId == null && packageId == null) || (productId != null && packageId != null)) {
            res.put("result", "fail");
            res.put("message", "단품 또는 패키지 중 하나만 지정해야 합니다.");
            return res;
        }

        Long existingId = (productId != null) ? wishlistMapper.selectWishlistIdByProduct(memberId, productId)
                : wishlistMapper.selectWishlistIdByPackage(memberId, packageId);

        if (existingId != null) {
            wishlistMapper.deleteWishlistById(existingId, memberId);
            res.put("result", "success");
            res.put("wished", false);
            res.put("message", "찜 목록에서 해제되었습니다.");
        } else {
            HashMap<String, Object> param = new HashMap<>();
            param.put("memberId", memberId);
            param.put("productId", productId);
            param.put("packageId", packageId);
            wishlistMapper.insertWishlist(param);

            res.put("result", "success");
            res.put("wished", true);
            res.put("message", "찜 목록에 추가되었습니다.");
        }
        return res;
    }

    // 3. 개별 삭제 / 선택 삭제 / 전체 비우기
    @Transactional
    public int removeWishlist(Long memberId, Long wishlistId) {
        return wishlistMapper.deleteWishlistById(wishlistId, memberId);
    }

    @Transactional
    public int removeSelectedWishlists(Long memberId, List<Long> wishlistIds) {
        if (wishlistIds == null || wishlistIds.isEmpty())
            return 0;
        return wishlistMapper.deleteSelectedWishlists(memberId, wishlistIds);
    }

    @Transactional
    public int deleteAllWishlists(Long memberId) {
        return wishlistMapper.deleteAllWishlists(memberId);
    }

    /////////////////////////////////////////////////////////////////////////
    // 찜 여부 조회
    public HashMap<String, Object> getWishlistStatus(Long memberId, HashMap<String, Object> map) {

        HashMap<String, Object> res = new HashMap<>();

        try {

            Long existingId = null;

            if (map.get("productId") != null) {
                Long productId = Long.valueOf(map.get("productId").toString());
                existingId = wishlistMapper.selectWishlistIdByProduct(memberId, productId);

            } else if (map.get("packageId") != null) {
                Long packageId = Long.valueOf(map.get("packageId").toString());
                existingId = wishlistMapper.selectWishlistIdByPackage(memberId, packageId);
            }

            res.put("result", "success");
            res.put("wished", existingId != null);

        } catch (Exception e) {
            e.printStackTrace();

            res.put("result", "fail");
            res.put("message", "찜 여부 조회 중 오류가 발생했습니다.");
        }

        return res;
    }
}
