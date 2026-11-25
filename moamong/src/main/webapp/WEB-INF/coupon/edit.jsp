<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>쿠폰 수정</title>

		<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
		<script src="/js/page-change.js"></script>

		<link rel="stylesheet" href="/css/coupon/add.css">
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">

		<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
		<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js"></script>

		<style>
			/* 달력이 다른 요소에 가려지지 않도록 설정합니다. */
			.flatpickr-calendar {
				z-index: 9999;
			}

			/* 날짜 입력창을 클릭할 수 있도록 설정합니다. */
			#validFrom,
			#validUntil {
				cursor: pointer;
			}
		</style>
	</head>

	<body>

		<div id="app" class="container">

			<div class="page-header">
				<div>
					<h2>쿠폰 수정</h2>
					<p>등록된 쿠폰 정보를 수정할 수 있습니다.</p>
				</div>
			</div>

			<div class="form-container">

				<!-- 기본 정보 -->
				<div class="form-section">
					<h3>기본 정보</h3>

					<div class="form-group">
						<label>쿠폰명 <span>*</span></label>
						<input type="text" v-model="couponName">
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

							<span>{{ discountType === 'FIXED' ? '원' : '%' }}</span>
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
							<input type="text" id="validFrom" v-model="validFrom" placeholder="시작 날짜와 시간을 선택하세요">
						</div>

						<div class="form-group">
							<label>사용 종료일 <span>*</span></label>
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
					<button class="btn-cancel" @click="fnCancel">취소</button>
					<button class="btn-submit" @click="fnEdit">쿠폰 수정</button>
				</div>

			</div>
		</div>

		<script>
			const app = Vue.createApp({

				data() {
					return {
						// 쿠폰 이름
						couponName: "",

						// 할인 유형
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
						validUntil: "",

						// 수정할 쿠폰 번호
						couponId: "${couponId}",

						// Flatpickr 달력 객체
						validFromPicker: null,
						validUntilPicker: null
					};
				},

				methods: {

					// 달력 초기화
					fnInitDatePicker() {

						let self = this;

						// 한국어 달력 설정
						flatpickr.localize(flatpickr.l10ns.ko);

						// 사용 시작일 달력
						self.validFromPicker = flatpickr("#validFrom", {

							enableTime: true,
							time_24hr: true,

							// 화면에 표시할 날짜 형식
							dateFormat: "Y-m-d H:i",

							// 달력을 입력창 아래쪽에 표시
							position: "below",

							// 직접 입력 방지
							allowInput: false,

							// 날짜 선택 시 Vue 변수에 저장
							onChange: function (selectedDates, dateStr) {
								self.validFrom = dateStr;
							}
						});

						// 사용 종료일 달력
						self.validUntilPicker = flatpickr("#validUntil", {

							enableTime: true,
							time_24hr: true,
							dateFormat: "Y-m-d H:i",
							position: "below",
							allowInput: false,

							onChange: function (selectedDates, dateStr) {
								self.validUntil = dateStr;
							}
						});
					},

					// 쿠폰 수정
					fnEdit() {

						let self = this;

						let param = {
							couponName: self.couponName,
							discountType: self.discountType,
							discountValue: self.discountValue,
							minimumOrderAmount: self.minimumOrderAmount,
							maximumDiscountAmount: self.maximumDiscountAmount,
							validFrom: self.validFrom,
							validUntil: self.validUntil,
							couponId: self.couponId
						};

						// 쿠폰 번호 확인
						if (!self.couponId) {
							alert("쿠폰 번호를 확인할 수 없습니다.");
							return;
						}

						// 쿠폰명 확인
						if (!self.couponName.trim()) {
							alert("쿠폰명을 입력해주세요.");
							return;
						}

						// 할인 값 확인
						if (self.discountValue === null || self.discountValue <= 0) {
							alert("할인 값을 올바르게 입력해주세요.");
							return;
						}

						// 정률 할인은 100% 초과 불가
						if (self.discountType === "RATE" && self.discountValue > 100) {
							alert("할인율은 100%를 초과할 수 없습니다.");
							return;
						}

						// 시작일 확인
						if (!self.validFrom) {
							alert("사용 시작일을 선택해주세요.");
							return;
						}

						// 종료일 확인
						if (!self.validUntil) {
							alert("사용 종료일을 선택해주세요.");
							return;
						}

						// 종료일이 시작일보다 늦은지 확인
						if (new Date(self.validFrom) >= new Date(self.validUntil)) {
							alert("사용 종료일은 시작일보다 늦어야 합니다.");
							return;
						}

						// 쿠폰 수정 요청
						$.ajax({
							url: "/coupon/edit.dox",
							dataType: "json",
							type: "POST",
							data: param,

							success: function (data) {
								if (data.result === "success") {
									alert(data.message);
									location.href = "/coupon/list.do";
								} else {
									alert(data.message);
								}
							},

							error: function (xhr, status, error) {
								console.log(xhr.responseText);
								console.log(error);
								alert("쿠폰 수정 중 오류가 발생했습니다.");
							}
						});
					},

					// 쿠폰 상세정보 조회
					fnGetCouponList() {

						let self = this;

						$.ajax({
							url: "/coupon/view.dox",
							type: "POST",
							dataType: "json",

							data: {
								couponId: self.couponId
							},

							success: function (data) {

								console.log(data);

								if (data.result === "success") {

									// 쿠폰 기본 정보 저장
									self.couponName = data.info.couponName;
									self.discountType = data.info.discountType;
									self.discountValue = data.info.discountValue;
									self.minimumOrderAmount = data.info.minimumOrderAmount;
									self.maximumDiscountAmount = data.info.maximumDiscountAmount;

									// DB에서 가져온 날짜의 T를 공백으로 변경
									// 2026-11-26T17:17:00
									// 2026-11-26 17:17:00
									let fromDate = data.info.validFrom
										? String(data.info.validFrom).replace("T", " ")
										: "";

									let untilDate = data.info.validUntil
										? String(data.info.validUntil).replace("T", " ")
										: "";

									// Vue 변수에 날짜 저장
									self.validFrom = fromDate;
									self.validUntil = untilDate;

									// Vue 화면 갱신 후 달력에 기존 날짜 설정
									self.$nextTick(function () {

										if (fromDate) {
											self.validFromPicker.setDate(
												fromDate,
												false,
												"Y-m-d H:i:S"
											);
										}

										if (untilDate) {
											self.validUntilPicker.setDate(
												untilDate,
												false,
												"Y-m-d H:i:S"
											);
										}
									});

								} else {
									alert(data.message || "쿠폰 조회에 실패했습니다.");
								}
							},

							error: function (xhr, status, error) {
								console.log(xhr.responseText);
								console.log(error);
								alert("쿠폰 정보를 불러오는 중 오류가 발생했습니다.");
							}
						});
					},

					// 목록 화면으로 이동
					fnCancel() {
						location.href = "/coupon/list.do";
					}
				},

				mounted() {

					// 먼저 달력을 생성
					this.fnInitDatePicker();

					// 쿠폰 상세정보 조회
					this.fnGetCouponList();
				}
			});

			app.mount("#app");
		</script>

	</body>

	</html>