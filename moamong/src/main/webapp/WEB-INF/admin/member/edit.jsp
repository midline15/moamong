<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">

		<title>회원 상세 정보</title>

		<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
		<script src="/js/page-change.js"></script>

		<link rel="stylesheet" href="/css/admin/default.css">
		<link rel="stylesheet" href="/css/admin/member/edit.css">
	</head>

	<body>

		<header class="header">
			<div class="logo">Logo</div>
		</header>

		<div id="app">

			<div class="admin-container">

				<!-- 사이드바 -->
				<aside class="sidebar">

					<div class="sidebar-title">
						관리자 페이지
					</div>

					<ul>
						<li class="active" onclick="location.href='/admin/member/list.do'">
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
						<h3>회원 상세 정보</h3>
					</div>

					<div class="breadcrumb">
						회원 관리 / 회원 목록 / 회원 상세 정보
					</div>

					<div class="content-area">

						<!-- 회원 프로필 -->
						<div class="user-profile">

							<div class="profile-left">

								<div class="profile-image">

									<!-- 추후 회원 프로필 이미지 연동 -->
									<!-- <img :src="userInfo.profileImage" alt="회원 프로필"> -->

									<span>●</span>

								</div>

								<div class="profile-name">

									<strong>{{ userInfo.memberName || '-' }}</strong>

									<span>{{ userInfo.email || '-' }}</span>

									<div class="profile-badges">

										<span class="grade-badge">
											{{ userInfo.memberGrade || '-' }}
										</span>

										<span class="status-badge" :class="fnStatusClass(userInfo.status)">
											{{ fnStatusName(userInfo.status) }}
										</span>

									</div>

								</div>

							</div>

							<div class="profile-right">

								<div class="profile-info-item">
									<span>회원 번호</span>
									<strong>{{ userInfo.memberId || '-' }}</strong>
								</div>

								<div class="profile-info-item">
									<span>가입일</span>
									<strong>{{ userInfo.createdAt || '-' }}</strong>
								</div>

								<div class="profile-info-item">
									<span>최근 로그인</span>
									<strong>{{ userInfo.lastLoginAt || '-' }}</strong>
								</div>

								<div class="profile-info-item">
									<span>휴대폰 번호</span>
									<strong>{{ userInfo.phone || '-' }}</strong>
								</div>

							</div>

							<div class="profile-buttons">

								<button class="btn-profile-edit" @click="fnEditUser"
									:disabled="userInfo.status === 'WITHDRAWN'">
									회원 정보 수정
								</button>

							</div>

						</div>

						<!-- 기본 정보 -->
						<div class="detail-info-area">

							<div class="detail-info-box">

								<h3>기본 정보</h3>

								<div class="info-row">
									<span>이름</span>
									<strong>{{ userInfo.memberName || '-' }}</strong>
								</div>

								<div class="info-row">
									<span>아이디</span>
									<strong>{{ userInfo.loginId || '-' }}</strong>
								</div>

								<div class="info-row">
									<span>이메일</span>
									<strong>{{ userInfo.email || '-' }}</strong>
								</div>

								<div class="info-row">
									<span>연락처</span>
									<strong>{{ userInfo.phone || '-' }}</strong>
								</div>

								<!-- 추후 주소 연동 -->
								<!--
                            <div class="info-row">
                                <span>주소</span>
                                <strong>{{ userInfo.address || '-' }}</strong>
                            </div>
                            -->

							</div>

							<div class="detail-info-box">

								<h3>회원 활동 정보</h3>

								<div class="info-row">
									<span>회원 등급</span>
									<strong>{{ userInfo.memberGrade || '-' }}</strong>
								</div>

								<!-- 추후 마케팅 수신 동의 연동 -->
								<!--
                            <div class="info-row">
                                <span>마케팅 수신 동의</span>
                                <strong>{{ userInfo.marketingAgree || '-' }}</strong>
                            </div>
                            -->

								<div class="info-row">
									<span>가입일</span>
									<strong>{{ userInfo.createdAt || '-' }}</strong>
								</div>

								<div class="info-row">
									<span>최근 로그인</span>
									<strong>{{ userInfo.lastLoginAt || '-' }}</strong>
								</div>

								<div class="info-row">
									<span>계정 상태</span>
									<strong class="status-badge" :class="fnStatusClass(userInfo.status)">
										{{ fnStatusName(userInfo.status) }}
									</strong>
								</div>

							</div>

						</div>

						<!-- 회원 등급 및 상태 관리 -->
						<div class="member-manage-area">

							<!-- 등급 관리 -->
							<div class="manage-box">

								<h3>회원 등급 관리</h3>

								<div class="manage-row">
									<span>현재 회원 등급</span>
									<strong>{{ userInfo.memberGrade || '-' }}</strong>
								</div>

								<div class="manage-row">
									<span>등급 변경</span>
									<strong>관리자 수동 변경</strong>
								</div>

								<div class="manage-actions">

									<button @click="fnOpenGradeModal" :disabled="userInfo.status === 'WITHDRAWN'">
										등급 변경
									</button>

								</div>

							</div>

							<!-- 상태 관리 -->
							<div class="manage-box">

								<h3>회원 상태 관리</h3>

								<div class="manage-row">
									<span>현재 계정 상태</span>
									<strong class="status-badge" :class="fnStatusClass(userInfo.status)">
										{{ fnStatusName(userInfo.status) }}
									</strong>
								</div>

								<div class="manage-row">
									<span>관리 기능</span>
									<strong>상태 변경 및 강제 탈퇴</strong>
								</div>

								<div class="manage-actions">

									<button @click="fnOpenStatusModal" :disabled="userInfo.status === 'WITHDRAWN'">
										상태 변경
									</button>

									<button class="btn-danger" @click="fnWithdraw"
										:disabled="userInfo.status === 'WITHDRAWN'">
										강제 탈퇴
									</button>

								</div>

							</div>

						</div>

						<!-- 관리자 메모: 추후 기능 재개 시 주석 해제 -->
						<!--
                    <div class="history-area">

                        <h3>관리자 메모</h3>

                        <div class="modal-item">
                            <textarea v-model="adminMemo"
                                placeholder="회원 관리 관련 특이사항을 입력하세요."></textarea>
                        </div>

                        <div class="modal-buttons">
                            <button class="btn-confirm" @click="fnSaveMemo">
                                메모 저장
                            </button>
                        </div>

                    </div>
                    -->

						<!-- 회원 변경 이력 -->
						<div class="history-area">

							<h3>회원 변경 이력</h3>

							<table class="history-table">

								<thead>
									<tr>
										<th>변경일</th>
										<th>관리자</th>
										<th>변경 종류</th>
										<th>변경 항목</th>
										<th>변경 전</th>
										<th>변경 후</th>
										<th>변경 사유</th>
									</tr>
								</thead>

								<tbody>

									<tr v-for="(item, index) in historyList" :key="item.historyId || index">

										<td>{{ item.createdAt || '-' }}</td>

										<td>{{ item.adminName || '-' }}</td>

										<td>{{ fnHistoryType(item.changeType) }}</td>

										<td>{{ item.changeField || '-' }}</td>

										<td>{{ item.beforeValue || '-' }}</td>

										<td>{{ item.afterValue || '-' }}</td>

										<td>{{ item.reason || '-' }}</td>

									</tr>

									<tr v-if="historyList.length === 0">
										<td colspan="7">
											변경 이력이 없습니다.
										</td>
									</tr>

								</tbody>

							</table>

						</div>

						<!-- 목록으로 -->
						<div class="detail-footer">

							<button class="btn-back" @click="fnBack">
								목록으로
							</button>

						</div>

					</div>

				</main>

			</div>

			<!-- 회원정보 수정 모달 -->
			<div class="modal-overlay" v-if="showInfoModal">

				<div class="manage-modal">

					<h3>회원정보 수정</h3>

					<div class="modal-item">

						<label>회원 이름</label>

						<input type="text" v-model="editInfo.memberName" placeholder="회원 이름 입력">

					</div>

					<div class="modal-item">

						<label>이메일</label>

						<input type="email" v-model="editInfo.email" placeholder="이메일 입력">

					</div>

					<div class="modal-item">

						<label>휴대폰 번호</label>

						<input type="text" v-model="editInfo.phone" placeholder="010-0000-0000">

					</div>

					<div class="modal-buttons">

						<button @click="showInfoModal = false">
							취소
						</button>

						<button class="btn-confirm" @click="fnUpdateInfo">
							수정 저장
						</button>

					</div>

				</div>

			</div>

			<!-- 등급 변경 모달 -->
			<div class="modal-overlay" v-if="showGradeModal">

				<div class="manage-modal">

					<h3>회원 등급 변경</h3>

					<div class="modal-item">
						<label>현재 등급</label>
						<strong>{{ userInfo.memberGrade || '-' }}</strong>
					</div>

					<div class="modal-item">

						<label>변경할 등급</label>

						<select v-model="changeGrade">
							<option value="BRONZE">BRONZE</option>
							<option value="SILVER">SILVER</option>
							<option value="GOLD">GOLD</option>
							<option value="VIP">VIP</option>
						</select>

					</div>

					<div class="modal-item">

						<label>변경 사유</label>

						<textarea v-model="changeReason" placeholder="등급 변경 사유를 입력하세요."></textarea>

					</div>

					<div class="modal-buttons">

						<button @click="showGradeModal = false">
							취소
						</button>

						<button class="btn-confirm" @click="fnChangeGrade">
							변경
						</button>

					</div>

				</div>

			</div>

			<!-- 상태 변경 모달 -->
			<div class="modal-overlay" v-if="showStatusModal">

				<div class="manage-modal">

					<h3>회원 상태 변경</h3>

					<div class="modal-item">

						<label>현재 상태</label>
						<strong>{{ fnStatusName(userInfo.status) }}</strong>

					</div>

					<div class="modal-item">

						<label>변경할 상태</label>

						<select v-model="changeStatus">
							<option value="ACTIVE">정상</option>
							<option value="SUSPENDED">정지</option>
							<option value="INACTIVE">휴면</option>
						</select>

					</div>

					<div class="modal-item">

						<label>변경 사유</label>

						<textarea v-model="changeReason" placeholder="상태 변경 사유를 입력하세요."></textarea>

					</div>

					<div class="modal-buttons">

						<button @click="showStatusModal = false">
							취소
						</button>

						<button class="btn-confirm" @click="fnChangeStatus">
							변경
						</button>

					</div>

				</div>

			</div>

		</div>

		<script>

			const app = Vue.createApp({

				data() {

					return {

						memberId: "${memberId}",

						userInfo: {},

						historyList: [],

						// 관리자 메모 기능 재개 시 사용
						// adminMemo: "",

						// 모달 상태
						showInfoModal: false,
						showGradeModal: false,
						showStatusModal: false,

						// 회원정보 수정
						editInfo: {
							memberName: "",
							email: "",
							phone: ""
						},

						// 등급 및 상태 변경
						changeGrade: "",
						changeStatus: "",
						changeReason: ""

					};

				},

				methods: {

					// 회원 상세 조회
					fnGetUserDetail() {

						let self = this;

						if (!self.memberId) {
							alert("회원 번호가 없습니다.");
							return;
						}

						$.ajax({

							url: "/admin/member/edit.dox",
							type: "POST",
							dataType: "json",

							data: {
								memberId: self.memberId
							},

							success: function (data) {

								console.log("회원 상세 조회 결과:", data);

								if (data.result === "success") {

									self.userInfo = data.userInfo || {};
									self.historyList = data.historyList || [];

								} else {

									alert(data.message || "회원 정보 조회 실패");

								}

							},

							error: function (xhr, status, error) {

								console.error("회원 조회 오류:", xhr.responseText);
								console.error("상태:", status);
								console.error("오류:", error);

								alert("회원 정보를 불러오지 못했습니다.");

							}

						});

					},

					// 숫자 포맷
					fnFormatNumber(value) {

						return Number(value || 0).toLocaleString();

					},

					// 상태명 변환
					fnStatusName(status) {

						const statusMap = {
							ACTIVE: "정상",
							SUSPENDED: "정지",
							WITHDRAWN: "탈퇴",
							INACTIVE: "휴면"
						};

						return statusMap[status] || status || "-";

					},

					// 상태 CSS
					fnStatusClass(status) {

						const classMap = {
							ACTIVE: "normal",
							SUSPENDED: "suspended",
							WITHDRAWN: "withdrawn",
							INACTIVE: "inactive"
						};

						return classMap[status] || "";

					},

					// 변경 종류 변환
					fnHistoryType(type) {

						const typeMap = {
							GRADE: "등급 변경",
							STATUS: "상태 변경",
							INFO: "회원정보 수정",
							WITHDRAW: "강제 탈퇴"
						};

						return typeMap[type] || type || "-";

					},

					// 회원정보 수정 모달
					fnEditUser() {

						if (this.userInfo.status === "WITHDRAWN") {
							alert("탈퇴 회원은 수정할 수 없습니다.");
							return;
						}

						this.editInfo = {
							memberName: this.userInfo.memberName || "",
							email: this.userInfo.email || "",
							phone: this.userInfo.phone || ""
						};

						this.showInfoModal = true;

					},

					// 회원정보 수정 저장
					fnUpdateInfo() {

						let self = this;

						if (!self.editInfo.memberName.trim()) {
							alert("회원 이름을 입력하세요.");
							return;
						}

						if (!self.editInfo.email.trim()) {
							alert("이메일을 입력하세요.");
							return;
						}

						if (!self.editInfo.phone.trim()) {
							alert("휴대폰 번호를 입력하세요.");
							return;
						}

						if (!confirm("회원정보를 수정하시겠습니까?")) {
							return;
						}

						$.ajax({

							url: "/admin/member/info/update.dox",
							type: "POST",
							dataType: "json",

							data: {
								memberId: self.memberId,
								memberName: self.editInfo.memberName.trim(),
								email: self.editInfo.email.trim(),
								phone: self.editInfo.phone.trim()
							},

							success: function (data) {

								if (data.result === "success") {

									alert("회원정보가 수정되었습니다.");

									self.showInfoModal = false;
									self.fnGetUserDetail();

								} else {

									alert(data.message || "회원정보 수정 실패");

								}

							},

							error: function (xhr, status, error) {

								console.error("회원정보 수정 오류:", xhr.responseText);
								console.error("상태:", status);
								console.error("오류:", error);

								alert("서버 통신 오류");

							}

						});

					},

					// 등급 변경 모달
					fnOpenGradeModal() {

						if (this.userInfo.status === "WITHDRAWN") {
							alert("탈퇴 회원은 등급을 변경할 수 없습니다.");
							return;
						}

						this.changeGrade = this.userInfo.memberGrade || "BRONZE";
						this.changeReason = "";
						this.showGradeModal = true;

					},

					// 등급 변경
					fnChangeGrade() {

						let self = this;

						if (!self.changeGrade) {
							alert("변경할 등급을 선택하세요.");
							return;
						}

						if (self.changeGrade === self.userInfo.memberGrade) {
							alert("현재 등급과 동일합니다.");
							return;
						}

						if (!self.changeReason.trim()) {
							alert("변경 사유를 입력하세요.");
							return;
						}

						if (!confirm("회원 등급을 변경하시겠습니까?")) {
							return;
						}

						$.ajax({

							url: "/admin/member/grade/update.dox",
							type: "POST",
							dataType: "json",

							data: {
								memberId: self.memberId,
								memberGrade: self.changeGrade,
								reason: self.changeReason
							},

							success: function (data) {

								console.log("등급 변경 응답:", data);

								if (data.result === "success") {

									alert("회원 등급이 변경되었습니다.");

									self.showGradeModal = false;
									self.fnGetUserDetail();

								} else {

									alert(data.message || "등급 변경 실패");

								}

							},

							error: function (xhr, status, error) {

								console.error("등급 변경 오류:", xhr.responseText);
								alert("서버 통신 오류");

							}

						});

					},

					// 상태 변경 모달
					fnOpenStatusModal() {

						if (this.userInfo.status === "WITHDRAWN") {
							alert("탈퇴 회원은 상태를 변경할 수 없습니다.");
							return;
						}

						this.changeStatus = this.userInfo.status;
						this.changeReason = "";
						this.showStatusModal = true;

					},

					// 상태 변경
					fnChangeStatus() {

						let self = this;

						if (!self.changeStatus) {
							alert("변경할 상태를 선택하세요.");
							return;
						}

						if (self.changeStatus === self.userInfo.status) {
							alert("현재 상태와 동일합니다.");
							return;
						}

						if (!self.changeReason.trim()) {
							alert("변경 사유를 입력하세요.");
							return;
						}

						if (!confirm("회원 상태를 변경하시겠습니까?")) {
							return;
						}

						$.ajax({

							url: "/admin/member/status/update.dox",
							type: "POST",
							dataType: "json",

							data: {
								memberId: self.memberId,
								status: self.changeStatus,
								reason: self.changeReason
							},

							success: function (data) {

								if (data.result === "success") {

									alert("회원 상태가 변경되었습니다.");

									self.showStatusModal = false;
									self.fnGetUserDetail();

								} else {

									alert(data.message || "상태 변경 실패");

								}

							},

							error: function (xhr, status, error) {

								console.error("상태 변경 오류:", xhr.responseText);
								alert("서버 통신 오류");

							}

						});

					},

					// 강제 탈퇴
					fnWithdraw() {

						let self = this;

						if (self.userInfo.status === "WITHDRAWN") {
							alert("이미 탈퇴 처리된 회원입니다.");
							return;
						}

						let reason = prompt("강제 탈퇴 사유를 입력하세요.");

						if (reason === null) {
							return;
						}

						if (!reason.trim()) {
							alert("탈퇴 사유를 입력하세요.");
							return;
						}

						if (!confirm("정말로 해당 회원을 강제 탈퇴 처리하시겠습니까?")) {
							return;
						}

						$.ajax({

							url: "/admin/member/withdraw.dox",
							type: "POST",
							dataType: "json",

							data: {
								memberId: self.memberId,
								reason: reason
							},

							success: function (data) {

								if (data.result === "success") {

									alert("회원 탈퇴 처리가 완료되었습니다.");
									self.fnGetUserDetail();

								} else {

									alert(data.message || "탈퇴 처리 실패");

								}

							},

							error: function (xhr, status, error) {

								console.error("회원 탈퇴 오류:", xhr.responseText);
								alert("서버 통신 오류");

							}

						});

					},

					// 관리자 메모 기능 재개 시 사용
					/*
					fnSaveMemo() {
	
						let self = this;
	
						if (!self.adminMemo.trim()) {
							alert("메모를 입력하세요.");
							return;
						}
	
						// 기존 메모 저장 AJAX 코드
	
					},
					*/

					// 회원 목록 이동
					fnBack() {

						location.href = "/admin/member/list.do";

					}

				},

				mounted() {

					this.fnGetUserDetail();

				}

			});

			app.mount("#app");

		</script>

	</body>

	</html>