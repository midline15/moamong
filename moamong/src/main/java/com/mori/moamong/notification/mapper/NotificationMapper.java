package com.mori.moamong.notification.mapper;

import java.util.HashMap;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface NotificationMapper {

	// 알림 등록
	int insertNotification(HashMap<String, Object> map);

	// 헤더 소형 창용 최신 알림 3건 조회
	List<HashMap<String, Object>> selectRecentNotifications(Long memberId);

	// 탭별 알림 전체 목록 조회 (ALL / IMPORTANT / TRASH)
	List<HashMap<String, Object>> selectNotificationList(@Param("memberId") Long memberId, @Param("tab") String tab);

	// 전체 미삭제 개수 및 읽지 않은 개수 조회
	HashMap<String, Object> selectNotificationCounts(Long memberId);

	// 단건 읽음 처리
	int markAsRead(@Param("memberId") Long memberId, @Param("notificationId") Long notificationId);

	// 전체 읽음 처리
	int markAllAsRead(Long memberId);

	// 중요 알림(찜) 일괄 설정
	int updateImportant(@Param("memberId") Long memberId, @Param("ids") List<Long> ids, @Param("isImportant") String isImportant);

	// 선택 알림 휴지통 이동
	int moveToTrash(@Param("memberId") Long memberId, @Param("ids") List<Long> ids);

	// 전체 알림 휴지통 이동
	int moveAllToTrash(Long memberId);

	// 휴지통 복원 (ids가 비어있으면 전체 복원)
	int restoreFromTrash(@Param("memberId") Long memberId, @Param("ids") List<Long> ids);

	// 휴지통 영구 삭제 (ids가 비어있으면 전체 비우기)
	int deletePermanent(@Param("memberId") Long memberId, @Param("ids") List<Long> ids);
}
