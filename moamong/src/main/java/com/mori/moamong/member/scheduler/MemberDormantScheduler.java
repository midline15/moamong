// package com.mori.moamong.member.scheduler;

// import org.springframework.boot.context.event.ApplicationReadyEvent;
// import org.springframework.context.event.EventListener;
// import org.springframework.scheduling.annotation.Scheduled;
// import org.springframework.stereotype.Component;

// import com.mori.moamong.member.mapper.MemberMapper;

// import lombok.RequiredArgsConstructor;

// @Component
// @RequiredArgsConstructor
// public class MemberDormantScheduler {

// 	private final MemberMapper memberMapper;
// 	private static final int INACTIVE_DAYS = 30; // 시연용 30일 기준

// 	// 서버 시작 시 1회 즉시 점검 (시연 테스트용)
// 	@EventListener(ApplicationReadyEvent.class)
// 	public void runOnStartup() {
// 		convertInactiveMembers();
// 	}

// 	// 매일 새벽 2시 정각 자동 실행
// 	@Scheduled(cron = "0 0 2 * * *")
// 	public void convertInactiveMembers() {
// 		int count = memberMapper.updateInactiveMembers(INACTIVE_DAYS);
// 		System.out.println(">>> [휴면계정 전환] 30일 이상 미접속 회원 " + count + "명 INACTIVE 처리 완료");
// 	}
// }
