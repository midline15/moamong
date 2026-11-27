<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>상품(단품) 등록</title>
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/adminLayout.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/product/add.css">
	</head>

	<body>
		<%@ include file="/WEB-INF/common/adminHeader.jsp" %>

			<div class="adm-shell">
				<%@ include file="/WEB-INF/common/adminSidebar.jsp" %>

					<main class="adm-main">
						<div id="app" class="admin-product">

							<div class="page-header">
								<h2>상품(단품) 등록</h2>
								<p>새로운 상품 정보를 입력하고 등록해 주세요.</p>
							</div>

							<section class="form-section">
								<h3>상품 정보</h3>

								<div class="form-group">
									<label for="productName">상품명</label>
									<input id="productName" type="text" v-model.trim="info.productName"
										placeholder="상품명을 입력해 주세요.">
								</div>

								<div class="form-group">
									<label for="categoryId">카테고리 ID</label>
									<input id="categoryId" type="number" v-model="info.categoryId"
										placeholder="카테고리 ID를 입력해 주세요." min="1">
								</div>

								<div class="form-group">
									<label for="productDescription">상품 설명</label>
									<textarea id="productDescription" v-model="info.productDescription"
										placeholder="상품 설명을 입력해 주세요."></textarea>
								</div>

								<div class="form-group">
									<label for="price">가격</label>
									<input id="price" type="number" v-model="info.price" placeholder="상품 가격을 입력해 주세요."
										min="0">
								</div>

								<div class="form-group">
									<label for="stockQuantity">재고 수량</label>
									<input id="stockQuantity" type="number" v-model="info.stockQuantity"
										placeholder="재고 수량을 입력해 주세요." min="0">
								</div>

								<div class="form-group">
									<label for="productStatus">판매 상태</label>
									<select id="productStatus" v-model="info.productStatus">
										<option value="SELLING">판매중</option>
										<option value="SOLD_OUT">품절</option>
										<option value="STOP">판매중지</option>
									</select>
								</div>
							</section>

							<section class="form-section">
								<h3>썸네일 이미지</h3>

								<div class="image-upload">
									<input type="file" accept="image/*" @change="fnThumbnailChange">

									<div v-if="thumbnailImage" class="image-item">
										<p>{{ thumbnailImage.name }}</p>
										<img :src="thumbnailPreviewUrl" alt="썸네일 미리보기">
										<button type="button" @click="fnDeleteThumbnail">삭제</button>
									</div>
								</div>
							</section>

							<section class="form-section">
								<h3>상세 이미지</h3>

								<div class="image-upload">
									<input type="file" multiple accept="image/*" @change="fnProductImageChange">
								</div>

								<p class="help-text">이미지를 드래그하여 순서를 변경할 수 있습니다.</p>

								<div v-for="(image, index) in productImageList" :key="image.previewUrl"
									class="image-item" draggable="true" @dragstart="fnDragStart(index)"
									@dragover.prevent @drop="fnDrop(index)">

									<p>{{ index + 1 }}번 이미지 - {{ image.file.name }}</p>
									<img :src="image.previewUrl" alt="상세 이미지 미리보기">
									<button type="button" @click="fnDeleteProductImage(index)">삭제</button>
								</div>

								<p v-if="productImageList.length === 0">
									등록된 상세 이미지가 없습니다.
								</p>
							</section>

							<div class="form-actions">
								<button type="button" class="btn-cancel" @click="fnCancel">취소</button>
								<button type="button" class="btn-submit" @click="fnProductAdd">상품 등록</button>
							</div>

						</div>
					</main>
			</div>

			<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
			<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
			<script src="${pageContext.request.contextPath}/js/page-change.js"></script>

			<script>
				const app = Vue.createApp({
					data() {
						return {
							contextPath: "${pageContext.request.contextPath}",
							info: {
								productName: "",
								categoryId: "",
								productDescription: "",
								price: "",
								stockQuantity: "",
								productStatus: "SELLING"
							},
							thumbnailImage: null,
							thumbnailPreviewUrl: "",
							productImageList: [],
							dragIndex: null
						};
					},

					methods: {
						// 썸네일 선택
						fnThumbnailChange(event) {
							let file = event.target.files[0];

							if (!file) {
								return;
							}

							if (this.thumbnailPreviewUrl) {
								URL.revokeObjectURL(this.thumbnailPreviewUrl);
							}

							this.thumbnailImage = file;
							this.thumbnailPreviewUrl = URL.createObjectURL(file);
							event.target.value = "";
						},

						// 썸네일 삭제
						fnDeleteThumbnail() {
							if (this.thumbnailPreviewUrl) {
								URL.revokeObjectURL(this.thumbnailPreviewUrl);
							}

							this.thumbnailImage = null;
							this.thumbnailPreviewUrl = "";
						},

						// 상세 이미지 추가
						fnProductImageChange(event) {
							let files = Array.from(event.target.files);

							files.forEach(file => {
								this.productImageList.push({
									file: file,
									previewUrl: URL.createObjectURL(file)
								});
							});

							event.target.value = "";
						},

						// 상세 이미지 삭제
						fnDeleteProductImage(index) {
							let image = this.productImageList[index];
							URL.revokeObjectURL(image.previewUrl);
							this.productImageList.splice(index, 1);
						},

						// 드래그 시작
						fnDragStart(index) {
							this.dragIndex = index;
						},

						// 이미지 순서 변경
						fnDrop(index) {
							if (this.dragIndex === null || this.dragIndex === index) {
								this.dragIndex = null;
								return;
							}

							let image = this.productImageList.splice(this.dragIndex, 1)[0];
							this.productImageList.splice(index, 0, image);
							this.dragIndex = null;
						},

						// 상품 등록
						fnProductAdd() {
							let self = this;

							if (!self.info.productName.trim()) {
								alert("상품명을 입력해 주세요.");
								return;
							}

							if (!self.info.categoryId || Number(self.info.categoryId) <= 0) {
								alert("카테고리 ID를 입력해 주세요.");
								return;
							}

							if (self.info.price === "" || Number(self.info.price) < 0) {
								alert("상품 가격을 확인해 주세요.");
								return;
							}

							if (self.info.stockQuantity === "" || Number(self.info.stockQuantity) < 0) {
								alert("재고 수량을 확인해 주세요.");
								return;
							}

							if (!self.info.productStatus) {
								alert("판매 상태를 선택해 주세요.");
								return;
							}

							let formData = new FormData();

							formData.append("productName", self.info.productName);
							formData.append("categoryId", self.info.categoryId);
							formData.append("productDescription", self.info.productDescription);
							formData.append("price", self.info.price);
							formData.append("stockQuantity", self.info.stockQuantity);
							formData.append("productStatus", self.info.productStatus);

							if (self.thumbnailImage) {
								formData.append("thumbnailImage", self.thumbnailImage);
							}

							let previewUrlList = [];

							self.productImageList.forEach(image => {
								formData.append("productImageList", image.file);
								previewUrlList.push(image.previewUrl);
							});

							formData.append("previewUrlList", JSON.stringify(previewUrlList));

							$.ajax({
								url: self.contextPath + "/product/add.dox",
								type: "POST",
								dataType: "json",
								data: formData,
								processData: false,
								contentType: false,

								success(data) {
									if (Number(data.result) > 0) {
										alert("상품이 등록되었습니다.");
										location.href = self.contextPath + "/admin/product/list.do";
									} else {
										alert("상품 등록에 실패했습니다.");
									}
								},

								error(xhr) {
									console.log(xhr.responseText);
									alert("상품 등록 중 오류가 발생했습니다.");
								}
							});
						},

						// 이전 화면으로 이동
						fnCancel() {
							history.back();
						}
					},

					beforeUnmount() {
						if (this.thumbnailPreviewUrl) {
							URL.revokeObjectURL(this.thumbnailPreviewUrl);
						}

						this.productImageList.forEach(image => {
							URL.revokeObjectURL(image.previewUrl);
						});
					}
				});

				app.mount("#app");
			</script>

	</body>

	</html>