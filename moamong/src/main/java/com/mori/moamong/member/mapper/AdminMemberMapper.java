
package com.mori.moamong.member.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Member;

@Mapper
public interface AdminMemberMapper {

	// 회원 목록 조회
	List<Member> selectAdminList(HashMap<String, Object> map);

	// 회원 수 조회
	int selectAdminCount(HashMap<String, Object> map);

	// 회원 통계 조회
	Member selectStats(HashMap<String, Object> map);

	// 회원 상세 조회
	Member selectAdminDetail(HashMap<String, Object> map);

	// 회원 등급 변경
	int updateMemberGrade(HashMap<String, Object> map);

	// 회원 상태 변경
	int updateMemberStatus(HashMap<String, Object> map);

	// 회원 강제 탈퇴
	int withdrawMember(HashMap<String, Object> map);

}
