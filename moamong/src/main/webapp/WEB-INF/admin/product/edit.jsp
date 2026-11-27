<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>상품(단품) 수정</title>

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
								<h2>상품(단품) 수정</h2>
								<p>등록된 상품 정보와 이미지를 수정할 수 있습니다.</p>
							</div>

							<section class="form-section">
								<h3>상품 정보</h3>

								<div class="form-group">
									<label for="productName">상품명</label>
									<input id="productName" type="text" v-model.trim="info.productName">
								</div>

								<div class="form-group">
									<label for="categoryId">카테고리 ID</label>
									<input id="categoryId" type="number" v-model="info.categoryId" min="1">
								</div>

								<div class="form-group">
									<label for="productDescription">상품 설명</label>
									<textarea id="productDescription" v-model="info.productDescription"></textarea>
								</div>

								<div class="form-group">
									<label for="price">가격</label>
									<input id="price" type="number" v-model="info.price" min="0">
								</div>

								<div class="form-group">
									<label for="stockQuantity">재고 수량</label>
									<input id="stockQuantity" type="number" v-model="info.stockQuantity" min="0">
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

								<div v-if="thumbnailUrl" class="image-item">
									<p>현재 썸네일</p>
									<img :src="thumbnailUrl" alt="현재 썸네일">
									<button type="button" @click="fnDeleteThumbnail">썸네일 삭제</button>
								</div>

								<div v-if="thumbnailImage" class="image-item">
									<p>새 썸네일: {{ thumbnailImage.name }}</p>
									<img :src="thumbnailPreviewUrl" alt="새 썸네일 미리보기">
								</div>

								<div class="image-upload">
									<input type="file" accept="image/*" @change="fnThumbnailChange">
								</div>
							</section>

							<section class="form-section">
								<h3>상세 이미지</h3>

								<div class="image-upload">
									<input type="file" multiple accept="image/*" @change="fnProductImageChange">
								</div>

								<p class="help-text">이미지를 드래그하여 순서를 변경할 수 있습니다.</p>

								<div v-for="(image, index) in productImageList" :key="image.imageId || image.previewUrl"
									class="image-item" draggable="true" @dragstart="fnDragStart(index)"
									@dragover.prevent @drop="fnDrop(index)">

									<p>{{ index + 1 }}번 이미지</p>

									<div v-if="!image.isNew">
										<img :src="image.imageUrl" alt="기존 상세 이미지">
									</div>

									<div v-else>
										<p>새 이미지: {{ image.file.name }}</p>
										<img :src="image.previewUrl" alt="새 상세 이미지 미리보기">
									</div>

									<div class="image-upload">
										<label>이미지 교체</label>
										<input type="file" accept="image/*"
											@change="fnReplaceProductImage(index, $event)">
									</div>

									<button type="button" @click="fnDeleteProductImage(index)">
										이미지 삭제
									</button>
								</div>

								<p v-if="productImageList.length === 0">
									등록된 상세 이미지가 없습니다.
								</p>
							</section>
							<div class="form-buttons">
								<div class="form-actions">
									<button type="button" class="btn-cancel" @click="fnCancel">취소</button>
									<button type="button" class="btn-submit" @click="fnProductEdit">상품 수정</button>
								</div>

								<div class="form-remove">
									<button type="button" class="btn-cancel" @click="fnRemove">상품삭제</button>
								</div>
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
							productId: "${productId}",

							info: {
								productName: "",
								categoryId: "",
								productDescription: "",
								price: "",
								stockQuantity: "",
								productStatus: ""
							},

							productImageList: [],
							thumbnailImage: null,
							thumbnailUrl: "",
							thumbnailPreviewUrl: "",
							dragIndex: null,
							deleteThumbnail: false
						};
					},

					methods: {
						// 기존 상품 정보 조회
						fnProductInfo() {
							let self = this;

							$.ajax({
								url: self.contextPath + "/product/view.dox",
								type: "POST",
								dataType: "json",
								data: {
									productId: self.productId
								},

								success(data) {
									if (!data.info) {
										alert("상품 정보를 불러오지 못했습니다.");
										return;
									}

									self.info = data.info;

									let imageList = data.info.productImageList || [];

									// 기존 썸네일 조회
									let thumbnail = imageList.find(image => {
										return image.imageType === "THUMBNAIL";
									});

									self.thumbnailUrl = thumbnail ? thumbnail.imageUrl : "";

									// 기존 상세 이미지 조회
									self.productImageList = imageList
										.filter(image => image.imageType === "DETAIL")
										.map(image => {
											return {
												imageId: image.imageId,
												imageUrl: image.imageUrl,
												imageType: image.imageType,
												displayOrder: image.displayOrder,
												isNew: false,
												file: null,
												previewUrl: null
											};
										});
								},

								error(xhr) {
									console.log(xhr.responseText);
									alert("상품 정보 조회 중 오류가 발생했습니다.");
								}
							});
						},

						// 썸네일 변경
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
							this.deleteThumbnail = false;
							event.target.value = "";
						},

						// 썸네일 삭제
						fnDeleteThumbnail() {
							this.thumbnailUrl = "";

							if (this.thumbnailPreviewUrl) {
								URL.revokeObjectURL(this.thumbnailPreviewUrl);
							}

							this.thumbnailImage = null;
							this.thumbnailPreviewUrl = "";
							this.deleteThumbnail = true;
						},

						// 새 상세 이미지 추가
						fnProductImageChange(event) {
							let files = Array.from(event.target.files);

							files.forEach(file => {
								this.productImageList.push({
									imageId: null,
									imageUrl: null,
									imageType: "DETAIL",
									displayOrder: 0,
									isNew: true,
									file: file,
									previewUrl: URL.createObjectURL(file)
								});
							});

							event.target.value = "";
						},

						// 상세 이미지 교체
						fnReplaceProductImage(index, event) {
							let file = event.target.files[0];

							if (!file) {
								return;
							}

							let oldImage = this.productImageList[index];

							if (oldImage.previewUrl) {
								URL.revokeObjectURL(oldImage.previewUrl);
							}

							this.productImageList.splice(index, 1, {
								imageId: null,
								imageUrl: null,
								imageType: "DETAIL",
								displayOrder: 0,
								isNew: true,
								file: file,
								previewUrl: URL.createObjectURL(file)
							});

							event.target.value = "";
						},

						// 상세 이미지 삭제
						fnDeleteProductImage(index) {
							let image = this.productImageList[index];

							if (image.previewUrl) {
								URL.revokeObjectURL(image.previewUrl);
							}

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

						// 상품 수정
						fnProductEdit() {
							let self = this;

							if (!self.info.productName || !self.info.productName.trim()) {
								alert("상품명을 입력해 주세요.");
								return;
							}

							if (!self.info.categoryId || Number(self.info.categoryId) <= 0) {
								alert("카테고리 ID를 확인해 주세요.");
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

							let formData = new FormData();

							formData.append("productId", self.productId);
							formData.append("productName", self.info.productName);
							formData.append("categoryId", self.info.categoryId);
							formData.append("productDescription", self.info.productDescription || "");
							formData.append("price", self.info.price);
							formData.append("stockQuantity", self.info.stockQuantity);
							formData.append("productStatus", self.info.productStatus);
							formData.append("deleteThumbnail", self.deleteThumbnail);

							// 최종 상세 이미지 목록
							let imageList = self.productImageList.map((image, index) => {
								return {
									imageId: image.isNew ? null : image.imageId,
									isNew: image.isNew,
									displayOrder: index + 1
								};
							});

							formData.append("imageList", JSON.stringify(imageList));

							// 새 상세 이미지 파일과 미리보기 URL
							let previewUrlList = [];

							self.productImageList.forEach(image => {
								if (image.isNew) {
									formData.append("productImageList", image.file);
									previewUrlList.push(image.previewUrl);
								}
							});

							formData.append("previewUrlList", JSON.stringify(previewUrlList));

							// 새 썸네일 이미지
							if (self.thumbnailImage) {
								formData.append("thumbnailImage", self.thumbnailImage);
							}

							$.ajax({
								url: self.contextPath + "/product/edit.dox",
								type: "POST",
								dataType: "json",
								data: formData,
								processData: false,
								contentType: false,

								success(data) {
									if (Number(data.result) > 0) {
										alert("상품이 수정되었습니다.");
										location.href = "/admin/product/list.do"
									} else {
										alert("상품 수정에 실패했습니다.");
									}
								},

								error(xhr) {
									console.log(xhr.responseText);
									alert("상품 수정 중 오류가 발생했습니다.");
								}
							});
						},

						// 이전 화면으로 이동
						fnCancel() {
							history.back();
						},

						// 해당 상품 삭제 
						fnRemove() {
							let self = this;

							if (!confirm("정말 삭제하시겠습니까?")) {
								return;
							}

							$.ajax({
								url: "/admin/product/remove.dox",
								type: "POST",
								dataType: "json",
								data: {
									productId: self.productId
								},

								success(data) {
									if (data.result == 'success') {
										alert("상품이 삭제되었습니다.");
										location.href = "/admin/product/list.do"
									} else {
										alert("상품 삭제에 실패했습니다.");
									}
								},
								error(xhr) {
									console.log(xhr.responseText);
									alert("상품 삭제 중 오류가 발생했습니다.");
								}
							});
						}
					},

					mounted() {
						// 최초 진입 시 상품 정보 조회
						this.fnProductInfo();
					},

					beforeUnmount() {
						if (this.thumbnailPreviewUrl) {
							URL.revokeObjectURL(this.thumbnailPreviewUrl);
						}

						this.productImageList.forEach(image => {
							if (image.previewUrl) {
								URL.revokeObjectURL(image.previewUrl);
							}
						});
					}
				});

				app.mount("#app");
			</script>

	</body>

	</html>