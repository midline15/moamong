package com.mori.moamong.chatbot.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ChatbotMapper {
	Map<String, Object> selectActiveRoomBySessionKey(@Param("sessionKey") String sessionKey);

	int insertChatRoom(Map<String, Object> param);

	int updateRoomMemberId(@Param("chatbotId") Long chatbotId, @Param("memberId") Long memberId);

	int insertChatMessage(Map<String, Object> param);

	List<Map<String, Object>> selectMessagesByChatbotId(@Param("chatbotId") Long chatbotId);

	int closeChatRoom(@Param("sessionKey") String sessionKey);
}
