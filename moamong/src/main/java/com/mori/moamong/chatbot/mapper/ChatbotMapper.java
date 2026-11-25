package com.mori.moamong.chatbot.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ChatbotMapper {

	// 세션 키로 현재 진행 중인(ACTIVE) 챗봇 상담방 조회
	Map<String, Object> selectActiveRoomBySessionKey(@Param("sessionKey") String sessionKey);

	// 신규 챗봇 상담방 생성
	int insertChatRoom(Map<String, Object> param);

	// 비로그인 상담방에 로그인 회원 번호(member_id) 연동
	int updateRoomMemberId(@Param("chatbotId") Long chatbotId, @Param("memberId") Long memberId);

	// 챗봇 대화 메시지 1건 저장
	int insertChatMessage(Map<String, Object> param);

	// 상담방 번호로 전체 대화 이력 오름차순 조회
	List<Map<String, Object>> selectMessagesByChatbotId(@Param("chatbotId") Long chatbotId);

	// 상담 종료 처리 (상태를 ENDED로 변경 및 종료 일시 기록)
	int closeChatRoom(@Param("sessionKey") String sessionKey);
}
