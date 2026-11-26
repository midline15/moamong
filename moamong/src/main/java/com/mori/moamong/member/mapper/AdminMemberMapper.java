package com.mori.moamong.member.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Member;



@Mapper
public interface AdminMemberMapper {
	// 회원 목록 조회
	// limit, offset, 검색 조건을 전달받습니다.
	List<Member> selectAdminList(HashMap<String, Object> map);

	// 검색 조건에 맞는 전체 회원 수 조회
	// 페이징에 사용할 전체 데이터 개수를 반환합니다.
	int selectAdminCount(HashMap<String, Object> map);

	// 관리자 페이지 회원 통계 조회
	Member selectStats(HashMap<String, Object> map);

	// 회원 상세정보 조회
	// memberId를 전달하면 해당 회원의 상세정보를 반환합니다.
	Member selectAdminDetail(HashMap<String, Object> map);
}
