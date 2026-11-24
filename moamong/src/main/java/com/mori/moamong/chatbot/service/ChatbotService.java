package com.mori.moamong.chatbot.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.mori.moamong.chatbot.mapper.ChatbotMapper;

@Service
public class ChatbotService {

	private final ChatbotMapper chatbotMapper;
	private final ChatClient chatClient;

	private static final String SYSTEM_PROMPT = "당신은 선물·커스텀 패키지 전문 쇼핑몰 '모아몽(MOAMONG)'의 친절한 AI 상담원입니다. "
			+ "배송비는 30,000원 이상 구매 시 무료이며, 미만 시 3,000원입니다. " + "커스텀 패키지는 원하는 상품과 선물 박스, 메시지 카드를 조합해 주문할 수 있습니다. "
			+ "이전 대화 맥락을 기억하여 자연스럽게 이어서 답변하고, 3~4문장 이내로 친절하게 한국어로 안내하세요.";

	public ChatbotService(ChatbotMapper chatbotMapper, ChatClient.Builder builder) {
		this.chatbotMapper = chatbotMapper;
		this.chatClient = builder.defaultSystem(SYSTEM_PROMPT).build();
	}

	@Transactional
	public Long getOrCreateRoom(String sessionKey, Long memberId) {
		Map<String, Object> room = chatbotMapper.selectActiveRoomBySessionKey(sessionKey);
		if (room != null) {
			Long chatbotId = ((Number) room.get("chatbot_id")).longValue();
			if (memberId != null && room.get("member_id") == null) {
				chatbotMapper.updateRoomMemberId(chatbotId, memberId);
			}
			return chatbotId;
		}
		Map<String, Object> newRoom = new HashMap<>();
		newRoom.put("memberId", memberId);
		newRoom.put("sessionKey", sessionKey);
		chatbotMapper.insertChatRoom(newRoom);
		return ((Number) newRoom.get("chatbot_id")).longValue();
	}

	private List<Message> buildRecentHistory(Long chatbotId) {
		List<Map<String, Object>> rows = chatbotMapper.selectMessagesByChatbotId(chatbotId);
		int start = Math.max(0, rows.size() - 10);
		List<Message> history = new ArrayList<>();
		for (int i = start; i < rows.size(); i++) {
			Map<String, Object> row = rows.get(i);
			String sender = String.valueOf(row.get("sender_type"));
			String content = String.valueOf(row.get("message_content"));
			if ("USER".equals(sender)) {
				history.add(new UserMessage(content));
			} else {
				history.add(new AssistantMessage(content));
			}
		}
		return history;
	}

	@Transactional
	public Map<String, Object> sendMessage(String sessionKey, Long memberId, String userMsg) {
		Long chatbotId = getOrCreateRoom(sessionKey, memberId);
		List<Message> history = buildRecentHistory(chatbotId);

		Map<String, Object> userParam = new HashMap<>();
		userParam.put("chatbotId", chatbotId);
		userParam.put("senderType", "USER");
		userParam.put("messageContent", userMsg);
		chatbotMapper.insertChatMessage(userParam);

		String botReply = chatClient.prompt().messages(history).user(userMsg).call().content();

		Map<String, Object> botParam = new HashMap<>();
		botParam.put("chatbotId", chatbotId);
		botParam.put("senderType", "BOT");
		botParam.put("messageContent", botReply);
		chatbotMapper.insertChatMessage(botParam);

		Map<String, Object> result = new HashMap<>();
		result.put("chatbotId", chatbotId);
		result.put("reply", botReply);
		return result;
	}

	public List<Map<String, Object>> getChatHistory(String sessionKey) {
		Map<String, Object> room = chatbotMapper.selectActiveRoomBySessionKey(sessionKey);
		if (room == null)
			return List.of();
		Long chatbotId = ((Number) room.get("chatbot_id")).longValue();
		return chatbotMapper.selectMessagesByChatbotId(chatbotId);
	}

	@Transactional
	public void endChatRoom(String sessionKey) {
		chatbotMapper.closeChatRoom(sessionKey);
	}
}
