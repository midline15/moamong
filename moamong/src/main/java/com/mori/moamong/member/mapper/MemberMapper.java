package com.mori.moamong.member.mapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Member;

@Mapper
public interface MemberMapper {
	List<Map<String, Object>> findAll();

	// 멤버 조회
	Member selectMember(HashMap<String, Object> map);

	// 아이디 중복 확인
	int idDuplicateCheck(HashMap<String, Object> map);

	// 이메일 중복 확인
	int emailDuplicateCheck(HashMap<String, Object> map);

	// 전화번호 중복 확인
	int phoneDuplicateCheck(HashMap<String, Object> map);

	// 회원가입
	int insertMember(HashMap<String, Object> map);

	Member selectMemberById(Long memberId);

	int updateMemberInfo(HashMap<String, Object> map);

	int updatePassword(HashMap<String, Object> map);

	int withdrawMember(Long memberId);

	// 소셜 로그인 기존 회원 조회
	Member selectMemberBySocial(HashMap<String, Object> map);

	// 소셜 로그인 최초 가입
	int insertSocialMember(HashMap<String, Object> map);
	
	// 아이디 찾기 (이름 + 이메일)
	Member selectMemberByNameAndEmail(HashMap<String, Object> map);

	// 비밀번호 재설정 본인 확인 (아이디 + 이름 + 이메일)
	Member selectMemberForPasswordReset(HashMap<String, Object> map);

}
