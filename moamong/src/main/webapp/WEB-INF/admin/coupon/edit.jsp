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

		<link rel="stylesheet" href="/css/admin/adminLayout.css">
		<link rel="stylesheet" href="/css/admin/coupon/add.css">
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">

		<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
		<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js"></script>

		<style>
			.flatpickr-calendar {
				z-index: 9999;
			}

			#validFrom,
			#validUntil {
				cursor: pointer;
			}
		</style>
	</head>

	<body>

		<%@ include file="/WEB-INF/common/adminHeader.jsp"%>

		<div class="adm-shell">

			<%@ include file="/WEB-INF/common/adminSidebar.jsp"%>

			<main class="adm-main">

				<div id="app">

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

			</main>

		</div>

		<script>
			const app = Vue.createApp({

				data() {
					return {
						couponName: "",
						discountType: "FIXED",
						discountValue: null,
						minimumOrderAmount: 0,
						maximumDiscountAmount: null,

						validFrom: "",
						validUntil: "",

						couponId: "${couponId}",

						validFromPicker: null,
						validUntilPicker: null
					};
				},

				watch: {
					// 정액 할인은 최대 할인 금액 미사용
					discountType(newValue) {
						if (newValue === "FIXED") {
							this.maximumDiscountAmount = null;
						}
					}
				},

				methods: {

					// 달력 초기화
					fnInitDatePicker() {
						let self = this;

						flatpickr.localize(flatpickr.l10ns.ko);

						self.validFromPicker = flatpickr("#validFrom", {
							enableTime: true,
							time_24hr: true,
							dateFormat: "Y-m-d H:i",
							position: "below",
							allowInput: false,

							onChange: function (selectedDates, dateStr) {
								self.validFrom = dateStr;
							}
						});

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

						if (!self.couponId) {
							alert("쿠폰 번호를 확인할 수 없습니다.");
							return;
						}

						if (!self.couponName.trim()) {
							alert("쿠폰명을 입력해주세요.");
							return;
						}

						if (self.discountValue === null || self.discountValue <= 0) {
							alert("할인 값을 올바르게 입력해주세요.");
							return;
						}

						if (self.discountType === "RATE" && self.discountValue > 100) {
							alert("할인율은 100%를 초과할 수 없습니다.");
							return;
						}

						if (self.minimumOrderAmount === null || self.minimumOrderAmount < 0) {
							alert("최소 주문 금액을 올바르게 입력해주세요.");
							return;
						}

						if (self.discountType === "RATE"
							&& self.maximumDiscountAmount !== null
							&& self.maximumDiscountAmount < 0) {
							alert("최대 할인 금액을 올바르게 입력해주세요.");
							return;
						}

						if (!self.validFrom) {
							alert("사용 시작일을 선택해주세요.");
							return;
						}

						if (!self.validUntil) {
							alert("사용 종료일을 선택해주세요.");
							return;
						}

						if (new Date(self.validFrom) >= new Date(self.validUntil)) {
							alert("사용 종료일은 시작일보다 늦어야 합니다.");
							return;
						}

						let param = {
							couponName: self.couponName,
							discountType: self.discountType,
							discountValue: self.discountValue,
							minimumOrderAmount: self.minimumOrderAmount,

							maximumDiscountAmount: self.discountType === "RATE"
								? self.maximumDiscountAmount
								: null,

							validFrom: self.validFrom,
							validUntil: self.validUntil,
							couponId: self.couponId
						};

						$.ajax({
							url: "/coupon/edit.dox",
							type: "POST",
							dataType: "json",
							data: param,

							success: function (data) {
								if (data.result === "success") {
									alert(data.message);
									location.href = "/coupon/list.do";
								} else {
									alert(data.message || "쿠폰 수정에 실패했습니다.");
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
								console.log("쿠폰 조회 응답:", data);

								if (data.result !== "success") {
									alert(data.message || "쿠폰 조회에 실패했습니다.");
									return;
								}

								// Controller에서 반환하는 coupon 데이터
								let coupon = data.coupon;

								if (!coupon) {
									alert("쿠폰 정보를 찾을 수 없습니다.");
									return;
								}

								self.couponName = coupon.couponName || "";
								self.discountType = coupon.discountType || "FIXED";
								self.discountValue = coupon.discountValue;
								self.minimumOrderAmount = coupon.minimumOrderAmount || 0;
								self.maximumDiscountAmount = coupon.maximumDiscountAmount;

								// DB 날짜 형식 변환
								let fromDate = coupon.validFrom
									? String(coupon.validFrom).replace("T", " ").substring(0, 16)
									: "";

								let untilDate = coupon.validUntil
									? String(coupon.validUntil).replace("T", " ").substring(0, 16)
									: "";

								self.validFrom = fromDate;
								self.validUntil = untilDate;

								// 달력에 기존 날짜 설정
								self.$nextTick(function () {
									if (fromDate && self.validFromPicker) {
										self.validFromPicker.setDate(
											fromDate,
											false,
											"Y-m-d H:i"
										);
									}

									if (untilDate && self.validUntilPicker) {
										self.validUntilPicker.setDate(
											untilDate,
											false,
											"Y-m-d H:i"
										);
									}
								});
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
					this.fnInitDatePicker();
					this.fnGetCouponList();
				}
			});

			app.mount("#app");
		</script>

	</body>

	</html>