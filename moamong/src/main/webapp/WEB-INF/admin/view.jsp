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
		<link rel="stylesheet" href="/css/admin/view.css">

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
						<h3>회원 상세 정보</h3>

					</div>


					<!-- 현재 페이지의 위치 -->
					<div class="breadcrumb">

						회원 관리 / 회원 목록 / 회원 상세 정보

					</div>


					<!-- =================================
                 가운데 콘텐츠 영역
                 ================================= -->


					<!-- ==========================================
				      회원 관리 메인 콘텐츠 영역
				      ========================================== -->


					<!-- ==========================================
					       회원 상세정보 메인 영역
					       ========================================== -->

					<div class="content-area">

						<!-- ======================================
					           1. 회원 프로필 영역
					           ====================================== -->
						<div class="user-profile">

							<!-- 회원 기본 프로필 -->
							<div class="profile-left">

								<!-- 프로필 이미지 영역 -->
								<div class="profile-image">
									<span>●</span>
								</div>

								<!-- 회원 이름 및 상태 -->
								<div class="profile-name">

									<strong>{{ userInfo.name }}</strong>

									<span>{{ userInfo.email }}</span>

									<div class="profile-badges">
										<span class="grade-badge">
											{{ userInfo.grade }}
										</span>

										<span class="status-badge">
											{{ userInfo.status }}
										</span>
									</div>

								</div>
							</div>

							<!-- 회원 가입 및 로그인 정보 -->
							<div class="profile-right">

								<div class="profile-info-item">
									<span>회원 번호</span>
									<strong>{{ userInfo.userNo }}</strong>
								</div>

								<div class="profile-info-item">
									<span>가입일</span>
									<strong>{{ userInfo.joinDate }}</strong>
								</div>

								<div class="profile-info-item">
									<span>최근 로그인</span>
									<strong>{{ userInfo.lastLogin }}</strong>
								</div>

								<div class="profile-info-item">
									<span>휴대폰 번호</span>
									<strong>{{ userInfo.phone }}</strong>
								</div>

							</div>

							<!-- 회원 관리 버튼 -->
							<div class="profile-buttons">

								<button class="btn-profile-edit" @click="fnEditUser">
									회원 정보 수정
								</button>

								<button class="btn-user-stop" @click="fnStopUser">
									회원 정지
								</button>

							</div>

						</div>


						<!-- ======================================
					           2. 회원 통계 영역
					           ====================================== -->
						<div class="detail-stats">

							<div class="detail-stats-card">
								<span>누적 주문</span>
								<strong>
									{{ userStats.orderCount }} 건
								</strong>
							</div>

							<div class="detail-stats-card">
								<span>누적 구매 금액</span>
								<strong>
									{{ fnFormatNumber(userStats.totalPrice) }} 원
								</strong>
							</div>

							<div class="detail-stats-card">
								<span>보유 포인트</span>
								<strong>
									{{ fnFormatNumber(userStats.point) }} P
								</strong>
							</div>

							<div class="detail-stats-card">
								<span>보유 쿠폰</span>
								<strong>
									{{ userStats.couponCount }} 장
								</strong>
							</div>

						</div>


						<!-- ======================================
					           3. 기본 정보 / 회원 활동 정보
					           ====================================== -->
						<div class="detail-info-area">

							<!-- 기본 정보 -->
							<div class="detail-info-box">

								<h3>기본 정보</h3>

								<div class="info-row">
									<span>이름</span>
									<strong>{{ userInfo.name }}</strong>
								</div>

								<div class="info-row">
									<span>아이디</span>
									<strong>{{ userInfo.userId }}</strong>
								</div>

								<div class="info-row">
									<span>이메일</span>
									<strong>{{ userInfo.email }}</strong>
								</div>

								<div class="info-row">
									<span>연락처</span>
									<strong>{{ userInfo.phone }}</strong>
								</div>

								<div class="info-row">
									<span>주소</span>
									<strong>{{ userInfo.address }}</strong>
								</div>

							</div>


							<!-- 회원 활동 정보 -->
							<div class="detail-info-box">

								<h3>회원 활동 정보</h3>

								<div class="info-row">
									<span>회원 등급</span>
									<strong>{{ userInfo.grade }}</strong>
								</div>

								<div class="info-row">
									<span>마케팅 수신 동의</span>
									<strong>{{ userInfo.marketingAgree }}</strong>
								</div>

								<div class="info-row">
									<span>총 리뷰 작성</span>
									<strong>{{ userStats.reviewCount }} 건</strong>
								</div>

								<div class="info-row">
									<span>총 문의 내역</span>
									<strong>{{ userStats.inquiryCount }} 건</strong>
								</div>

								<div class="info-row">
									<span>계정 상태</span>
									<strong>{{ userInfo.status }}</strong>
								</div>

							</div>

						</div>


						<!-- ======================================
					           4. 최근 주문 내역
					           ====================================== -->
						<div class="recent-order">

							<div class="order-header">

								<h3>최근 주문 내역</h3>

								<button class="btn-all-order" @click="fnOrderList">
									전체 주문 보기 ›
								</button>

							</div>


							<!-- 주문 목록 테이블 -->
							<table class="order-table">

								<thead>
									<tr>
										<th>주문번호</th>
										<th>주문일</th>
										<th>상품명</th>
										<th>결제 금액</th>
										<th>주문 상태</th>
									</tr>
								</thead>

								<tbody>

									<!-- DB에서 조회한 주문 목록 출력 -->
									<tr v-for="(item, index) in orderList" :key="item.orderNo">

										<td>{{ item.orderNo }}</td>

										<td>{{ item.orderDate }}</td>

										<td>{{ item.productName }}</td>

										<td>
											₩ {{ fnFormatNumber(item.price) }}
										</td>

										<td>
											<span class="order-status">
												{{ item.orderStatus }}
											</span>
										</td>

									</tr>

									<!-- 조회된 주문이 없을 경우 -->
									<tr v-if="orderList.length === 0">
										<td colspan="5">
											조회된 주문 내역이 없습니다.
										</td>
									</tr>

								</tbody>

							</table>

							<div class="order-notice">
								* 회원 및 회원 보유 쿠폰 데이터는 디자인 예시입니다.
							</div>

						</div>


						<!-- ======================================
					           5. 목록으로 버튼
					           ====================================== -->
						<div class="detail-footer">

							<button class="btn-back" @click="fnBack">
								목록으로
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


		<!-- =========================================
     Vue 실행 영역
     ========================================= -->

		<script>

			// Vue 애플리케이션을 생성합니다.
			const app = Vue.createApp({

				// 화면에서 사용할 데이터
				data() {
					return {

						// 회원 기본 정보
						userInfo: {},

						// 회원 통계 정보
						userStats: {},

						// 최근 주문 목록
						orderList: []

					};
				},

				methods: {

					// =====================================
					// 회원 상세정보 조회
					// =====================================
					fnGetUserDetail: function () {

						let self = this;

						// 이전 페이지에서 전달받은 회원 번호
						let userNo = $("#userNo").val();

						$.ajax({

							url: "/user/detail.dox",

							type: "POST",

							dataType: "json",

							data: {
								userNo: userNo
							},

							success: function (data) {

								// 서버에서 조회에 성공한 경우
								if (data.result == "success") {

									// 회원 기본 정보 저장
									self.userInfo = data.userInfo;

									// 회원 통계 정보 저장
									self.userStats = data.userStats;

									// 최근 주문 목록 저장
									self.orderList = data.orderList;

								} else {

									alert(data.message);

								}

							},

							error: function (xhr, status, error) {

								console.log(error);

								alert("회원 정보를 불러오지 못했습니다.");

							}

						});

					},


					// =====================================
					// 숫자에 천 단위 콤마 추가
					// =====================================
					fnFormatNumber: function (value) {

						// DB에서 값이 없을 경우 0으로 처리
						return Number(value || 0).toLocaleString();

					},


					// =====================================
					// 회원 정보 수정 페이지 이동
					// =====================================
					fnEditUser: function () {

						let userNo = $("#userNo").val();

						location.href = "/user/edit.do?userNo=" + userNo;

					},


					// =====================================
					// 회원 정지
					// =====================================
					fnStopUser: function () {

						// 실제 정지 처리는 별도의 API와 연결 예정
						alert("회원 정지 기능은 추후 연결합니다.");

					},


					// =====================================
					// 전체 주문 내역 페이지 이동
					// =====================================
					fnOrderList: function () {

						let userNo = $("#userNo").val();

						location.href = "/order/list.do?userNo=" + userNo;

					},


					// =====================================
					// 회원 목록 페이지 이동
					// =====================================
					fnBack: function () {

						location.href = "/user/list.do";

					}

				},

				// =====================================
				// 페이지가 처음 실행될 때
				// =====================================
				mounted() {

					// 회원 상세정보를 DB에서 조회
					this.fnGetUserDetail();

				}

			});

			app.mount('#app');

		</script>

	</body>

	</html>