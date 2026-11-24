<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

	<!DOCTYPE html>
	<html lang="ko">

	<head>

		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">

		<title>쿠폰 등록</title>

		<!-- jQuery 라이브러리 -->
		<script src="https://code.jquery.com/jquery-3.7.1.js"></script>

		<!-- Vue 3 라이브러리 -->
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

		<!-- 기존 프로젝트 공통 JS -->
		<script src="/js/page-change.js"></script>

		<!-- 쿠폰 등록 CSS -->
		<link rel="stylesheet" href="/css/coupon/add.css">

		<!-- Flatpickr 달력 CSS -->
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">

		<!-- Flatpickr 달력 JS -->
		<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

		<!-- 한국어 설정 -->
		<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js"></script>

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
					<h2>쿠폰 등록</h2>
					<p>신규 쿠폰 정보를 입력하고 등록할 수 있습니다.</p>
				</div>

			</div>


			<!-- 쿠폰 등록 폼 -->
			<div class="form-container">

				<!-- 기본 정보 -->
				<div class="form-section">

					<h3>기본 정보</h3>

					<div class="form-group">

						<label>쿠폰명 <span>*</span></label>

						<input type="text" v-model="couponName" placeholder="쿠폰명을 입력하세요.">

					</div>

				</div>


				<!-- 할인 설정 -->
				<div class="form-section">

					<h3>할인 설정</h3>

					<div class="form-group">

						<label>할인 유형 <span>*</span></label>

						<select v-model="discountType">

							<option value="FIXED">정액 할인</option>

							<option value="RATE">정률 할인</option>

						</select>

					</div>


					<div class="form-group">

						<label>
							{{ discountType === 'FIXED' ? '할인 금액' : '할인율' }}
							<span>*</span>
						</label>

						<div class="input-unit">

							<input type="number" v-model.number="discountValue" min="1" placeholder="할인 값을 입력하세요.">

							<span>
								{{ discountType === 'FIXED' ? '원' : '%' }}
							</span>

						</div>

					</div>


					<div class="form-group">

						<label>최소 주문 금액</label>

						<div class="input-unit">

							<input type="number" v-model.number="minimumOrderAmount" min="0">

							<span>원</span>

						</div>

					</div>


					<div class="form-group" v-if="discountType === 'RATE'">

						<label>최대 할인 금액</label>

						<div class="input-unit">

							<input type="number" v-model.number="maximumDiscountAmount" min="0"
								placeholder="최대 할인 금액을 입력하세요.">

							<span>원</span>

						</div>

					</div>

				</div>


				<!-- 사용 기간 설정 -->
				<div class="form-section">

					<h3>사용 기간 설정</h3>

					<div class="date-group">

						<div class="form-group">

							<label>사용 시작일 <span>*</span></label>

							<!-- Vue의 validFrom 변수와 연결합니다. -->
							<!-- readonly를 사용하면 키보드로 직접 입력하지 않고 달력으로 선택합니다. -->
							<input type="text" id="validFrom" v-model="validFrom" placeholder="시작 날짜와 시간을 선택하세요">

						</div>

						<div class="form-group">

							<label>사용 종료일 <span>*</span></label>

							<!-- Vue의 validUntil 변수와 연결합니다. -->
							<input type="text" id="validUntil" v-model="validUntil" placeholder="종료 날짜와 시간을 선택하세요">

						</div>

					</div>

				</div>


				<!-- 쿠폰 미리보기 -->
				<div class="form-section">

					<h3>쿠폰 미리보기</h3>

					<div class="preview-card">

						<div class="preview-title">
							{{ couponName || '쿠폰명을 입력하세요.' }}
						</div>

						<div class="preview-discount">

							<span v-if="discountType === 'FIXED'">
								{{ Number(discountValue || 0).toLocaleString() }}원 할인
							</span>

							<span v-else>
								{{ discountValue || 0 }}% 할인
							</span>

						</div>

						<p>
							{{ Number(minimumOrderAmount || 0).toLocaleString() }}원 이상 구매 시 사용 가능
						</p>

					</div>

				</div>


				<!-- 버튼 -->
				<div class="button-area">

					<button class="btn-cancel" @click="fnCancel">
						취소
					</button>

					<button class="btn-submit" @click="fnAdd">
						쿠폰 등록
					</button>

				</div>

			</div>

		</div>

		<!-- ====================================== -->
		<!-- 관리자 콘텐츠 영역 종료 -->
		<!-- ====================================== -->


		<!-- ====================================== -->
		<!-- 추후 공통 하단 영역 추가 예정 -->
		<!-- ====================================== -->


	</body>

	</html>


	<script>

		const app = Vue.createApp({

			data() {

				return {

					// 쿠폰 이름
					couponName: "",

					// 할인 유형
					// FIXED : 정액 할인
					// RATE : 정률 할인
					discountType: "FIXED",

					// 할인 금액 또는 할인율
					discountValue: null,

					// 최소 주문 금액
					minimumOrderAmount: 0,

					// 최대 할인 금액
					maximumDiscountAmount: null,

					// 쿠폰 사용 시작일
					validFrom: "",

					// 쿠폰 사용 종료일
					validUntil: ""

				};

			},


			methods: {

				// 쿠폰 등록
				fnAdd() {

					let self = this;
					let param = {

						couponName: self.couponName,
						discountType: self.discountType,
						discountValue: self.discountValue,
						minimumOrderAmount: self.minimumOrderAmount,
						maximumDiscountAmount: self.maximumDiscountAmount,
						validFrom: self.validFrom,
						validUntil: self.validUntil

					};

					// 쿠폰명이 입력되었는지 확인
					if (!self.couponName.trim()) {

						alert("쿠폰명을 입력해주세요.");
						return;

					}

					// 할인 값이 입력되었는지 확인
					if (self.discountValue === null || self.discountValue <= 0) {

						alert("할인 값을 올바르게 입력해주세요.");
						return;

					}

					// 정률 할인은 100%를 초과할 수 없음
					if (self.discountType === "RATE" && self.discountValue > 100) {

						alert("할인율은 100%를 초과할 수 없습니다.");
						return;

					}

					// 사용 시작일 확인
					if (!self.validFrom) {

						alert("사용 시작일을 선택해주세요.");
						return;

					}

					// 사용 종료일 확인
					if (!self.validUntil) {

						alert("사용 종료일을 선택해주세요.");
						return;

					}

					// 종료일이 시작일보다 빠른지 확인
					if (new Date(self.validFrom) >= new Date(self.validUntil)) {

						alert("사용 종료일은 시작일보다 늦어야 합니다.");
						return;

					}

					$.ajax({
						url: "/coupon/add.dox",
						dataType: "json",
						type: "POST",
						data: param,
						success: function (data) {
							if (data.result === 'success') {
								alert(data.message);
								location.href = "/coupon/list.do"
							} else {
								alert(data.message);
							}

						}
					});

				},

				// 목록 화면으로 이동
				fnCancel() {

					location.href = "/coupon/list.do";

				}

			},
			mounted() {
				// 화면이 처음 열리면 쿠폰 목록을 조회합니다.
				let self = this;

				// 한국어 달력 설정
				flatpickr.localize(flatpickr.l10ns.ko);

				// 사용 시작일 달력 설정
				flatpickr("#validFrom", {

					// 날짜와 시간을 함께 선택할 수 있습니다.
					enableTime: true,

					// 시간은 시:분까지만 선택합니다.
					time_24hr: true,
					dateFormat: "Y-m-d H:i",

					// Vue의 데이터와 연결합니다.
					defaultDate: self.validFrom || null,

					// 날짜를 선택하면 Vue 데이터에 저장합니다.
					onChange: function (selectedDates, dateStr) {
						self.validFrom = dateStr;
					}

				});

				// 사용 종료일 달력 설정
				flatpickr("#validUntil", {

					enableTime: true,
					time_24hr: true,
					dateFormat: "Y-m-d H:i",

					defaultDate: self.validUntil || null,

					onChange: function (selectedDates, dateStr) {
						self.validUntil = dateStr;
					}

				});

			}

		});

		app.mount("#app");

	</script>