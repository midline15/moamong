<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>나의 리뷰</title>

		<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
		<link rel="stylesheet" href="/css/review/list.css">
	</head>

	<body>
		<div id="app">

			<h2 class="page-title">나의 리뷰</h2>
			<p class="page-desc">내가 작성한 상품 리뷰를 확인하고 관리할 수 있습니다.</p>

			<div class="review-count">
				작성한 리뷰 <strong>{{ list.length }}</strong>개
			</div>

			<div v-for="review in list" :key="review.reviewId" class="review-card">

				<!-- 일반 리뷰 -->
				<div v-if="editReviewId !== review.reviewId">

					<div class="review-header">
						<div class="product-name">{{ review.productName }}</div>
						<!--해당 부분에 추후 상품 이미지 추가예정-->
					</div>

					<div class="review-date">
						작성일 : {{ review.createdAt }}
					</div>

					<div class="star">
						{{ '★'.repeat(review.rating) }}{{ '☆'.repeat(5-review.rating) }}
					</div>

					<div class="review-content">
						{{ review.reviewContent }}
					</div>

					<div class="image-list">
						<img v-for="img in review.imageList" :key="img.imageId" :src="img.imageUrl" class="image-item"
							alt="리뷰 이미지">
					</div>

					<div class="button-area">
						<button class="btn-edit" @click="fnEditMode(review)">
							수정
						</button>

						<button class="btn-delete" @click="fnRemove(review.reviewId)">
							삭제
						</button>
					</div>
				</div>

				<!-- 리뷰 수정 -->
				<div v-else>

					<div class="review-header">
						<div class="product-name">{{ review.productName }}</div>
						<div style="color:#16a34a; font-size:12px;">수정 중</div>
					</div>

					<label class="edit-label">별점</label>

					<div>
						<button v-for="num in 5" :key="num" type="button" class="star-button"
							:class="{active: editRating >= num}" @click="editRating = num">
							★
						</button>
					</div>

					<label class="edit-label">리뷰 내용</label>

					<textarea v-model="editContent" placeholder="리뷰 내용을 입력해주세요.">
            </textarea>

					<!-- 기존 이미지 -->
					<label class="edit-label">
						기존 등록 이미지 ({{ editImageList.length }}/3)
					</label>

					<div class="image-list">

						<div v-for="img in editImageList" :key="img.imageId" class="image-delete">

							<img :src="img.imageUrl" class="image-item" alt="기존 리뷰 이미지">

							<button type="button" class="image-remove-btn" @click="fnRemoveImage(img.imageId)">
								×
							</button>
						</div>

					</div>

					<!-- 새 이미지 -->
					<label class="edit-label">
						새로운 이미지 추가
						({{ editImageList.length + newFiles.length }}/3)
					</label>

					<input type="file" accept=".jpg,.jpeg,.png,image/jpeg,image/png" multiple @change="fnFileChange"
						ref="fileInput" :disabled="editImageList.length + newFiles.length >= 3">

					<p style="font-size:12px; color:#777;">
						JPG, JPEG, PNG 파일만 가능하며 이미지당 최대 5MB,
						총 3장까지 등록할 수 있습니다.
					</p>

					<!-- 새 이미지 미리보기 -->
					<div class="image-list">

						<div v-for="(url, idx) in newImagePreview" :key="idx" class="image-delete">

							<img :src="url" class="image-item" alt="새 이미지 미리보기">

							<button type="button" class="image-remove-btn" @click="fnRemoveNewImage(idx)">
								×
							</button>
						</div>

					</div>

					<div class="button-area">

						<button class="btn-cancel" @click="fnCancel">
							취소
						</button>

						<button class="btn-save" @click="fnUpdate(review.reviewId)">
							수정 완료
						</button>

					</div>
				</div>
			</div>

			<div v-if="list.length === 0" class="empty-message">
				아직 작성한 리뷰가 없습니다.
			</div>

		</div>

		<script>
			const app = Vue.createApp({

				data() {
					return {
						list: [],
						editReviewId: null,
						editRating: 0,
						editContent: "",
						editImageList: [],
						deleteImageList: [],
						newFiles: [],
						newImagePreview: [],
						memberId: "${memberId}"
					};
				},

				methods: {

					fnList() {
						let self = this;

						$.ajax({
							url: "/review/my-list.dox",
							type: "POST",
							dataType: "json",
							data: {
								memberId: self.memberId
							},
							success(data) {
								if (data.result == "success") {
									self.list = data.list;
								} else {
									alert("리뷰 목록 조회에 실패했습니다.");
								}
							},
							error() {
								alert("서버 통신 오류가 발생했습니다.");
							}
						});
					},

					fnEditMode(review) {
						this.editReviewId = review.reviewId;
						this.editRating = review.rating;
						this.editContent = review.reviewContent;

						this.editImageList = review.imageList.map(img =>
							Object.assign({}, img)
						);

						this.deleteImageList = [];
						this.newFiles = [];
						this.clearPreview();
					},

					// 기존 이미지 삭제
					fnRemoveImage(imageId) {

						this.deleteImageList.push(imageId);

						this.editImageList = this.editImageList.filter(img =>
							img.imageId !== imageId
						);
					},

					// 새 이미지 선택
					fnFileChange(event) {

						const selectedFiles = Array.from(event.target.files);
						const allowedTypes = ["image/jpeg", "image/png"];

						if (this.editImageList.length + this.newFiles.length
							+ selectedFiles.length > 3) {

							alert("리뷰 이미지는 최대 3개까지 등록할 수 있습니다.");
							event.target.value = "";
							return;
						}

						for (let file of selectedFiles) {

							if (!allowedTypes.includes(file.type)) {
								alert("JPG, JPEG, PNG 파일만 업로드할 수 있습니다.");
								event.target.value = "";
								return;
							}

							if (file.size > 5 * 1024 * 1024) {
								alert("이미지는 한 장당 5MB 이하만 가능합니다.");
								event.target.value = "";
								return;
							}
						}

						this.newFiles = this.newFiles.concat(selectedFiles);

						this.refreshPreview();

						event.target.value = "";
					},

					// 새 이미지 삭제
					fnRemoveNewImage(index) {

						this.newFiles.splice(index, 1);
						this.refreshPreview();
					},

					// 미리보기 재생성
					refreshPreview() {

						this.clearPreview();

						this.newImagePreview = this.newFiles.map(file =>
							URL.createObjectURL(file)
						);
					},

					// 미리보기 URL 정리
					clearPreview() {

						this.newImagePreview.forEach(url =>
							URL.revokeObjectURL(url)
						);

						this.newImagePreview = [];
					},

					// 취소
					fnCancel() {

						this.clearPreview();

						this.editReviewId = null;
						this.editRating = 0;
						this.editContent = "";
						this.editImageList = [];
						this.deleteImageList = [];
						this.newFiles = [];
					},

					// 수정 저장
					fnUpdate(reviewId) {

						let self = this;

						if (self.editRating < 1 || self.editRating > 5) {
							alert("별점을 선택해주세요.");
							return;
						}

						if (!self.editContent.trim()) {
							alert("리뷰 내용을 입력해주세요.");
							return;
						}

						if (self.editImageList.length + self.newFiles.length > 3) {
							alert("리뷰 이미지는 최대 3개까지 가능합니다.");
							return;
						}

						let formData = new FormData();

						formData.append("reviewId", reviewId);
						formData.append("memberId", self.memberId);
						formData.append("rating", self.editRating);
						formData.append("reviewContent", self.editContent);

						formData.append(
							"deleteImageList",
							JSON.stringify(self.deleteImageList)
						);

						self.newFiles.forEach(file => {
							formData.append("files", file);
						});

						$.ajax({
							url: "/review/edit.dox",
							type: "POST",
							data: formData,
							processData: false,
							contentType: false,
							dataType: "json",

							success(data) {

								if (data.result == "success") {
									alert("리뷰가 수정되었습니다.");

									self.fnCancel();
									self.fnList();

								} else {
									alert(data.message || "수정에 실패했습니다.");
								}
							},

							error(xhr) {
								alert("리뷰 수정 중 오류가 발생했습니다.");
								console.log(xhr.responseText);
							}
						});
					},

					// 리뷰 삭제
					fnRemove(reviewId) {

						let self = this;

						if (!confirm("정말로 리뷰를 삭제하시겠습니까?")) {
							return;
						}

						$.ajax({
							url: "/review/remove.dox",
							type: "POST",
							dataType: "json",
							data: {
								reviewId: reviewId,
								memberId: self.memberId
							},

							success(data) {

								if (data.result == "success") {
									alert("리뷰가 삭제되었습니다.");
									self.fnList();
								} else {
									alert(data.message || "삭제에 실패했습니다.");
								}
							},

							error() {
								alert("리뷰 삭제 중 오류가 발생했습니다.");
							}
						});
					}
				},

				mounted() {
					this.fnList();
				},

				beforeUnmount() {
					this.clearPreview();
				}
			});

			app.mount("#app");
		</script>

	</body>

	</html>