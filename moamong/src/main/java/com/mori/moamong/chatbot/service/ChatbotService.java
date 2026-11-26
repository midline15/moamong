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

	private static final String SYSTEM_PROMPT = "당신은 감성 선물·커스텀 패키지 전문 편집숍 '모아몽(MOAMONG)'의 친절한 AI 컨시어지입니다. "
			+ "[모아몽 핵심 안내] "
			+ "1. 배송 정책: 30,000원 이상 구매 시 무료배송이며, 미만 시 기본 배송비 3,000원이 부과됩니다. "
			+ "2. 선물키트(커스텀 패키지): 대상별(가족, 연인, 친구, 동료, 나에게) 및 목적별(생일·기념일, 감사·답례, 축하·응원, 위로·격려, 마음전달) 패키지를 선택하고 원하는 메시지 카드 문구를 동봉할 수 있습니다. "
			+ "3. 주문/취소/반품: 결제 완료 상태에서는 마이페이지 주문 내역에서 즉시 취소가 가능하며, 상품 수령 후 마이페이지에서 별점·사진 리뷰를 작성할 수 있습니다. "
			+ "4. 응대 원칙: 이전 대화 맥락을 기억해 자연스럽게 이어서 답변하고, 선물 추천 요청 시 예산대와 받는 사람에 맞춰 센스 있는 조합과 이유를 3~4문장 이내로 다정하고 읽기 쉽게 한국어로 안내하세요.";


	// 생성자: 시스템 프롬프트를 포함한 Spring AI ChatClient 초기화
	public ChatbotService(ChatbotMapper chatbotMapper, ChatClient.Builder builder) {
		this.chatbotMapper = chatbotMapper;
		this.chatClient = builder.defaultSystem(SYSTEM_PROMPT).build();
	}

	// 활성 상담방 조회 또는 신규 생성 (비로그인 방의 로그인 회원 연동 포함)
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

	// 최근 10개 대화 이력을 Spring AI Message 리스트로 변환
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
	
	// 사용자 메시지 저장 후 AI 응답 생성 및 DB 기록
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

	// 현재 활성 상담방의 전체 대화 내역 조회
	public List<Map<String, Object>> getChatHistory(String sessionKey) {
		Map<String, Object> room = chatbotMapper.selectActiveRoomBySessionKey(sessionKey);
		if (room == null)
			return List.of();
		Long chatbotId = ((Number) room.get("chatbot_id")).longValue();
		return chatbotMapper.selectMessagesByChatbotId(chatbotId);
	}

	// 현재 진행 중인 상담방 종료 처리
	@Transactional
	public void endChatRoom(String sessionKey) {
		chatbotMapper.closeChatRoom(sessionKey);
	}
}

