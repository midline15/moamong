<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">

		<!-- 모바일에서도 화면 크기에 맞게 표시하기 위한 설정 -->
		<meta name="viewport" content="width=device-width, initial-scale=1.0">

		<title>관리자 페이지</title>

		<!-- jQuery를 사용하기 위한 라이브러리 -->
		<script src="https://code.jquery.com/jquery-3.7.1.js"
			integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>

		<!-- Vue 3를 사용하기 위한 라이브러리 -->
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

		<!-- 기존 프로젝트에서 사용하는 공통 JS -->
		<script src="/js/page-change.js"></script>

		<link rel="stylesheet" href="/css/admin/default.css">
		<link rel="stylesheet" href="/css/admin/list.css">

	</head>

	<body>

		<!-- Vue가 실행되는 전체 영역 -->
		<div id="app">

			<!-- =====================================
             상단 헤더
             ===================================== -->

			<header class="header">

				<!-- 관리자 페이지 로고 -->
				<div class="logo">
					Logo
				</div>

			</header>


			<!-- =====================================
             관리자 메인 영역
             ===================================== -->

			<div class="admin-container">


				<!-- =================================
                 왼쪽 사이드바
                 ================================= -->

				<aside class="sidebar">

					<!-- 사이드바 제목 -->
					<div class="sidebar-title">
						관리자 페이지
					</div>

					<!-- 관리자 메뉴 목록 -->
					<ul>

						<!-- 현재 선택된 메뉴 -->
						<li class="active">
							회원 관리
						</li>

						<li>
							상품조회 / 등록
						</li>

						<li>
							주문 관리
						</li>

						<li>
							배송 관리
						</li>

						<li>
							재고 관리
						</li>

						<li>
							거래처 관리
						</li>

						<li>
							리뷰 및 문의
						</li>

						<li>
							쿠폰 관리
						</li>

						<li>
							이벤트 관리
						</li>

						<li>
							매출 통계
						</li>

					</ul>

				</aside>


				<!-- =================================
                 오른쪽 메인 콘텐츠
                 ================================= -->

				<main class="main-content">

					<!-- 페이지 제목 -->
					<div class="page-title">

						<!-- 현재 페이지 이름 -->
						<h3>회원 목록</h3>

					</div>


					<!-- 현재 페이지의 위치 -->
					<div class="breadcrumb">

						회원 관리 / 회원 목록

					</div>


					<!-- =================================
                     가운데 콘텐츠 영역
                     ================================= -->


					<!-- ==========================================
					      회원 관리 메인 콘텐츠 영역
					      ========================================== -->

					<div class="content-area">

						<!-- ======================================
					          1. 회원 통계 영역
					          ====================================== -->

						<div class="member-stats">

							<!-- 전체 회원 수 -->
							<div class="stats-card">
							    <div class="stats-title">전체 회원</div>
							    <div class="stats-value">
							        <span><strong>{{ memberStats.totalCount }}</strong>명</span>
							    </div>
							</div>

							<!-- 오늘 가입한 회원 수 -->
							<div class="stats-card">
							    <div class="stats-title">오늘 가입</div>
							    <div class="stats-value">
							        <span><strong>{{ memberStats.todayCount }}</strong>명</span>
							    </div>
							</div>

							<!-- 활성 회원 수 -->
							<div class="stats-card">
								<div class="stats-title">활성 회원</div>

								<!-- DB에서 조회한 활성 회원 수 출력 -->
								<div class="stats-value">
									<span><strong>{{memberStats.activeCount}}</strong>명</span>
								</div>
							</div>

							<!-- 휴면 회원 수 -->
							<div class="stats-card">
								<div class="stats-title">휴면 회원</div>

								<!-- DB에서 조회한 휴면 회원 수 출력 -->
								<div class="stats-value">
									<span><strong>{{ memberStats.dormantCount }}</strong>명</span>
								</div>
							</div>

						</div>


						<!-- ======================================
					          2. 회원 검색 영역
					          ====================================== -->

						<div class="member-search">

							<h3>회원 검색</h3>

							<div class="search-row">

								<!-- 이름, 아이디, 이메일 검색 -->
								<div class="search-item">
									<label>검색어</label>

									<input type="text" v-model="keyword" placeholder="이름 또는 아이디 또는 이메일">
								</div>

								<!-- 회원 등급 선택 -->
								<div class="search-item">
									<label>회원 등급</label>

									<select v-model="searchGrade">
										<option value="">전체 등급</option>
										<option value="VIP">VIP</option>
										<option value="GOLD">GOLD</option>
										<option value="SILVER">SILVER</option>
									</select>
								</div>

								<!-- 회원 상태 선택 -->
								<div class="search-item">
									<label>회원 상태</label>

									<select v-model="searchStatus">
										<option value="">전체 상태</option>
										<option value="정상">정상</option>
										<option value="휴면">휴면</option>
									</select>
								</div>

								<!-- 가입 기간 선택 -->
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

							<!-- 검색 버튼 영역 -->
							<div class="search-buttons">

								<!-- 검색 조건 초기화 -->
								<button class="btn-reset" @click="fnReset">
									초기화
								</button>

								<!-- 검색 실행 -->
								<button class="btn-search" @click="fnSearch">
									검색
								</button>

							</div>

						</div>


						<!-- ======================================
					          3. 회원 목록 영역
					          ====================================== -->

						<div class="member-list">

							<!-- 회원 목록 제목 -->
							<div class="list-header">

								<h3>회원 목록</h3>

								<!-- DB에서 조회한 회원 수 표시 -->
								<span>
									총 명
								</span>

							</div>

							<!-- 회원 목록 테이블 -->
							<table class="member-table">

								<!-- 테이블 제목 -->
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

								<!-- DB에서 조회한 회원 데이터 출력 -->

								<tbody>

									<!-- 서버에서 전달받은 회원 목록만큼 반복 -->
									<tr v-for="member in memberList" :key="member.memberId">

										<!-- 회원 이름과 로그인 아이디 -->
										<td class="member-info">
											<strong>{{ member.memberName }}</strong>
											<span>{{ member.loginId }}</span>
										</td>

										<!-- 연락처 -->
										<td>{{ member.phone }}</td>

										<!-- 회원 등급 -->
										<td>
											<span class="grade-badge"
												:class="member.memberGrade ? member.memberGrade.toLowerCase() : ''">
												{{ member.memberGrade}}
											</span>
										</td>

										<!-- 누적 구매 금액 -->
										<td>
											{{ member.totalPayment}}원
										</td>

										<!-- 가입일 -->
										<td>{{ member.createdAt }}</td>

										<!-- 회원 상태 -->
										<td>
											<span class="status-badge"
												:class="member.status == '정상' ? 'normal' : 'dormant'">
												{{ member.status }}
											</span>
										</td>

										<!-- 상세보기 버튼 -->
										<td>
											<button class="btn-detail" @click="fnView(member.memberId)">
												상세보기
											</button>
										</td>

									</tr>

									<!-- 조회된 회원이 없을 때 -->
									<tr v-if="memberList.length == 0">
										<td colspan="7">
											조회된 회원이 없습니다.
										</td>
									</tr>

								</tbody>


							</table>


							<!-- ==================================
					              4. 페이지 번호 영역
					              ================================== -->

							<div class="pagination">

								<!-- 이전 페이지 -->
								<button @click="fnPage(currentPage - 1)" :disabled="currentPage == 1">
									이전
								</button>

								<!-- 페이지 번호 -->
								<button v-for="page in totalPages" :key="page" @click="fnPage(page)"
									:class="{ active: currentPage == page }">
									{{ page }}
								</button>

								<!-- 다음 페이지 -->
								<button @click="fnPage(currentPage + 1)" :disabled="currentPage >= totalPages">
									다음
								</button>

							</div>

						</div>


						<!-- ======================================
					          5. 회원 등록 버튼
					          ====================================== -->

						<div class="member-add">

							<button @click="fnAdd">
								+ 회원 등록
							</button>

						</div>

					</div>


				</main>

			</div>


			<!-- =====================================
             하단 회사 정보
             ===================================== -->

			<footer class="footer">

				<!-- 회사 로고 -->
				<div>

					<div class="footer-logo">
						Logo
					</div>

				</div>


				<!-- 회사 정보 -->
				<div>

					<h4>회사 정보</h4>

					<p>
						회사소개<br>
						이용약관<br>
						개인정보처리방침
					</p>

				</div>


				<!-- 고객센터 -->
				<div>

					<h4>고객센터</h4>

					<p>
						공지사항<br>
						자주 묻는 질문<br>
						1:1 문의
					</p>

				</div>


				<!-- 사업자 정보 -->
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
	</body>

	</html>

	<script>

		const app = Vue.createApp({

			// 화면에서 사용할 데이터를 보관하는 곳입니다.
			data() {
				return {

					// 검색어
					keyword: "",

					// 회원 등급
					searchGrade: "",

					// 회원 상태
					searchStatus: "",

					// 가입 기간
					searchPeriod: "",

					// 현재 페이지
					currentPage: 1,

					// 한 페이지에 보여줄 회원 수
					pageSize: 5,

					// 회원 목록
					memberList: [],

					// 전체 회원 수
					totalCount: 0,

					// 회원 통계 데이터
					memberStats: {
						totalCount: 0,
						todayCount: 0,
						activeCount: 0,
						dormantCount: 0
					}


				};
			},


			methods: {

				fnList: function () {
					let self = this;
					let param = {
					};
					$.ajax({
						url: "/admin/list.dox",
						dataType: "json",
						type: "POST",
						data: param,
						success: function (data) {


							// 서버에서 전달받은 결과가 성공인지 확인합니다.
							if (data.result == "success") {

								// 서버에서 전달받은 회원 목록을 Vue의 memberList에 저장합니다.
								// data.list에는 DB에서 조회한 회원 데이터가 들어 있습니다.
								self.memberList = data.list;

								self.memberStats = data.stats;

								self.totalCount = data.stats.totalCount;



							} else {

								// 조회에 실패했을 때 안내 메시지를 보여줍니다.
								alert("회원 목록 조회에 실패했습니다.");

							}
						},

					});
				},
				
				fnView(memberId) {
					pageChange("view.do", {memberId: memberId});
				}

			},


			mounted() {

				let self = this;
				self.fnList();
			}

		});

		app.mount('#app');

	</script>