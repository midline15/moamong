package com.mori.moamong.notification.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import com.mori.moamong.notification.service.NotificationService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Controller
public class NotificationController {

	private final NotificationService notificationService;

	private Long getLoginMemberId(HttpSession session) {
		Object sid = session.getAttribute("sessionId");
		return sid == null ? null : Long.parseLong(String.valueOf(sid));
	}

	private List<Long> parseIds(String idsStr) {
		List<Long> list = new ArrayList<>();
		if (idsStr == null || idsStr.trim().isEmpty()) return list;
		for (String s : idsStr.split(",")) {
			if (!s.trim().isEmpty()) list.add(Long.parseLong(s.trim()));
		}
		return list;
	}

	// 전체 알림 페이지 이동
	@RequestMapping("/notification/list.do")
	public String notificationListPage(HttpSession session) {
		if (getLoginMemberId(session) == null) return "redirect:/member/login.do";
		return "/notification/notificationList";
	}

	// 헤더 소형 창 데이터 조회 (.dox)
	@RequestMapping(value = "/notification/popover.dox", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String, Object> popover(HttpSession session) {
		Long memberId = getLoginMemberId(session);
		if (memberId == null) return new HashMap<>(java.util.Map.of("result", "unauth"));
		return notificationService.getPopoverData(memberId);
	}

	// 탭별 전체 알림 목록 조회 (.dox)
	@RequestMapping(value = "/notification/list.dox", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String, Object> list(@RequestParam(defaultValue = "ALL") String tab, HttpSession session) {
		Long memberId = getLoginMemberId(session);
		if (memberId == null) return new HashMap<>(java.util.Map.of("result", "unauth"));
		return notificationService.getListByTab(memberId, tab);
	}

	// 단건 읽음 / 전체 읽음 / 중요(찜) / 휴지통 / 복원 / 영구삭제 처리 (.dox)
	@RequestMapping(value = "/notification/action.dox", method = RequestMethod.POST)
	@ResponseBody
	public HashMap<String, Object> action(
			@RequestParam String type,
			@RequestParam(required = false) Long notificationId,
			@RequestParam(required = false) String ids,
			@RequestParam(required = false) String isImportant,
			HttpSession session) {
		HashMap<String, Object> res = new HashMap<>();
		Long memberId = getLoginMemberId(session);
		if (memberId == null) {
			res.put("result", "fail");
			return res;
		}
		switch (type) {
			case "READ_ONE" -> notificationService.readOne(memberId, notificationId);
			case "READ_ALL" -> notificationService.readAll(memberId);
			case "IMPORTANT" -> notificationService.setImportant(memberId, parseIds(ids), isImportant);
			case "TRASH" -> notificationService.moveToTrash(memberId, parseIds(ids));
			case "TRASH_ALL" -> notificationService.moveAllToTrash(memberId);
			case "RESTORE" -> notificationService.restoreFromTrash(memberId, parseIds(ids));
			case "DELETE_PERM" -> notificationService.deletePermanent(memberId, parseIds(ids));
		}
		res.put("result", "success");
		return res;
	}
}
