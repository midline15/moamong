package com.mori.moamong.notification.service;

import java.util.HashMap;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.mori.moamong.notification.mapper.NotificationMapper;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class NotificationService {

	private final NotificationMapper notificationMapper;

	// 타 서비스(주문, 쿠폰, 문의 등)에서 호출할 공통 알림 발송 메서드
	@Transactional
	public void sendNotification(Long memberId, String type, String title, String content, Long relatedId) {
		if (memberId == null) return;
		HashMap<String, Object> map = new HashMap<>();
		map.put("memberId", memberId);
		map.put("notificationType", type);
		map.put("notificationTitle", title);
		map.put("notificationContent", content);
		map.put("relatedId", relatedId);
		notificationMapper.insertNotification(map);
	}

	// 헤더 소형 창 데이터 조회 (최신 3건 + 카운트)
	public HashMap<String, Object> getPopoverData(Long memberId) {
		HashMap<String, Object> res = new HashMap<>();
		res.put("result", "success");
		res.put("recentList", notificationMapper.selectRecentNotifications(memberId));
		res.put("counts", notificationMapper.selectNotificationCounts(memberId));
		return res;
	}

	// 전체 알림 페이지 탭별 목록 조회
	public HashMap<String, Object> getListByTab(Long memberId, String tab) {
		HashMap<String, Object> res = new HashMap<>();
		res.put("result", "success");
		res.put("list", notificationMapper.selectNotificationList(memberId, tab));
		res.put("counts", notificationMapper.selectNotificationCounts(memberId));
		return res;
	}

	@Transactional
	public void readOne(Long memberId, Long notificationId) {
		notificationMapper.markAsRead(memberId, notificationId);
	}

	@Transactional
	public void readAll(Long memberId) {
		notificationMapper.markAllAsRead(memberId);
	}

	@Transactional
	public void setImportant(Long memberId, List<Long> ids, String isImportant) {
		if (ids != null && !ids.isEmpty()) {
			notificationMapper.updateImportant(memberId, ids, isImportant);
		}
	}

	@Transactional
	public void moveToTrash(Long memberId, List<Long> ids) {
		if (ids != null && !ids.isEmpty()) {
			notificationMapper.moveToTrash(memberId, ids);
		}
	}

	@Transactional
	public void moveAllToTrash(Long memberId) {
		notificationMapper.moveAllToTrash(memberId);
	}

	@Transactional
	public void restoreFromTrash(Long memberId, List<Long> ids) {
		notificationMapper.restoreFromTrash(memberId, ids);
	}

	@Transactional
	public void deletePermanent(Long memberId, List<Long> ids) {
		notificationMapper.deletePermanent(memberId, ids);
	}
}
