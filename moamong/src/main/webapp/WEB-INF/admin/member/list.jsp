<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">

		<title>회원 목록</title>

		<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
		<script src="/js/page-change.js"></script>

		<link rel="stylesheet" href="/css/admin/default.css">
		<link rel="stylesheet" href="/css/admin/member/list.css">
	</head>

	<body>

		<!-- 상단 헤더 -->
		<header class="header">
			<div class="logo">
				Logo
			</div>
		</header>

		<!-- Vue 영역 -->
		<div id="app">

			<div class="admin-container">

				<!-- 사이드바 -->
				<aside class="sidebar">

					<div class="sidebar-title">
						관리자 페이지
					</div>

					<ul>
						<li class="active">
							회원 관리
						</li>
						<li>상품조회 / 등록</li>
						<li>주문 관리</li>
						<li>배송 관리</li>
						<li>재고 관리</li>
						<li>거래처 관리</li>
						<li>리뷰 및 문의</li>
						<li onclick="location.href='/admin/coupon/list.do'">
							쿠폰 관리
						</li>
						<li onclick="location.href='/admin/event/list.do'">
							이벤트 관리
						</li>
						<li onclick="location.href='/admin/policy/list.do'">
							운영정책 관리
						</li>
						<li>매출 통계</li>
					</ul>

				</aside>

				<!-- 메인 콘텐츠 -->
				<main class="main-content">

					<div class="page-title">
						<h3>회원 목록</h3>
					</div>

					<div class="breadcrumb">
						회원 관리 / 회원 목록
					</div>

					<div class="content-area">

						<!-- 1. 회원 통계 -->
						<div class="member-stats">

							<div class="stats-card">
								<div class="stats-title">전체 회원</div>
								<div class="stats-value">
									<span><strong>{{ memberStats.totalCount }}</strong>명</span>
								</div>
							</div>

							<div class="stats-card">
								<div class="stats-title">오늘 가입</div>
								<div class="stats-value">
									<span><strong>{{ memberStats.todayCount }}</strong>명</span>
								</div>
							</div>

							<div class="stats-card">
								<div class="stats-title">활성 회원</div>
								<div class="stats-value">
									<span><strong>{{ memberStats.activeCount }}</strong>명</span>
								</div>
							</div>

							<div class="stats-card">
								<div class="stats-title">휴면 회원</div>
								<div class="stats-value">
									<span><strong>{{ memberStats.dormantCount }}</strong>명</span>
								</div>
							</div>

						</div>

						<!-- 2. 회원 검색 -->
						<div class="member-search">

							<h3>회원 검색</h3>

							<div class="search-row">

								<!-- 검색어 -->
								<div class="search-item">
									<label>검색어</label>
									<input type="text" v-model="keyword" placeholder="이름 또는 아이디 또는 이메일"
										@keyup.enter="fnSearch">
								</div>

								<!-- 회원 등급 -->
								<div class="search-item">
									<label>회원 등급</label>

									<select v-model="searchGrade">
										<option value="">전체 등급</option>
										<option value="VIP">VIP</option>
										<option value="GOLD">GOLD</option>
										<option value="SILVER">SILVER</option>
										<option value="BRONZE">BRONZE</option>
									</select>
								</div>

								<!-- 회원 상태 -->
								<div class="search-item">
									<label>회원 상태</label>

									<select v-model="searchStatus">
										<option value="">전체 상태</option>
										<option value="ACTIVE">정상</option>
										<option value="SUSPENDED">정지</option>
										<option value="WITHDRAWN">탈퇴</option>
										<option value="INACTIVE">휴면</option>
									</select>
								</div>

								<!-- 가입 기간 -->
								<div class="search-item">
									<label>가입일</label>

									<select v-model="searchPeriod">
										<option value="">기간 선택</option>
										<option value="today">오늘</option>
										<option value="week">최근 7일</option>
										<option value="month">최근 30일</option>
									</select>
								</div>

							</div>

							<!-- 검색 버튼 -->
							<div class="search-buttons">

								<button class="btn-reset" @click="fnReset">
									초기화
								</button>

								<button class="btn-search" @click="fnSearch">
									검색
								</button>

							</div>

						</div>

						<!-- 3. 회원 목록 -->
						<div class="member-list">

							<div class="list-header">
								<h3>회원 목록</h3>
								<span>
									총 {{ totalCount }}명
								</span>
							</div>

							<table class="member-table">

								<thead>
									<tr>
										<th>회원 정보</th>
										<th>연락처</th>
										<th>회원 등급</th>
										<th>누적 구매 금액</th>
										<th>가입일</th>
										<th>상태</th>
										<th>관리</th>
									</tr>
								</thead>

								<tbody>

									<tr v-for="member in memberList" :key="member.memberId">

										<!-- 회원 정보 -->
										<td class="member-info">
											<strong>{{ member.memberName || '-' }}</strong>
											<span>{{ member.loginId || '-' }}</span>
										</td>

										<!-- 연락처 -->
										<td>
											{{ member.phone || '-' }}
										</td>

										<!-- 회원 등급 -->
										<td>
											<span class="grade-badge" :class="fnGradeClass(member.memberGrade)">
												{{ member.memberGrade || '-' }}
											</span>
										</td>

										<!-- 누적 구매 금액 -->
										<td>
											{{ fnFormatNumber(member.totalPayment) }}원
										</td>

										<!-- 가입일 -->
										<td>
											{{ member.createdAt || '-' }}
										</td>

										<!-- 회원 상태 -->
										<td>
											<span class="status-badge" :class="fnStatusClass(member.status)">
												{{ fnStatusName(member.status) }}
											</span>
										</td>

										<!-- 상세 페이지 이동 -->
										<td>
											<button class="btn-detail" @click="fnEdit(member.memberId)">
												상세보기
											</button>
										</td>

									</tr>

									<!-- 조회 결과 없음 -->
									<tr v-if="memberList.length === 0">
										<td colspan="7">
											조회된 회원이 없습니다.
										</td>
									</tr>

								</tbody>

							</table>

							<!-- 페이지 이동 -->
							<div class="pagination">

								<button @click="fnPage(1)" :disabled="currentPage == 1">
									처음
								</button>

								<button @click="fnPage(currentPage - 1)" :disabled="currentPage == 1">
									이전
								</button>

								<button v-for="page in visiblePages" :key="page" @click="fnPage(page)"
									:class="{ active: currentPage == page }">
									{{ page }}
								</button>

								<button @click="fnPage(currentPage + 1)" :disabled="currentPage >= totalPages">
									다음
								</button>

								<button @click="fnPage(totalPages)" :disabled="currentPage >= totalPages">
									마지막
								</button>

							</div>

						</div>

					</div>

				</main>

			</div>

			<!-- 하단 회사 정보 -->
			<footer class="footer">

				<div>
					<div class="footer-logo">
						Logo
					</div>
				</div>

				<div>
					<h4>회사 정보</h4>
					<p>
						회사소개<br>
						이용약관<br>
						개인정보처리방침
					</p>
				</div>

				<div>
					<h4>고객센터</h4>
					<p>
						공지사항<br>
						자주 묻는 질문<br>
						1:1 문의
					</p>
				</div>

				<div>
					<p>
						상호명 : 기프트온<br>
						사업자등록번호 : 000-00-00000<br>
						주소 : 서울특별시 OO구 OO동<br>
						고객센터 : 1588-0000<br>
						Copyright © GIFT-ON. All rights reserved.
					</p>
				</div>

			</footer>

		</div>

		<script>

			const app = Vue.createApp({

				// 화면 데이터
				data() {

					return {

						// 검색 조건
						keyword: "",
						searchGrade: "",
						searchStatus: "",
						searchPeriod: "",

						// 페이지 정보
						currentPage: 1,
						pageSize: 5,

						// 회원 목록
						memberList: [],

						// 전체 회원 수
						totalCount: 0,

						// 회원 통계
						memberStats: {
							totalCount: 0,
							todayCount: 0,
							activeCount: 0,
							dormantCount: 0
						}

					};

				},

				// 계산된 데이터
				computed: {

					// 전체 페이지 수
					totalPages() {

						return Math.max(
							1,
							Math.ceil(this.totalCount / this.pageSize)
						);

					},

					// 화면에 표시할 페이지 번호
					visiblePages() {

						let pageGroupSize = 5;

						let startPage =
							Math.floor((this.currentPage - 1) / pageGroupSize)
							* pageGroupSize + 1;

						let endPage = Math.min(
							startPage + pageGroupSize - 1,
							this.totalPages
						);

						let pages = [];

						for (let i = startPage; i <= endPage; i++) {
							pages.push(i);
						}

						return pages;

					}

				},

				// 화면 함수
				methods: {

					// 회원 목록 조회
					fnList() {

						let self = this;

						let param = {

							keyword: self.keyword,
							searchGrade: self.searchGrade,
							searchStatus: self.searchStatus,
							searchPeriod: self.searchPeriod,

							limit: self.pageSize,
							offset: (self.currentPage - 1) * self.pageSize

						};

						$.ajax({

							url: "/admin/member/list.dox",
							type: "POST",
							dataType: "json",
							data: param,

							success: function (data) {

								if (data.result == "success") {

									self.memberList = data.list || [];

									self.memberStats =
										data.stats || self.memberStats;

									self.totalCount =
										Number(data.count) || 0;

								} else {

									alert(data.message || "회원 목록 조회에 실패했습니다.");

								}

							},

							error: function () {

								alert("서버 통신 오류");

							}

						});

					},

					// 검색
					fnSearch() {

						this.currentPage = 1;
						this.fnList();

					},

					// 검색 조건 초기화
					fnReset() {

						this.keyword = "";
						this.searchGrade = "";
						this.searchStatus = "";
						this.searchPeriod = "";

						this.currentPage = 1;

						this.fnList();

					},

					// 페이지 이동
					fnPage(page) {

						page = Number(page);

						if (page < 1 || page > this.totalPages) {
							return;
						}

						this.currentPage = page;
						this.fnList();

					},

					// 등급 CSS 클래스
					fnGradeClass(grade) {

						const gradeMap = {

							BRONZE: "bronze",
							SILVER: "silver",
							GOLD: "gold",
							VIP: "vip"

						};

						return gradeMap[grade] || "";

					},

					// 상태 한글 변환
					fnStatusName(status) {

						const statusMap = {

							ACTIVE: "정상",
							SUSPENDED: "정지",
							WITHDRAWN: "탈퇴",
							INACTIVE: "휴면"

						};

						return statusMap[status] || status || "-";

					},

					// 상태 CSS 클래스
					fnStatusClass(status) {

						const statusMap = {

							ACTIVE: "normal",
							SUSPENDED: "suspended",
							WITHDRAWN: "withdrawn",
							INACTIVE: "inactive"

						};

						return statusMap[status] || "";

					},

					// 숫자 포맷
					fnFormatNumber(value) {

						return Number(value || 0).toLocaleString();

					},

					// 회원 상세 페이지 이동
					fnEdit(memberId) {
						pageChange("/admin/member/edit.do", {
							memberId: memberId
						});

					}

				},

				// 최초 실행
				mounted() {

					this.fnList();

				}

			});

			app.mount("#app");

		</script>

	</body>

	</html>