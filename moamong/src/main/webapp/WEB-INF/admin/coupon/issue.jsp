<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>쿠폰 발급</title>

		<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

		<link rel="stylesheet" href="/css/admin/adminLayout.css">
		<link rel="stylesheet" href="/css/admin/coupon/issue.css">
	</head>

	<body>

		<%@ include file="/WEB-INF/common/adminHeader.jsp"%>

		<div class="adm-shell">

			<%@ include file="/WEB-INF/common/adminSidebar.jsp"%>

			<main class="adm-main">

				<div id="app">

					<!-- 페이지 제목 -->
					<div class="page-header">
						<div>
							<h2>쿠폰 발급</h2>
							<p>회원에게 쿠폰을 발급할 수 있습니다.</p>
						</div>
						<div class="button-area">
							<button class="btn-return" @click="fnList">목록으로</button>
						</div>
					</div>

					<div class="form-container">

						<!-- 쿠폰 선택 -->
						<div class="form-section">
							<h3>1. 발급 쿠폰 선택</h3>

							<div class="form-group">
								<label>발급할 쿠폰 <span>*</span></label>
								<select v-model="couponId">
									<option value="">쿠폰을 선택하세요.</option>
									<option v-for="coupon in couponList" :key="coupon.couponId"
										:value="String(coupon.couponId)">
										{{ coupon.couponName }}
										({{ coupon.discountType === 'FIXED'
										? coupon.discountValue + '원'
										: coupon.discountValue + '%' }})
									</option>
								</select>
							</div>
						</div>

						<!-- 발급 대상 선택 -->
						<div class="form-section">
							<h3>2. 발급 대상 선택</h3>

							<div class="radio-group">
								<label>
									<input type="radio" value="ALL" v-model="issueType">
									전체 회원 발급
								</label>

								<label>
									<input type="radio" value="SELECT" v-model="issueType">
									회원 선택 발급
								</label>
							</div>
						</div>

						<!-- 회원 검색 -->
						<div class="form-section" v-if="issueType === 'SELECT'">
							<h3>3. 회원 검색</h3>

							<div class="search-area">
								<input type="text" v-model="keyword" placeholder="회원 이름 또는 로그인 ID"
									@keyup.enter="fnSearchMember">

								<button class="btn-search" @click="fnSearchMember">검색</button>
							</div>

							<div class="table-container">
								<table>
									<thead>
										<tr>
											<th>선택</th>
											<th>회원 번호</th>
											<th>로그인 ID</th>
											<th>회원 이름</th>
										</tr>
									</thead>

									<tbody>
										<tr v-for="member in memberList" :key="member.memberId">
											<td>
												<input type="checkbox" :value="member.memberId" v-model="selectedMembers">
											</td>
											<td>{{ member.memberId }}</td>
											<td>{{ member.loginId }}</td>
											<td>{{ member.memberName }}</td>
										</tr>

										<tr v-if="memberList.length === 0">
											<td colspan="4">검색된 회원이 없습니다.</td>
										</tr>
									</tbody>
								</table>
							</div>

							<p class="selected-count">
								선택 회원: <strong>{{ selectedMembers.length }}명</strong>
							</p>
						</div>

						<!-- 발급 정보 확인 -->
						<div class="form-section">
							<h3>발급 정보 확인</h3>

							<div class="issue-info">
								<p>
									발급 대상:
									<strong>
										{{ issueType === 'ALL'
										? '전체 회원'
										: selectedMembers.length + '명' }}
									</strong>
								</p>
							</div>
						</div>

						<!-- 하단 버튼 -->
						<div class="button-area">
							<button class="btn-cancel" @click="fnList">취소</button>
							<button class="btn-submit" @click="fnIssueCoupon">
								쿠폰 발급하기
							</button>
						</div>

					</div>

				</div>

			</main>

		</div>

		<script>
			const app = Vue.createApp({
				data() {
					return {
						couponList: [],
						memberList: [],
						couponId: "",
						issueType: "ALL",
						keyword: "",
						selectedMembers: []
					};
				},
				methods: {
					// 쿠폰 목록 조회
					fnGetCouponList() {
						let self = this;

						$.ajax({
							url: "/coupon/list.dox",
							type: "POST",
							dataType: "json",
							success: function (data) {
								if (data.result === "success") {

									self.couponList = (data.list || []).filter(coupon => {
										return coupon.issueStatus === "ACTIVE";
									});

								}
							},
						});
					},

					// 회원 검색
					fnSearchMember() {
						let self = this;

						if (!this.keyword.trim()) {
							alert("검색어를 입력하세요.");
							return;
						}

						$.ajax({
							url: "/coupon/member/search.dox",
							type: "POST",
							dataType: "json",
							data: {
								keyword: self.keyword
							},
							success: function (data) {
								if (data.result === "success") {
									self.memberList = data.list || [];
								} else {
									alert(data.message || "회원 검색 실패");
								}
							},
							error: function () {
								alert("회원 검색 중 오류 발생");
							}
						});
					},

					// 쿠폰 발급
					fnIssueCoupon() {
						let self = this;

						if (!this.couponId) {
							alert("발급할 쿠폰을 선택하세요.");
							return;
						}

						if (this.issueType === "SELECT"
							&& this.selectedMembers.length === 0) {
							alert("발급할 회원을 선택하세요.");
							return;
						}

						if (!confirm("선택한 대상에게 쿠폰을 발급할까요?")) {
							return;
						}

						$.ajax({
							url: "/coupon/issue.dox",
							type: "POST",
							dataType: "json",
							data: {
								couponId: self.couponId,
								issueType: self.issueType,
								memberIds: self.selectedMembers.join(",")
							},
							success: function (data) {

								if (data.result === "success") {

									alert(
										"쿠폰 발급 완료\n"
										+ "신규 발급: " + data.issuedCount + "건\n"
										+ "중복 제외: " + data.duplicateCount + "건"
									);

									self.selectedMembers = [];
									self.fnGetCouponList();

								} else {

									alert(data.message || "쿠폰 발급에 실패했습니다.");

								}
							}
						});
					},

					// 목록 이동
					fnList() {
						location.href = "/admin/coupon/list.do";
					}
				},

				mounted() {
					this.fnGetCouponList();
				}
			});

			app.mount("#app");
		</script>

	</body>

	</html>