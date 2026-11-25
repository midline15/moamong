package com.mori.moamong.member.mapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Member;

@Mapper
public interface MemberMapper {
		// 전체 회원 목록 조회
		List<Map<String, Object>> findAll();

		// 로그인 아이디로 회원 단건 조회
		Member selectMember(HashMap<String, Object> map);

		// 아이디 중복 확인
		int idDuplicateCheck(HashMap<String, Object> map);

		// 이메일 중복 확인
		int emailDuplicateCheck(HashMap<String, Object> map);

		// 전화번호 중복 확인
		int phoneDuplicateCheck(HashMap<String, Object> map);

		// 일반 회원가입
		int insertMember(HashMap<String, Object> map);

		// 회원번호(PK)로 내 정보 상세 조회
		Member selectMemberById(Long memberId);

		// 내 정보 수정 (이름, 이메일, 휴대폰 번호)
		int updateMemberInfo(HashMap<String, Object> map);

		// 비밀번호 변경
		int updatePassword(HashMap<String, Object> map);

		// 회원 탈퇴 (상태 WITHDRAWN 변경 및 탈퇴일시 기록)
		int withdrawMember(Long memberId);

		// 소셜 로그인 기존 회원 조회
		Member selectMemberBySocial(HashMap<String, Object> map);

		// 소셜 로그인 최초 가입
		int insertSocialMember(HashMap<String, Object> map);

		// 아이디 찾기 (이름 + 이메일)
		Member selectMemberByNameAndEmail(HashMap<String, Object> map);

		// 비밀번호 재설정 본인 확인 (아이디 + 이름 + 이메일)
		Member selectMemberForPasswordReset(HashMap<String, Object> map);

		// 최종 로그인 일시 갱신
		int updateLastLoginAt(Long memberId);

		// 30일 미접속 활성 회원 휴면(INACTIVE) 일괄 전환
		int updateInactiveMembers(int days);

		// 휴면 계정 해제 (INACTIVE -> ACTIVE + last_login_at 갱신)
		int activateDormantMember(Long memberId);
		
		// 회원가입용 활성 약관 목록 조회
		List<HashMap<String, Object>> selectJoinPolicies();

}
