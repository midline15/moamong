package com.mori.moamong.productInq.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.ProductInq;

@Mapper
public interface ProductInqMapper {

    // 상품 문의 목록 조회
    List<ProductInq> selectProductInqList(HashMap<String, Object> map);

    // 상품 문의 전체 개수 조회
    int selectProductInqCount(HashMap<String, Object> map);

    // 답변완료 문의 개수 조회
    int selectProductInqAnsweredCount(HashMap<String, Object> map);

    // 미답변 문의 개수 조회
    int selectProductInqWaitingCount(HashMap<String, Object> map);

    // 선택한 상태의 문의 개수 조회
    int selectProductInqFilteredCount(HashMap<String, Object> map);

    // 상품 문의 등록
    int insertProductInq(HashMap<String, Object> map);

    // 상품 문의 답변 등록
    int updateProductInqAnswer(HashMap<String, Object> map);

    // 상품 문의 수정
    int updateProductInq(HashMap<String, Object> map);

    // 상품 문의 삭제(논리 삭제)
    int deleteProductInq(HashMap<String, Object> map);

    // 상품 문의 답변 수정
    int updateProductInqAnswerEdit(HashMap<String, Object> map);

    // 상품 문의 답변 삭제
    int deleteProductInqAnswer(HashMap<String, Object> map);
}
