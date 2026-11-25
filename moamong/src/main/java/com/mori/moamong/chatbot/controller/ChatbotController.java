package com.mori.moamong.chatbot.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

import com.mori.moamong.chatbot.service.ChatbotService;

import jakarta.servlet.http.HttpSession;

@RestController
@RequestMapping("/chatbot")
public class ChatbotController {

	private final ChatbotService chatbotService;

	public ChatbotController(ChatbotService chatbotService) {
		this.chatbotService = chatbotService;
	}

	private Long extractMemberId(HttpSession session) {
		Object idObj = session.getAttribute("sessionId");
		return (idObj instanceof Number) ? ((Number) idObj).longValue() : null;
	}

	@PostMapping("/send.dox")
	public Map<String, Object> sendMessage(@RequestBody Map<String, String> payload, HttpSession session) {
		Map<String, Object> res = new HashMap<>();
		String message = payload.get("message");
		if (message == null || message.trim().isEmpty()) {
			res.put("result", "fail");
			res.put("message", "메시지를 입력해 주세요.");
			return res;
		}
		try {
			Map<String, Object> data = chatbotService.sendMessage(session.getId(), extractMemberId(session),
					message.trim());
			res.put("result", "success");
			res.putAll(data);
		} catch (Exception e) {
			res.put("result", "error");
			res.put("message", "AI 응답 처리 중 오류가 발생했습니다: " + e.getMessage());
		}
		return res;
	}

	@PostMapping("/history.dox")
	public Map<String, Object> getHistory(HttpSession session) {
		Map<String, Object> res = new HashMap<>();
		res.put("result", "success");
		res.put("list", chatbotService.getChatHistory(session.getId()));
		return res;
	}

	@PostMapping("/end.dox")
	public Map<String, Object> endChat(HttpSession session) {
		chatbotService.endChatRoom(session.getId());
		Map<String, Object> res = new HashMap<>();
		res.put("result", "success");
		return res;
	}
	
	@GetMapping("/test.do")
    public ModelAndView chatTestPage() {
        return new ModelAndView("forward:/chatbot/chatTest.jsp");
    }


}
