
package com.mori.moamong.review.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Review;
import com.mori.moamong.dto.ReviewImage;

@Mapper
public interface ReviewMapper {

    // 나의 리뷰 목록 조회
    List<Review> selectMyReviewList(HashMap<String, Object> map);

    // 나의 리뷰 개수 조회
    int selectMyReviewCount(HashMap<String, Object> map);

    // 특정 리뷰 조회
    Review selectReview(HashMap<String, Object> map);

    // 리뷰 이미지 목록 조회
    List<ReviewImage> selectReviewImageList(HashMap<String, Object> map);

    // 리뷰 내용 및 별점 수정
    int updateReview(HashMap<String, Object> map);

    // 선택한 기존 이미지 삭제
    int deleteReviewImage(HashMap<String, Object> map);

    // 새로운 이미지 등록
    int insertReviewImage(HashMap<String, Object> map);

    // 리뷰에 연결된 이미지 전체 삭제
    int deleteReviewImageAll(HashMap<String, Object> map);

    // 리뷰 삭제
    int deleteReview(HashMap<String, Object> map);

    // 상품 또는 패키지 리뷰 목록 조회
    List<Review> selectReviewList(HashMap<String, Object> map);

    // 리뷰 전체 개수 조회
    int selectReviewCount(HashMap<String, Object> map);
}
