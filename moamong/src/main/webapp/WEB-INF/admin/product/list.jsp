<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>상품(단품) 관리</title>

		<!-- 공통 레이아웃 CSS -->
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/adminLayout.css">

		<!-- 상품 목록 CSS -->
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/product/list.css">

		<!-- jQuery -->
		<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

		<!-- Vue 3 -->
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
	</head>

	<body>

		<%@ include file="/WEB-INF/common/adminHeader.jsp" %>

			<div class="adm-shell">
				<%@ include file="/WEB-INF/common/adminSidebar.jsp" %>

					<main class="adm-main">
						<div id="app" class="admin-product">

							<h2>상품(단품) 관리</h2>

							<!-- 검색 조건 -->
							<div class="search-area">
								<select v-model="search.productStatus">
									<option value="">전체 상태</option>
									<option value="SELLING">판매중</option>
									<option value="SOLD_OUT">품절</option>
									<option value="STOP">판매중지</option>
								</select>

								<select v-model="search.searchType">
									<option value="all">전체 검색</option>
									<option value="productName">상품명</option>
									<option value="productId">상품 ID</option>
								</select>

								<input type="text" v-model="search.keyword" placeholder="검색어를 입력해 주세요."
									@keyup.enter="fnSearch">

								<button type="button" class="btn btn-search" @click="fnSearch">
									검색
								</button>

								<button type="button" class="btn btn-reset" @click="fnReset">
									초기화
								</button>
							</div>

							<!-- 목록 상단 -->
							<div class="list-header">
								<div class="list-count">
									전체 상품
									<strong>{{ totalCount.toLocaleString() }}</strong>개
								</div>

								<button type="button" class="btn btn-add" @click="fnMoveAdd">
									+ 상품 등록
								</button>
							</div>

							<!-- 상품 목록 -->
							<table class="product-table">
								<thead>
									<tr>
										<th style="width: 70px;">상품 ID</th>
										<th style="width: 90px;">이미지</th>
										<th>상품명</th>
										<th style="width: 100px;">카테고리 ID</th>
										<th style="width: 120px;">판매 가격</th>
										<th style="width: 90px;">재고</th>
										<th style="width: 100px;">판매 상태</th>
										<th style="width: 130px;">등록일</th>
										<th style="width: 90px;">관리</th>
									</tr>
								</thead>

								<tbody>
									<tr v-for="product in productList" :key="product.productId">
										<td>{{ product.productId }}</td>

										<td>
											<img v-if="product.thumbnailUrl" :src="product.thumbnailUrl"
												class="thumbnail">

											<span v-else class="no-image">
												이미지 없음
											</span>
										</td>

										<td class="product-name">
											{{ product.productName }}
										</td>

										<td>{{ product.categoryId }}</td>

										<td>
											{{ Number(product.price || 0).toLocaleString() }}원
										</td>

										<td>
											{{ Number(product.stockQuantity || 0).toLocaleString() }}
										</td>

										<td>
											<span class="status" :class="fnStatusClass(product.productStatus)">
												{{ fnStatusText(product.productStatus) }}
											</span>
										</td>

										<td>{{ product.createdAt }}</td>

										<td>
											<button type="button" class="btn-edit"
												@click="fnMoveEdit(product.productId)">
												수정
											</button>
										</td>
									</tr>

									<tr v-if="productList.length === 0">
										<td colspan="9" class="empty-list">
											조회된 상품이 없습니다.
										</td>
									</tr>
								</tbody>
							</table>

							<!-- 페이지네이션 -->
							<div class="pagination">
								<button type="button" @click="fnMovePage(1)" :disabled="page === 1">
									처음
								</button>

								<button type="button" @click="fnMovePage(page - 1)" :disabled="page === 1">
									이전
								</button>

								<button type="button" v-for="num in pageList" :key="num"
									:class="{ active: page === num }" @click="fnMovePage(num)">
									{{ num }}
								</button>

								<button type="button" @click="fnMovePage(page + 1)" :disabled="page >= totalPage">
									다음
								</button>

								<button type="button" @click="fnMovePage(totalPage)" :disabled="page >= totalPage">
									마지막
								</button>
							</div>

						</div>
					</main>
			</div>

			<script>
				const app = Vue.createApp({
					data() {
						return {
							// 상품 목록
							productList: [],

							// 검색 조건
							search: {
								productStatus: "",
								searchType: "all",
								keyword: ""
							},

							// 현재 페이지
							page: 1,

							// 페이지당 상품 수
							pageSize: 10,

							// 전체 상품 개수
							totalCount: 0
						};
					},

					computed: {
						// 전체 페이지 수
						totalPage() {
							return Math.max(1, Math.ceil(this.totalCount / this.pageSize));
						},

						// 페이지 번호 목록
						pageList() {
							let start = Math.floor((this.page - 1) / 5) * 5 + 1;
							let end = Math.min(start + 4, this.totalPage);
							let list = [];

							for (let i = start; i <= end; i++) {
								list.push(i);
							}

							return list;
						}
					},

					methods: {
						// 숫자 천 단위 콤마
						fnNumber(value) {
							return Number(value || 0).toLocaleString();
						},

						// 판매 상태 한글 표시
						fnStatusText(status) {
							if (status === "SELLING") {
								return "판매중";
							}

							if (status === "SOLD_OUT") {
								return "품절";
							}

							if (status === "STOP") {
								return "판매중지";
							}

							return "-";
						},

						// 판매 상태 CSS 클래스
						fnStatusClass(status) {
							if (status === "SELLING") {
								return "status-selling";
							}

							if (status === "SOLD_OUT") {
								return "status-soldout";
							}

							if (status === "STOP") {
								return "status-stop";
							}

							return "";
						},

						// 검색 실행
						fnSearch() {
							this.page = 1;
							this.fnGetProductList();
						},

						// 검색 초기화
						fnReset() {
							this.search.productStatus = "";
							this.search.searchType = "all";
							this.search.keyword = "";
							this.page = 1;
							this.fnGetProductList();
						},

						// 상품 등록 페이지 이동
						fnMoveAdd() {
							location.href = "${pageContext.request.contextPath}/admin/product/add.do";
						},

						// 상품 수정 페이지 이동
						fnMoveEdit(productId) {
							location.href = "${pageContext.request.contextPath}/admin/product/edit.do?productId=" + productId;
						},

						// 페이지 이동
						fnMovePage(page) {
							if (page < 1 || page > this.totalPage) {
								return;
							}

							this.page = page;
							this.fnGetProductList();
						},

						// 상품 목록 조회
						fnGetProductList() {
							let self = this;

							$.ajax({
								url: "${pageContext.request.contextPath}/admin/product/list.dox",
								type: "POST",
								dataType: "json",
								data: {
									productStatus: self.search.productStatus,
									searchType: self.search.searchType,
									keyword: self.search.keyword.trim(),
									page: self.page,
									pageSize: self.pageSize
								},

								success: function (data) {
									// 상품 목록
									self.productList = Array.isArray(data.productList)
										? data.productList
										: [];

									// 전체 상품 개수
									self.totalCount = Number(data.totalCount || 0);

									// 현재 페이지 보정
									if (self.totalCount > 0 && self.page > self.totalPage) {
										self.page = self.totalPage;
										self.fnGetProductList();
									}
								},

								error: function (xhr, status, error) {
									console.log(xhr.responseText);
									console.log(error);

									self.productList = [];
									self.totalCount = 0;

									alert("상품 목록을 불러오는 중 오류가 발생했습니다.");
								}
							});
						}
					},

					mounted() {
						// 최초 진입 시 상품 목록 조회
						this.fnGetProductList();
					}
				});

				app.mount("#app");
			</script>

	</body>

	</html>