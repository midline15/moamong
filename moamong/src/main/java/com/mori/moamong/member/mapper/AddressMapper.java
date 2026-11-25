package com.mori.moamong.member.mapper;

import java.util.HashMap;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AddressMapper {
	// 회원 번호로 내 배송지 전체 목록 조회
    List<HashMap<String, Object>> selectAddressList(Long memberId);

    // 배송지 단건 상세 조회 (본인 소유 검증)
    HashMap<String, Object> selectAddressOne(HashMap<String, Object> map);

    // 기본 배송지 1건 조회
    HashMap<String, Object> selectDefaultAddress(Long memberId);

    // 회원별 등록된 배송지 총 개수 조회
    int countAddressByMemberId(Long memberId);

    // 기존 기본 배송지 해제 (is_default = 0 초기화)
    int resetDefaultAddress(Long memberId);

    // 특정 배송지를 기본 배송지로 지정 (is_default = 1)
    int updateDefaultAddress(HashMap<String, Object> map);

    // 신규 배송지 등록
    int insertAddress(HashMap<String, Object> map);

    // 기존 배송지 정보 수정
    int updateAddress(HashMap<String, Object> map);

    // 배송지 단건 삭제
    int deleteAddress(HashMap<String, Object> map);

}
