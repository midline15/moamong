<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>모아몽 - 주문 내역</title>
		<script src="https://code.jquery.com/jquery-3.7.1.js"
			integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
		<script src="/js/page-change.js"></script>
		<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
		<!-- 공통 레이아웃 CSS (헤더 · 사이드바 · 푸터 · 마이페이지) -->
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypage.css">
	</head>

	<body>
		<%@ include file="/WEB-INF/common/header.jsp" %>

			<div id="app" class="mp-wrap">
				<% request.setAttribute("activeMenu", "order" ); %>
					<%@ include file="/WEB-INF/common/mypageSidebar.jsp" %>

						<main class="mp-content">
							<div class="mp-head">
								<h2>주문 목록</h2>
								<span class="mp-breadcrumb">마이페이지 &gt; 주문 목록</span>
							</div>

							<!-- 상태 필터 탭 + 기간 필터 + 상품명/주문번호 검색 -->
							<div
								style="display:flex; flex-wrap:wrap; justify-content:space-between; align-items:center; gap:10px; margin-bottom:14px;">
								<div style="display:flex; gap:8px;">
									<button class="mp-btn" :class="{ 'mp-btn-gold': currentTab === 'ALL' }"
										@click="currentTab = 'ALL'">
										전체 ({{ orderList.length }})
									</button>
									<button class="mp-btn" :class="{ 'mp-btn-gold': currentTab === 'PAID' }"
										@click="currentTab = 'PAID'">
										결제완료 ({{ paidCount }})
									</button>
									<button class="mp-btn" :class="{ 'mp-btn-gold': currentTab === 'CANCELED' }"
										@click="currentTab = 'CANCELED'">
										주문취소 ({{ canceledCount }})
									</button>
								</div>

								<div style="display:flex; flex-wrap:wrap; align-items:center; gap:6px;">
									<button v-for="p in periodOptions" :key="p.value" class="mp-btn"
										:class="{ 'mp-btn-gold': periodMonths === p.value }"
										@click="periodMonths = p.value">{{ p.label }}</button>
									<input type="text" v-model.trim="searchKeyword" placeholder="상품명 또는 주문번호 검색"
										style="padding:6px 12px; border:1px solid #dfd1bd; border-radius:6px; font-size:12px; background:#fffdf9; width:190px;">
								</div>
							</div>

							<!-- 필터링된 기간·검색 기준 누적 결제 요약 바 -->
							<div class="mp-card"
								style="padding:12px 18px; margin-bottom:16px; display:flex; justify-content:space-between; align-items:center; font-size:13px;">
								<span>조회된 주문 <strong style="color:#765a36;">{{ filteredOrderList.length
										}}건</strong></span>
								<span>실결제 합계(취소 제외): <strong style="color:#765a36; font-size:15px;">{{
										filteredPaidTotal.toLocaleString() }}원</strong></span>
							</div>


							<div v-if="filteredOrderList.length === 0" class="mp-card"
								style="text-align:center; padding:54px 20px; color:#85817b;">
								<div style="font-size:15px; font-weight:700; color:#5c5346; margin-bottom:6px;">
									{{ orderList.length === 0 ? '아직 주문하신 내역이 없습니다.' : '조건에 일치하는 주문 내역이 없습니다.' }}
								</div>
								<div style="font-size:13px; margin-bottom:18px;">
						{{ orderList.length === 0 ? '소중한 분을 위한 맞춤 선물 패키지를 지금 만나보세요!' : '검색어나 기간 필터를 초기화하면 전체 주문 내역을 확인할 수 있습니다.' }}
								</div>
								<div style="display:flex; justify-content:center; gap:8px;">
									<button v-if="orderList.length > 0" class="mp-btn"
										@click="currentTab = 'ALL'; periodMonths = 0; searchKeyword = '';">필터
										초기화</button>
									<a href="/package/list.do" class="mp-btn mp-btn-gold"
										style="text-decoration:none;">선물 패키지 둘러보기</a>
								</div>
							</div>


							<!-- 주문 카드 목록 (피그마 아이보리 카드 + 우측 골드 액션 버튼) -->
							<div v-for="order in filteredOrderList" :key="order.orderId" class="mp-card">
								<div
									style="display:flex; justify-content:space-between; align-items:center; padding-bottom:10px; border-bottom:1px solid #e3d6c1; margin-bottom:12px; font-size:13px;">
									<span>
										<strong style="color:#765a36;">{{ fnStatusLabel(order.orderStatus) }}</strong>
										<span style="color:#9a8f80; margin-left:8px;">({{ order.orderedAt }} · {{
											order.orderNumber }})</span>
									</span>
									<strong>총 {{ Number(order.finalAmount).toLocaleString() }}원</strong>
								</div>

								<div style="display:flex; justify-content:space-between; align-items:center; gap:16px;">
									<div style="flex:1;">
										<div v-for="item in order.items" :key="item.orderItemId"
											style="display:flex; align-items:center; gap:12px; padding:6px 0;">
											<img :src="(item.thumbnailUrl && item.thumbnailUrl.trim()) ? item.thumbnailUrl : defaultThumb"
												@error="fnImgError"
												style="width:56px; height:56px; border-radius:6px; object-fit:cover; background:#efe7da;">
											<div style="font-size:13px;">
												<strong>{{ item.itemNameSnapshot }}</strong>
												<div style="color:#85817b; margin-top:2px;">{{
													Number(item.unitPrice).toLocaleString() }}원 × {{ item.quantity }}개
												</div>
											</div>
										</div>
									</div>

									<div style="display:flex; flex-direction:column; gap:6px; min-width:96px;">
										<button class="mp-btn mp-btn-gold"
											@click="fnGoDetail(order.orderId)">상세보기</button>
										<button
											v-if="order.orderStatus === 'PAID' || order.orderStatus === 'PAYMENT_PENDING'"
											class="mp-btn mp-btn-danger"
											@click="fnCancelOrder(order.orderId)">주문취소</button>
									</div>
								</div>
							</div>
							<!-- 주문 취소 사유 모달 -->
							<div v-if="showCancelModal" class="mp-modal-backdrop" @click.self="showCancelModal = false">
								<div class="mp-modal-box">
									<h3 style="margin:0 0 14px 0; font-size:17px; color:#765a36;">주문 취소 사유 선택</h3>
									<label v-for="r in cancelReasons" :key="r"
										style="display:flex; align-items:center; gap:8px; padding:9px 10px; border:1px solid #efe7da; border-radius:6px; margin-bottom:8px; cursor:pointer; font-size:13px; background:#fff;">
										<input type="radio" :value="r" v-model="selectedReason">
										<span>{{ r }}</span>
									</label>
									<div v-if="selectedReason === '기타 (직접 입력)'" style="margin-top:8px;">
										<textarea v-model="customReason" rows="3" maxlength="200"
											style="width:100%; padding:8px; border:1px solid #e3d6c1; border-radius:6px; font-size:13px;"
											placeholder="취소 사유를 입력해주세요"></textarea>
									</div>
									<div style="display:flex; justify-content:flex-end; gap:8px; margin-top:16px;">
										<button class="mp-btn" @click="showCancelModal = false">닫기</button>
										<button class="mp-btn mp-btn-danger" :disabled="isCanceling"
											@click="fnConfirmCancel">
											{{ isCanceling ? '처리 중...' : '취소 확정' }}
										</button>
									</div>
								</div>
							</div>
						</main>
			</div>

			<%@ include file="/WEB-INF/common/footer.jsp" %>
	</body>

	</html>
	<script>
		const app = Vue.createApp({
			data() {
				return {
					orderList: [],

					periodMonths: 0,
					periodOptions: [
						{label: "전체기간", value: 0},
						{label: "1개월", value: 1},
						{label: "3개월", value: 3},
						{label: "6개월", value: 6}
					],
					searchKeyword: "",


					currentTab: "ALL",   // <--- 추가 (쉼표 확인!)
					defaultThumb: "data:image/svg+xml;utf8,<svg xmlns='http://w3.org' width='100' height='100'><rect width='100' height='100' fill='%23f1f3f5'/></svg>",
					showCancelModal: false,
					cancelTargetOrderId: null,
					cancelReasons: ["단순 변심", "옵션 / 수량 선택 실수", "배송지 입력 오류", "다른 상품으로 재주문 예정", "기타 (직접 입력)"],
					selectedReason: "단순 변심",
					customReason: ""
				};
			},
			methods: {
				fnGoMain() {location.href = "/";},
				fnGoMypage() {location.href = "/member/mypage.do";},
				fnGoCart() {location.href = "/cart/list.do";},
				fnGoDetail(orderId) {location.href = "/order/detail.do?orderId=" + orderId;},
				fnGoCancelList() {location.href = "/order/cancel-list.do";},


				fnImgError(e) {
					e.target.onerror = null;
					e.target.src = this.defaultThumb;
				},

				fnStatusLabel(status) {
					const map = {
						PAYMENT_PENDING: "결제대기",
						PAID: "결제완료",
						PREPARING: "상품준비중",
						SHIPPING: "배송중",
						DELIVERED: "배송완료",
						CANCELED: "주문취소"
					};
					return map[status] || status;
				},
				fnStatusClass(status) {
					if (status === "CANCELED") return "status-canceled";
					if (status === "PAYMENT_PENDING") return "status-pending";
					return "status-paid";
				},
				fnList() {
					let self = this;
					$.ajax({
						url: "/order/list.dox",
						type: "POST",
						dataType: "json",
						success: function (data) {
							if (data.result === "success") {
								self.orderList = data.list || [];
							} else {
								alert(data.message || "주문 내역 조회에 실패했습니다.");
							}
						}
					});
				},
				fnCancelOrder(orderId) {
					this.cancelTargetOrderId = orderId;
					this.selectedReason = "단순 변심";
					this.customReason = "";
					this.showCancelModal = true;
				},
				fnConfirmCancel() {
					if (this.isCanceling) return;
					let self = this;
					let finalReason = this.selectedReason;
					if (finalReason === "기타 (직접 입력)") {
						if (!this.customReason.trim()) {
							alert("기타 취소 사유를 입력해주세요.");
							return;
						}
						finalReason = "기타: " + this.customReason.trim();
					}

					this.isCanceling = true;
					$.ajax({
						url: "/order/cancel.dox",
						type: "POST",
						data: {orderId: this.cancelTargetOrderId, cancelReason: finalReason},
						dataType: "json",
						success: function (data) {
							if (data.result === "success") {
								alert(data.message);
								self.showCancelModal = false;
								self.fnList();
							} else {
								alert(data.message || "주문 취소에 실패했습니다.");
							}
						},
						error: function () {
							alert("주문 취소 처리 중 서버 오류가 발생했습니다.");
						},
						complete: function () {
							self.isCanceling = false;
						}
					});
				}
			},
			mounted() {
				this.fnList();
			},

			computed: {
				paidCount() {
					return this.orderList.filter(o => o.orderStatus !== "CANCELED").length;
				},
				canceledCount() {
					return this.orderList.filter(o => o.orderStatus === "CANCELED").length;
				},
				filteredOrderList() {
					const now = new Date();
					const kw = this.searchKeyword.toLowerCase();

					return this.orderList.filter(o => {
						// 1) 상태 필터
						if (this.currentTab === "CANCELED" && o.orderStatus !== "CANCELED") return false;
						if (this.currentTab === "PAID" && o.orderStatus === "CANCELED") return false;

						// 2) 기간 필터 (1·3·6개월)
						if (this.periodMonths > 0 && o.orderedAt) {
							const orderDate = new Date(o.orderedAt.replace(" ", "T"));
							const cutoff = new Date(now);
							cutoff.setMonth(cutoff.getMonth() - this.periodMonths);
							if (orderDate < cutoff) return false;
						}

						// 3) 상품명 또는 주문번호 검색
						if (kw) {
							const matchOrderNo = (o.orderNumber || "").toLowerCase().includes(kw);
							const matchItemName = (o.items || []).some(it => (it.itemNameSnapshot || "").toLowerCase().includes(kw));
							if (!matchOrderNo && !matchItemName) return false;
						}

						return true;
					});
				},
				filteredPaidTotal() {
					return this.filteredOrderList
						.filter(o => o.orderStatus !== "CANCELED")
						.reduce((sum, o) => sum + Number(o.finalAmount || 0), 0);
				}

			},
		});

		app.mount('#app');
	</script>