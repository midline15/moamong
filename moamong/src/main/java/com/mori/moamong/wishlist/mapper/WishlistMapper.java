package com.mori.moamong.wishlist.mapper;

import java.util.HashMap;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface WishlistMapper {

    // 1. 내 찜 목록 조회 (단품 + 패키지 + 썸네일 + 재고/판매상태)
    List<HashMap<String, Object>> selectWishlistByMemberId(@Param("memberId") Long memberId);

    // 2. 특정 상품/패키지 찜 여부 확인 (토글용)
    Long selectWishlistIdByProduct(@Param("memberId") Long memberId, @Param("productId") Long productId);
    Long selectWishlistIdByPackage(@Param("memberId") Long memberId, @Param("packageId") Long packageId);

    // 3. 찜 등록
    int insertWishlist(HashMap<String, Object> map);

    // 4. 찜 삭제 (단건 / 선택 일괄 / 전체 비우기)
    int deleteWishlistById(@Param("wishlistId") Long wishlistId, @Param("memberId") Long memberId);
    int deleteSelectedWishlists(@Param("memberId") Long memberId, @Param("wishlistIds") List<Long> wishlistIds);
    int deleteAllWishlists(@Param("memberId") Long memberId);
}
