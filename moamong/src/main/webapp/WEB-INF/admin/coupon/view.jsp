<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>쿠폰 회수 관리</title>

		<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

		<link rel="stylesheet" href="/css/admin/coupon/add.css">
		<link rel="stylesheet" href="/css/admin/coupon/view.css">
	</head>

	<body>

		<div id="app" class="container">

			<div class="page-header">
				<div>
					<h2>쿠폰 회수 관리</h2>
					<p>쿠폰 상세 정보와 발급 회원을 확인하고 쿠폰을 회수할 수 있습니다.</p>
				</div>
			</div>

			<div class="form-container" v-if="coupon">

				<!-- 쿠폰 기본 정보 -->
				<div class="form-section">
					<h3>쿠폰 기본 정보</h3>

					<div class="detail-group">
						<div class="detail-item">
							<label>쿠폰 번호</label>
							<div class="detail-value">{{ coupon.couponId }}</div>
						</div>

						<div class="detail-item">
							<label>쿠폰명</label>
							<div class="detail-value">{{ coupon.couponName }}</div>
						</div>

						<div class="detail-item">
							<label>할인 유형</label>
							<div class="detail-value">
								{{ coupon.discountType === 'FIXED' ? '정액 할인' : '정률 할인' }}
							</div>
						</div>

						<div class="detail-item">
							<label>할인 혜택</label>
							<div class="detail-value">
								{{ coupon.discountType === 'FIXED'
								? Number(coupon.discountValue).toLocaleString() + '원'
								: coupon.discountValue + '%' }}
							</div>
						</div>

						<div class="detail-item">
							<label>최소 주문 금액</label>
							<div class="detail-value">
								{{ Number(coupon.minimumOrderAmount || 0).toLocaleString() }}원
							</div>
						</div>

						<div class="detail-item">
							<label>최대 할인 금액</label>
							<div class="detail-value">
								{{ coupon.maximumDiscountAmount
								? Number(coupon.maximumDiscountAmount).toLocaleString() + '원'
								: '-' }}
							</div>
						</div>

						<div class="detail-item">
							<label>사용 시작일</label>
							<div class="detail-value">{{ coupon.validFrom }}</div>
						</div>

						<div class="detail-item">
							<label>사용 종료일</label>
							<div class="detail-value">{{ coupon.validUntil }}</div>
						</div>
					</div>
				</div>

				<!-- 발급 현황 -->
				<div class="form-section">
					<h3>발급 및 사용 현황</h3>

					<div class="stats-group">
						<div class="stats-card">
							<p>총 발급 건수</p>
							<strong>{{ coupon.issuedCount || 0 }}건</strong>
						</div>

						<div class="stats-card">
							<p>사용 완료</p>
							<strong>{{ coupon.usedCount || 0 }}건</strong>
						</div>

						<div class="stats-card">
							<p>회수 가능</p>
							<strong>{{ coupon.availableCount || 0 }}건</strong>
						</div>
					</div>
				</div>

				<!-- 발급 회원 목록 -->
				<div class="form-section">

					<div class="page-header">
						<div>
							<h3>발급 회원 목록</h3>
							<p>발급된 쿠폰의 회원별 사용 상태를 확인할 수 있습니다.</p>
						</div>

						<button class="btn-delete" @click="fnRevokeAll"
							:disabled="Number(coupon.availableCount || 0) === 0">
							미사용 쿠폰 일괄 회수
						</button>
					</div>

					<div class="table-container">
						<table>
							<thead>
								<tr>
									<th>회원 번호</th>
									<th>로그인 ID</th>
									<th>회원 이름</th>
									<th>발급일</th>
									<th>쿠폰 상태</th>
									<th>회수일</th>
									<th>관리</th>
								</tr>
							</thead>

							<tbody>
								<tr v-for="member in memberList" :key="member.memberCouponId">

									<td>{{ member.memberId }}</td>
									<td>{{ member.loginId || '-' }}</td>
									<td>{{ member.memberName || '탈퇴 회원' }}</td>
									<td>{{ member.issuedAt || '-' }}</td>

									<td>
										<span v-if="member.displayStatus === 'AVAILABLE'">
											미사용
										</span>
										<span v-else-if="member.displayStatus === 'USED'">
											사용 완료
										</span>
										<span v-else-if="member.displayStatus === 'EXPIRED'">
											만료
										</span>
										<span v-else-if="member.displayStatus === 'REVOKED'">
											회수 완료
										</span>
										<span v-else>
											{{ member.displayStatus }}
										</span>
									</td>

									<td>{{ member.revokedAt || '-' }}</td>

									<td>
										<button class="btn-delete" :disabled="member.displayStatus !== 'AVAILABLE'"
											@click="fnRevoke(member)">
											회수
										</button>
									</td>

								</tr>

								<tr v-if="memberList.length === 0">
									<td colspan="7">발급된 회원이 없습니다.</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>

				<!-- 하단 버튼 -->
				<div class="button-area">
					<button class="btn-cancel" @click="fnList">
						목록으로
					</button>
				</div>

			</div>

			<div class="form-container" v-else>
				<p>쿠폰 정보를 불러오는 중입니다.</p>
			</div>

		</div>

		<script>
			const app = Vue.createApp({

				data() {
					return {
						couponId: new URLSearchParams(location.search).get("couponId"),
						coupon: null,
						memberList: []
					};
				},

				methods: {

					// 쿠폰 및 발급 회원 조회
					fnGetCoupon() {

						let self = this;

						if (!this.couponId) {
							alert("쿠폰 번호가 없습니다.");
							this.fnList();
							return;
						}

						$.ajax({
							url: "/coupon/issued/list.dox",
							type: "POST",
							dataType: "json",
							data: {
								couponId: self.couponId
							},
							success: function (data) {

								if (data.result === "success") {
									self.coupon = data.coupon;
									self.memberList = data.list || [];
								} else {
									alert(data.message || "쿠폰 조회 실패");
									self.fnList();
								}
							},
							error: function (xhr) {
								console.log(xhr.responseText);
								alert("쿠폰 조회 중 오류가 발생했습니다.");
							}
						});
					},

					// 회원 쿠폰 개별 회수
					fnRevoke(member) {

						let self = this;

						if (member.displayStatus !== "AVAILABLE") {
							alert("회수할 수 없는 쿠폰입니다.");
							return;
						}

						if (!confirm(member.memberName + " 회원의 쿠폰을 회수할까요?")) {
							return;
						}

						$.ajax({
							url: "/coupon/revoke.dox",
							type: "POST",
							dataType: "json",
							data: {
								couponId: self.couponId,
								memberCouponId: member.memberCouponId
							},
							success: function (data) {

								alert(data.message);

								if (data.result === "success") {
									self.fnGetCoupon();
								}
							},
							error: function (xhr) {
								console.log(xhr.responseText);
								alert("쿠폰 회수 중 오류가 발생했습니다.");
							}
						});
					},

					// 사용 가능한 쿠폰 일괄 회수
					fnRevokeAll() {

						let self = this;

						if (Number(this.coupon.availableCount || 0) === 0) {
							alert("회수할 수 있는 쿠폰이 없습니다.");
							return;
						}

						if (!confirm("해당 쿠폰의 미사용 발급 내역을 모두 회수할까요?")) {
							return;
						}

						$.ajax({
							url: "/coupon/revoke/all.dox",
							type: "POST",
							dataType: "json",
							data: {
								couponId: self.couponId
							},
							success: function (data) {

								alert(data.message);

								if (data.result === "success") {
									self.fnGetCoupon();
								}
							},
							error: function (xhr) {
								console.log(xhr.responseText);
								alert("일괄 회수 중 오류가 발생했습니다.");
							}
						});
					},

					// 목록 이동
					fnList() {
						location.href = "/admin/coupon/list.do";
					}
				},

				mounted() {
					this.fnGetCoupon();
				}

			});

			app.mount("#app");
		</script>

	</body>

	</html>