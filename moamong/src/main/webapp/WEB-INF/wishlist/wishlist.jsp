<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>모아몽 - 찜 목록</title>
		<script src="https://code.jquery.com/jquery-3.7.1.js"
		integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
		<script src="/js/page-change.js"></script>
		<!-- 공통 레이아웃 & 장바구니 & 찜목록 & 주문서 전용 CSS -->
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/order/shop.css">
	</head>

	<body>
		<%@ include file="/WEB-INF/common/header.jsp" %>

		<main id="app" class="shop-wrap" style="max-width: 960px;">
			<div class="shop-head">
				<h2>찜 목록</h2>
				<div class="shop-steps">마이페이지 &gt; <strong>찜 목록</strong></div>
			</div>

			<div class="shop-toolbar">
				<label style="cursor:pointer; display:flex; align-items:center; gap:8px; font-weight:600;">
					<input type="checkbox" v-model="isAllChecked" @change="fnToggleAll">
					전체 선택 ({{ selectedIds.length }} / {{ wishList.length }})
				</label>
				<div style="display:flex; gap:6px;">
					<button class="shop-btn shop-btn-gold" @click="fnMoveSelectedToCart">선택 상품 담기</button>
					<button class="shop-btn" @click="fnRemoveSelected">선택 삭제</button>
					<button class="shop-btn shop-btn-danger" @click="fnDeleteAll">전체 비우기</button>
				</div>
			</div>
			<!-- 선물 예산 플래너 & 무료배송 달성 게이지 (기존 shop.css 클래스 100% 재사용) -->
			<div class="free-ship-box">
				<div class="wish-planner-top">
					<div style="display:flex; align-items:center; gap:6px;">
						<strong>목표 선물 예산</strong>
						<input type="number" class="wish-budget-input" v-model.number="targetBudget" @input="fnSaveBudget" step="5000" min="0">
						<span>원</span>
					</div>
					<div style="display:flex; flex-wrap:wrap; align-items:center; gap:12px;">
						<span>선택 합계: <strong>{{ selectedTotalPrice.toLocaleString() }}원</strong></span>
						<span v-if="targetBudget > 0">
							예산 잔액:
							<strong :class="budgetRemain >= 0 ? 'wish-budget-ok' : 'wish-budget-over'">
								{{ budgetRemain >= 0 ? budgetRemain.toLocaleString() + '원 남음' : Math.abs(budgetRemain).toLocaleString() + '원 초과' }}
							</strong>
						</span>
					</div>
				</div>
				<div class="free-ship-text">
					<span>무료배송 기준 (30,000원)</span>
					<strong v-if="selectedTotalPrice >= 30000">무료배송 달성!</strong>
					<span v-else><strong>{{ (30000 - selectedTotalPrice).toLocaleString() }}원</strong> 더 담으면 무료배송</span>
				</div>
				<div class="free-ship-bar">
					<div class="free-ship-fill" :style="{ width: freeShipPercent + '%' }"></div>
				</div>
			</div>

			<div v-if="wishList.length === 0" class="shop-card" style="text-align:center; padding:60px 20px; color:#85817b;">
				<div style="font-size:15px; font-weight:700; color:#5c5346; margin-bottom:6px;">아직 찜한 선물이 없습니다.</div>
				<div style="font-size:13px; margin-bottom:18px;">마음에 드는 선물들을 둘러보고 찜 목록에 담아보세요!</div>
				<div style="display:flex; justify-content:center; gap:8px;">
					<a href="/package/list.do" class="shop-btn shop-btn-gold" style="text-decoration:none;">선물 패키지 둘러보기</a>
					<a href="/product/list.do" class="shop-btn" style="text-decoration:none;">단품 상품 보기</a>
				</div>
			</div>


			<div v-for="item in wishList" :key="item.wishlistId" class="shop-card"
			:class="{ soldout: !item.available }"
			style="display:flex; align-items:center; justify-content:space-between; gap:16px;">
			<div style="display:flex; align-items:center; gap:16px; flex:1; min-width:0;">
				<input type="checkbox" :value="item.wishlistId" v-model="selectedIds">
				<img class="shop-thumb" :src="item.thumbnailUrl || defaultThumb" @error="fnImgError"
				alt="상품 이미지">
				<div style="flex:1; min-width:0;">
					<div>
						<span class="shop-badge">{{ item.itemType === 'PRODUCT' ? '단품' : ('패키지' +
							(item.packageGrade ? ' · ' + item.packageGrade : '')) }}</span>
							<span v-if="!item.available" class="shop-badge soldout">품절/구매불가</span>
						</div>
						<div @click="fnGoDetail(item)" style="font-size:15px; font-weight:700; margin-top:5px; cursor:pointer; text-decoration:underline; text-underline-offset:3px;">
							{{ item.itemName || '판매 종료된 상품입니다' }}</div>
							<div style="font-size:12px; color:#9a8f80; margin-top:4px;">찜한 날짜: {{ item.createdAt }}
							</div>
						</div>
					</div>

					<div style="text-align:right; min-width:110px;">
						<strong style="font-size:16px; color:#29251f;">{{ Number(item.price || 0).toLocaleString()
							}}원</strong>
						</div>

						<div style="display:flex; flex-direction:column; gap:6px; min-width:92px;">
							<button class="shop-btn shop-btn-gold" @click="fnMoveToCart(item)"
							:disabled="!item.available">장바구니</button>
							<button class="shop-btn shop-btn-danger" @click="fnRemove(item.wishlistId)">삭제</button>
						</div>
					</div>
				</main>

				<%@ include file="/WEB-INF/common/footer.jsp" %>
			</body>

		</html>
		<script>
			const app = Vue.createApp({
				data() {
					return {
						targetBudget: 50000,
						wishList: [],
						selectedIds: [],
						defaultThumb: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIj48cmVjdCB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iI2YxZjNmNSIvPjx0ZXh0IHg9IjUwJSIgeT0iNTQlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjODY4ZTk2IiBmb250LWZhbWlseT0ic2Fucy1zZXJpZiIgZm9udC1zaXplPSIxMiI+TU9BTU9ORzwvdGV4dD48L3N2Zz4="
					};
				},
				computed: {
					isAllChecked: {
						get() {
							return this.wishList.length > 0 && this.selectedIds.length === this.wishList.length;
						},
						set(val) { }
					},
					
					selectedTotalPrice() {
						return this.wishList
						.filter(item => this.selectedIds.includes(item.wishlistId))
						.reduce((sum, item) => sum + Number(item.price || 0), 0);
					},
					budgetRemain() {
						return Number(this.targetBudget || 0) - this.selectedTotalPrice;
					},
					freeShipPercent() {
						return Math.min(100, Math.round((this.selectedTotalPrice / 30000) * 100));
					},
					
				},
				methods: {
					fnGoCart() {location.href = "/cart/list.do";},
					fnGoMypage() {location.href = "/member/mypage.do";},
					fnGoMain() {location.href = "/";},
					fnImgError(e) {e.target.src = this.defaultThumb;},
					fnList() {
						let self = this;
						$.ajax({
							url: "/wishlist/list.dox",
							type: "POST",
							dataType: "json",
							success: function (data) {
								if (data.result === "success") {
									self.wishList = data.list;
									self.selectedIds = [];
								} else {
									alert(data.message || "찜 목록 조회에 실패했습니다.");
								}
							}
						});
					},
					fnToggleAll(e) {
						if (e.target.checked) {
							this.selectedIds = this.wishList.map(item => item.wishlistId);
						} else {
							this.selectedIds = [];
						}
					},
					fnMoveToCart(item) {
						if (item.itemType === "PACKAGE") {
							alert("패키지 상품은 구성품 및 옵션 선택 후 장바구니에 담을 수 있습니다.");
							location.href = "/package/detail.do?packageId=" + item.packageId;
							return;
						}
						$.ajax({
							url: "/cart/add.dox",
							type: "POST",
							dataType: "json",
							data: {productId: item.productId, quantity: 1},
							success: function (data) {
								if (data.result === "success") {
									if (confirm("장바구니에 담겼습니다. 장바구니로 이동하시겠습니까?")) {
										location.href = "/cart/list.do";
									}
								} else {
									alert(data.message || "장바구니 담기에 실패했습니다.");
								}
							}
						});
					},
					
					async fnMoveSelectedToCart() {
						if (this.selectedIds.length === 0) {
							alert("장바구니에 담을 상품을 선택해주세요.");
							return;
						}
						const selectedItems = this.wishList.filter(item => this.selectedIds.includes(item.wishlistId));
						const validItems = selectedItems.filter(item => item.available);
						const skippedCount = selectedItems.length - validItems.length;
						
						if (validItems.length === 0) {
							alert("선택하신 상품이 모두 품절/구매불가 상태입니다.");
							return;
						}
						
						let successCount = 0;
						for (const item of validItems) {
							const payload = item.itemType === "PACKAGE"
							? { packageId: item.packageId, quantity: 1 }
							: { productId: item.productId, quantity: 1 };
							
							await $.ajax({
								url: "/cart/add-json.dox",
								type: "POST",
								contentType: "application/json",
								data: JSON.stringify(payload),
								dataType: "json",
								success: function (data) {
									if (data.result === "success") successCount++;
								}
							});
						}
						
						let msg = successCount + "개 상품이 장바구니에 담겼습니다.";
						if (skippedCount > 0) {
							msg += "\n(품절/구매불가 상품 " + skippedCount + "개 제외)";
						}
						if (confirm(msg + "\n장바구니로 이동하시겠습니까?")) {
							location.href = "/cart/list.do";
						}
					},
					
					fnRemove(wishlistId) {
						let self = this;
						if (!confirm("찜 목록에서 삭제하시겠습니까?")) return;
						$.ajax({
							url: "/wishlist/remove.dox",
							type: "POST",
							dataType: "json",
							data: {wishlistId: wishlistId},
							success: function (data) {
								if (data.result === "success") {
									self.fnList();
								} else {
									alert("삭제에 실패했습니다.");
								}
							}
						});
					},
					fnRemoveSelected() {
						let self = this;
						if (this.selectedIds.length === 0) {
							alert("삭제할 상품을 선택해주세요.");
							return;
						}
						if (!confirm("선택한 " + this.selectedIds.length + "개 항목을 삭제하시겠습니까?")) return;
						$.ajax({
							url: "/wishlist/removeSelected.dox",
							type: "POST",
							dataType: "json",
							data: {wishlistIds: this.selectedIds.join(",")},
							success: function (data) {
								if (data.result === "success") {
									self.fnList();
								} else {
									alert("선택 삭제에 실패했습니다.");
								}
							}
						});
					},
					fnDeleteAll() {
						let self = this;
						if (!confirm("찜 목록을 모두 비우시겠습니까?")) return;
						$.ajax({
							url: "/wishlist/deleteAll.dox",
							type: "POST",
							dataType: "json",
							success: function (data) {
								if (data.result === "success") {
									self.fnList();
								} else {
									alert("전체 비우기에 실패했습니다.");
								}
							}
						});
					},
					fnTestToggle(productId) {
						let self = this;
						$.ajax({
							url: "/wishlist/toggle.dox",
							type: "POST",
							dataType: "json",
							data: {productId: productId},
							success: function (data) {
								if (data.result === "success") {
									self.fnList();
								} else {
									alert(data.message || "찜 토글 실패");
								}
							}
						});
					},
					
					fnSaveBudget() {
						localStorage.setItem("moamong_wish_budget", String(this.targetBudget || 0));
					}
				},
				mounted() {
					const savedBudget = localStorage.getItem("moamong_wish_budget");
					if (savedBudget !== null) this.targetBudget = Number(savedBudget);
					this.fnList();
				}
				
			});
			
			app.mount('#app');
		</script>