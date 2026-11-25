package com.mori.moamong.inquiry.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Inquiry;

@Mapper
public interface InquiryMapper {

    // 1:1문의 목록
    List<Inquiry> selectInquiryList(HashMap<String, Object> map);

    // 1:1문의 전체 개수 (페이징용)
    int selectInquiryCnt(HashMap<String, Object> map);

    // 1:1문의 상세
    Inquiry selectInquiry(HashMap<String, Object> map);

    // 1:1문의 등록
    int insertInquiry(HashMap<String, Object> map);

    // 1:1문의 수정
    int updateInquiry(HashMap<String, Object> map);

    // 1:1문의 답변 등록/수정
    int updateInquiryAnswer(HashMap<String, Object> map);

    // 1:1문의 삭제
    int deleteInquiry(HashMap<String, Object> map);
 
    // 1:1문의 이미지 목록
    List<HashMap<String, Object>> selectInquiryImageList(HashMap<String, Object> map);

    // 1:1문의 이미지 등록
    int insertInquiryImage(HashMap<String, Object> map);

    // 1:1문의 이미지 전체 삭제 (문의 기준)
    int deleteInquiryImage(HashMap<String, Object> map);

    // 관리자 여부 확인 (1/0)
    int selectAdminCnt(HashMap<String, Object> map);

}