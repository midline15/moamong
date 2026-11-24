<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">

		<title>쿠폰 관리</title>

		<!-- jQuery 라이브러리 -->
		<script src="https://code.jquery.com/jquery-3.7.1.js"></script>

		<!-- Vue 3 라이브러리 -->
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

		<!-- 프로젝트 공통 JS -->
		<script src="/js/page-change.js"></script>

		<!-- 쿠폰 목록 CSS -->
		<link rel="stylesheet" href="/css/coupon/list.css">

	</head>

	<body>

		<!-- ====================================== -->
		<!-- 추후 공통 상단 영역 추가 예정 -->
		<!-- ====================================== -->


		<!-- ====================================== -->
		<!-- 추후 공통 사이드바 영역 추가 예정 -->
		<!-- ====================================== -->


		<!-- ====================================== -->
		<!-- 관리자 콘텐츠 영역 시작 -->
		<!-- ====================================== -->

		<div id="app" class="container">

			<!-- 페이지 제목 -->
			<div class="page-header">

				<div>
					<h2>쿠폰 관리</h2>
					<p>등록된 쿠폰을 확인하고 관리할 수 있습니다.</p>
				</div>

				<!-- 쿠폰 등록 화면으로 이동 -->
				<button class="btn-primary" @click="fnAdd">
					+ 쿠폰 등록
				</button>

			</div>


			<!-- 쿠폰 요약 정보 -->
			<div class="summary">

				<div class="summary-item">
					<span>전체 쿠폰</span>
					<strong>{{ totalCount }}</strong>
				</div>

				<div class="summary-item">
					<span>사용 가능</span>
					<strong>{{ activeCount }}</strong>
				</div>

				<div class="summary-item">
					<span>사용 예정</span>
					<strong>{{ upcomingCount }}</strong>
				</div>

				<div class="summary-item">
					<span>기간 만료</span>
					<strong>{{ expiredCount }}</strong>
				</div>

			</div>


			<!-- 검색 영역 -->
			<div class="search-area">

				<div class="search-box">

					<select v-model="searchType">

						<option value="couponName">쿠폰명</option>
						<option value="discountType">할인 </option>

					</select>

					<input type="text" v-model="keyword" placeholder="검색어를 입력하세요." @keyup.enter="fnSearch">

					<button class="btn-search" @click="fnSearch">
						검색
					</button>

					<button class="btn-reset" @click="fnReset">
						초기화
					</button>

				</div>

			</div>


			<!-- 쿠폰 목록 -->
			<div class="table-wrap">

				<table>

					<thead>
						<tr>
							<th>번호</th>
							<th>쿠폰명</th>
							<th>할인 유형</th>
							<th>할인 혜택</th>
							<th>최소 주문 금액</th>
							<th>최대 할인 금액</th>
							<th>사용 시작일</th>
							<th>사용 종료일</th>
							<th>관리</th>
						</tr>
					</thead>

					<tbody>

						<tr v-for="coupon in filteredCoupons" :key="coupon.couponId">

							<td>{{ coupon.couponId }}</td>

							<td class="coupon-name">
								{{ coupon.couponName || '-' }}
							</td>

							<td>

								<span class="type-badge" :class="fnDiscountClass(coupon.discountType)">

									{{ fnDiscountType(coupon.discountType) }}

								</span>

							</td>

							<td class="discount-value">

								<span v-if="coupon.discountType === 'FIXED'">
									{{ fnNumber(coupon.discountValue) }}원
								</span>

								<span v-else-if="coupon.discountType === 'RATE'">
									{{ coupon.discountValue }}%
								</span>

								<span v-else>
									-
								</span>

							</td>

							<td>
								{{ fnNumber(coupon.minimumOrderAmount) }}원
							</td>

							<td>

								<span v-if="coupon.maximumDiscountAmount != null">
									{{ fnNumber(coupon.maximumDiscountAmount) }}원
								</span>

								<span v-else>
									-
								</span>

							</td>

							<td>
								{{ fnDate(coupon.validFrom) }}
							</td>

							<td>
								{{ fnDate(coupon.validUntil) }}
							</td>

							<td>

								<button class="btn-edit" @click="fnEdit(coupon.couponId)">

									수정

								</button>

								<button class="btn-delete" @click="fnRemove(coupon.couponId)">

									삭제

								</button>

							</td>

						</tr>


						<!-- 검색 결과가 없는 경우 -->
						<tr v-if="filteredCoupons.length === 0">

							<td colspan="9" class="empty">
								등록된 쿠폰이 없습니다.
							</td>

						</tr>

					</tbody>

				</table>

			</div>


			<!-- 목록 하단 -->
			<div class="list-footer">

				<span>
					총 {{ filteredCoupons.length }}개의 쿠폰
				</span>

			</div>

		</div>

		<!-- ====================================== -->
		<!-- 관리자 콘텐츠 영역 종료 -->
		<!-- ====================================== -->


		<!-- ====================================== -->
		<!-- 추후 공통 하단 영역 추가 예정 -->
		<!-- ====================================== -->


		<script>

			const app = Vue.createApp({

				data() {

					return {

						// DB에서 조회한 쿠폰 목록을 저장하는 배열
						couponList: [],

						// 검색 종류
						searchType: "couponName",

						// 검색어
						keyword: "",

						// 전체 쿠폰 개수
						totalCount: 0

					};

				},


				computed: {

					// 현재 사용 가능한 쿠폰 개수
					activeCount() {

						let now = new Date();

						return this.couponList.filter(coupon => {

							let start = new Date(coupon.validFrom);
							let end = new Date(coupon.validUntil);

							return start <= now && end >= now;

						}).length;

					},


					// 아직 사용 시작일이 되지 않은 쿠폰 개수
					upcomingCount() {

						let now = new Date();

						return this.couponList.filter(coupon => {

							return new Date(coupon.validFrom) > now;

						}).length;

					},


					// 사용 기간이 지난 쿠폰 개수
					expiredCount() {

						let now = new Date();

						return this.couponList.filter(coupon => {

							return new Date(coupon.validUntil) < now;

						}).length;

					},


					// 검색 조건에 맞는 쿠폰 목록
					filteredCoupons() {

						let self = this;

						// 검색어가 비어 있다면 전체 목록을 보여줍니다.
						if (!self.keyword || !self.keyword.trim()) {

							return self.couponList;

						}

						// 검색어를 소문자로 변경합니다.
						let keyword = self.keyword.toLowerCase();

						return self.couponList.filter(coupon => {

							// 쿠폰명이 없는 경우 빈 문자열로 처리합니다.
							let couponName = String(coupon.couponName || "").toLowerCase();

							// 쿠폰명 검색
							if (self.searchType === "couponName") {

								return couponName.includes(keyword);

							}

							// 할인 유형 검색
							if (self.searchType === "discountType") {

								let discountType = self.fnDiscountType(coupon.discountType);

								return discountType.toLowerCase().includes(keyword);

							}

							return true;

						});

					}

				},


				methods: {

					// 숫자를 천 단위 콤마 형식으로 변경합니다.
					fnNumber(value) {

						return Number(value || 0).toLocaleString();

					},


					// 할인 유형을 한글로 변경합니다.
					fnDiscountType(type) {

						if (type === "FIXED") {

							return "정액 할인";

						}

						if (type === "RATE") {

							return "정률 할인";

						}

						return "-";

					},


					// 할인 유형에 따른 CSS 클래스를 반환합니다.
					fnDiscountClass(type) {

						if (type === "FIXED") {

							return "fixed";

						}

						if (type === "RATE") {

							return "rate";

						}

						return "";

					},


					// 날짜를 화면에 보기 좋게 표시합니다.
					fnDate(value) {

						if (!value) {

							return "-";

						}

						return String(value).replace("T", " ");

					},


					// 검색 실행
					fnSearch() {


					},


					// 검색 초기화
					fnReset() {

						this.keyword = "";
						this.searchType = "couponName";

					},


					// 쿠폰 등록 페이지 이동
					fnAdd() {

						location.href = "/coupon/add.do";

					},


					// 쿠폰 수정 페이지 이동
					fnEdit(couponId) {

						location.href = "/coupon/edit.do?couponId=" + couponId;

					},


					// 쿠폰 삭제
					fnRemove(couponId) {

						let self = this;

						// 삭제하기 전에 사용자에게 확인을 받습니다.
						if (!confirm("정말 해당 쿠폰을 삭제하시겠습니까?")) {

							return;

						}

						$.ajax({

							url: "/coupon/remove.dox",

							type: "POST",

							dataType: "json",

							data: {

								couponId: couponId

							},

							success: function (data) {

								if (data.result === "success") {

									alert("쿠폰이 삭제되었습니다.");

									// 삭제 후 목록을 다시 조회합니다.
									self.fnGetCouponList();

								} else {

									alert(data.message || "쿠폰 삭제에 실패했습니다.");

								}

							},

							error: function (xhr, status, error) {

								console.log(xhr.responseText);
								console.log(error);

								alert("서버 통신 중 오류가 발생했습니다.");

							}

						});

					},


					// 쿠폰 목록 조회
					fnGetCouponList() {

						let self = this;

						$.ajax({

							url: "/coupon/list.dox",

							type: "POST",

							dataType: "json",

							data: {},

							success: function (data) {

								if (data.result === "success") {

									// 서버에서 받은 쿠폰 목록을 배열에 저장합니다.
									self.couponList = Array.isArray(data.list) ? data.list : [];

									// 전체 쿠폰 개수를 저장합니다.
									self.totalCount = self.couponList.length;

								} else {

									self.couponList = [];
									self.totalCount = 0;

									alert(data.message || "쿠폰 조회에 실패했습니다.");

								}

							},

							error: function (xhr, status, error) {

								console.log(xhr.responseText);
								console.log(error);

								self.couponList = [];
								self.totalCount = 0;

								alert("쿠폰 목록을 불러오는 중 오류가 발생했습니다.");

							}

						});

					}

				},


				mounted() {

					// 화면이 처음 열리면 쿠폰 목록을 조회합니다.
					this.fnGetCouponList();

				}

			});


			app.mount("#app");

		</script>

	</body>

	</html>