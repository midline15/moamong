<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>모아몽 - 나의 리뷰 관리</title>

		<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypage.css">
		<link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypageSub.css">
	</head>
	<body>
		<%@ include file="/WEB-INF/common/header.jsp"%>

		<div id="app" class="mp-wrap">
			<%@ include file="/WEB-INF/common/mypageSidebar.jsp"%>

			<main class="mp-main">
				<div class="mp-sub-top">
					<h2>리뷰 관리</h2>
					<span class="mp-breadcrumb">마이페이지 &gt; 리뷰관리</span>
				</div>

				<div class="mp-sub-tabs">
					<button type="button" class="mp-sub-tab" @click="location.href='/order/list.do'">리뷰작성 (주문내역)</button>
					<button type="button" class="mp-sub-tab active">리뷰목록 ({{ list.length }})</button>
				</div>

				<div v-if="pagedList.length === 0" class="mp-card" style="text-align:center; padding:60px 20px; color:#85817b;">
					아직 작성한 리뷰가 없습니다.
				</div>

				<div v-for="review in pagedList" :key="review.reviewId" class="mp-item-card">
					<!-- 일반 리뷰 조회 -->
					<template v-if="editReviewId !== review.reviewId">
						<img :src="(review.imageList && review.imageList.length > 0) ? review.imageList[0].imageUrl : '/images/no-image.png'"
						alt="리뷰 썸네일" class="mp-item-thumb">

						<div class="mp-item-body">
							<div class="mp-item-title">{{ review.productName }}</div>
							<div class="mp-item-stars">{{ '★'.repeat(review.rating) }}{{ '☆'.repeat(5 - review.rating) }}</div>
							<div class="mp-item-text">{{ review.reviewContent }}</div>

							<div v-if="review.imageList && review.imageList.length > 1" class="rv-img-grid">
								<div v-for="img in review.imageList" :key="img.imageId" class="rv-img-box">
									<img :src="img.imageUrl" alt="리뷰 이미지">
								</div>
							</div>
							<div class="mp-item-meta">작성일 : {{ review.createdAt }}</div>
						</div>

						<div class="mp-item-actions">
							<button type="button" class="mp-btn mp-btn-gold" @click="fnEditMode(review)">수정</button>
							<button type="button" class="mp-btn mp-btn-danger" @click="fnRemove(review.reviewId)">삭제</button>
						</div>
					</template>
					<!-- 리뷰 수정 모드 -->
					<div v-else style="width:100%;">
						<div style="display:flex; justify-content:space-between; align-items:center; padding-bottom:10px; border-bottom:1px solid #e3d6c1;">
							<strong class="mp-item-title">{{ review.productName }}</strong>
							<span class="mp-badge">수정 중</span>
						</div>

						<label class="rv-edit-label">별점</label>
						<div>
							<button v-for="num in 5" :key="num" type="button" class="rv-star-btn"
							:class="{ active: editRating >= num }" @click="editRating = num">★</button>
						</div>

						<label class="rv-edit-label">리뷰 내용</label>
						<textarea v-model="editContent" class="rv-textarea" placeholder="리뷰 내용을 입력해주세요."></textarea>

						<label class="rv-edit-label">기존 등록 이미지 ({{ editImageList.length }}/3)</label>
						<div v-if="editImageList.length > 0" class="rv-img-grid">
							<div v-for="img in editImageList" :key="img.imageId" class="rv-img-box">
								<img :src="img.imageUrl" alt="기존 리뷰 이미지">
								<button type="button" class="rv-img-del" @click="fnRemoveImage(img.imageId)">×</button>
							</div>
						</div>

						<label class="rv-edit-label">새로운 이미지 추가 ({{ editImageList.length + newFiles.length }}/3)</label>
						<input type="file" accept=".jpg,.jpeg,.png,image/jpeg,image/png" multiple @change="fnFileChange"
						ref="fileInput" :disabled="editImageList.length + newFiles.length >= 3" style="font-size:12px;">
						<p class="mp-item-meta">JPG, JPEG, PNG 파일만 가능하며 이미지당 최대 5MB, 총 3장까지 등록할 수 있습니다.</p>

						<div v-if="newImagePreview.length > 0" class="rv-img-grid">
							<div v-for="(url, idx) in newImagePreview" :key="idx" class="rv-img-box">
								<img :src="url" alt="새 이미지 미리보기">
								<button type="button" class="rv-img-del" @click="fnRemoveNewImage(idx)">×</button>
							</div>
						</div>

						<div class="mp-item-actions" style="justify-content:flex-end; margin-top:16px;">
							<button type="button" class="mp-btn" @click="fnCancel">취소</button>
							<button type="button" class="mp-btn mp-btn-gold" @click="fnUpdate(review.reviewId)">수정 완료</button>
						</div>
					</div>
				</div>

				<div v-if="totalPages > 1" class="mp-paging">
					<button class="mp-page-btn" :disabled="page === 1" @click="page = 1">&laquo;</button>
					<button class="mp-page-btn" :disabled="page === 1" @click="page--">&lsaquo;</button>
					<button v-for="p in totalPages" :key="p" class="mp-page-btn" :class="{ active: p === page }" @click="page = p">{{ p }}</button>
					<button class="mp-page-btn" :disabled="page === totalPages" @click="page++">&rsaquo;</button>
					<button class="mp-page-btn" :disabled="page === totalPages" @click="page = totalPages">&raquo;</button>
				</div>
			</main>
		</div>

		<%@ include file="/WEB-INF/common/footer.jsp"%>
	</body>
</html>
<script>
	const app = Vue.createApp({
		data() {
			return {
				list: [], page: 1, pageSize: 5,
				editReviewId: null, editRating: 0, editContent: "",
				editImageList: [], deleteImageList: [], newFiles: [], newImagePreview: [],
				memberId: "${memberId}"
			};
		},
		computed: {
			totalPages() { return Math.max(1, Math.ceil(this.list.length / this.pageSize)); },
			pagedList() { return this.list.slice((this.page - 1) * this.pageSize, this.page * this.pageSize); }
		},
		methods: {
			fnList() {
				let self = this;
				$.ajax({
					url: "/review/my-list.dox", type: "POST", dataType: "json",
					data: { memberId: self.memberId },
					success(data) {
						if (data.result == "success") {
							self.list = data.list || [];
							if (self.page > self.totalPages) self.page = self.totalPages;
						} else { alert("리뷰 목록 조회에 실패했습니다."); }
					},
					error() { alert("서버 통신 오류가 발생했습니다."); }
				});
			},
			fnEditMode(review) {
				this.editReviewId = review.reviewId;
				this.editRating = review.rating;
				this.editContent = review.reviewContent;
				this.editImageList = (review.imageList || []).map(img => Object.assign({}, img));
				this.deleteImageList = []; this.newFiles = []; this.clearPreview();
			},
			fnRemoveImage(imageId) {
				this.deleteImageList.push(imageId);
				this.editImageList = this.editImageList.filter(img => img.imageId !== imageId);
			},
			fnFileChange(event) {
				const selectedFiles = Array.from(event.target.files);
				const allowedTypes = ["image/jpeg", "image/png"];
				if (this.editImageList.length + this.newFiles.length + selectedFiles.length > 3) {
					alert("리뷰 이미지는 최대 3개까지 등록할 수 있습니다."); event.target.value = ""; return;
				}
				for (let file of selectedFiles) {
					if (!allowedTypes.includes(file.type)) { alert("JPG, JPEG, PNG 파일만 업로드할 수 있습니다."); event.target.value = ""; return; }
					if (file.size > 5 * 1024 * 1024) { alert("이미지는 한 장당 5MB 이하만 가능합니다."); event.target.value = ""; return; }
				}
				this.newFiles = this.newFiles.concat(selectedFiles);
				this.refreshPreview(); event.target.value = "";
			},
			fnRemoveNewImage(index) { this.newFiles.splice(index, 1); this.refreshPreview(); },
			refreshPreview() { this.clearPreview(); this.newImagePreview = this.newFiles.map(file => URL.createObjectURL(file)); },
			clearPreview() { this.newImagePreview.forEach(url => URL.revokeObjectURL(url)); this.newImagePreview = []; },
			fnCancel() {
				this.clearPreview();
				this.editReviewId = null; this.editRating = 0; this.editContent = "";
				this.editImageList = []; this.deleteImageList = []; this.newFiles = [];
			},
			fnUpdate(reviewId) {
				let self = this;
				if (self.editRating < 1 || self.editRating > 5) { alert("별점을 선택해주세요."); return; }
				if (!self.editContent.trim()) { alert("리뷰 내용을 입력해주세요."); return; }
				if (self.editImageList.length + self.newFiles.length > 3) { alert("리뷰 이미지는 최대 3개까지 가능합니다."); return; }
				
				let formData = new FormData();
				formData.append("reviewId", reviewId);
				formData.append("memberId", self.memberId);
				formData.append("rating", self.editRating);
				formData.append("reviewContent", self.editContent);
				formData.append("deleteImageList", JSON.stringify(self.deleteImageList));
				self.newFiles.forEach(file => formData.append("files", file));
				
				$.ajax({
					url: "/review/edit.dox", type: "POST", data: formData,
					processData: false, contentType: false, dataType: "json",
					success(data) {
						if (data.result == "success") { alert("리뷰가 수정되었습니다."); self.fnCancel(); self.fnList(); }
						else { alert(data.message || "수정에 실패했습니다."); }
					},
					error(xhr) { alert("리뷰 수정 중 오류가 발생했습니다."); console.log(xhr.responseText); }
				});
			},
			fnRemove(reviewId) {
				let self = this;
				if (!confirm("정말로 리뷰를 삭제하시겠습니까?")) return;
				$.ajax({
					url: "/review/remove.dox", type: "POST", dataType: "json",
					data: { reviewId: reviewId, memberId: self.memberId },
					success(data) {
						if (data.result == "success") { alert("리뷰가 삭제되었습니다."); self.fnList(); }
						else { alert(data.message || "삭제에 실패했습니다."); }
					},
					error() { alert("리뷰 삭제 중 오류가 발생했습니다."); }
				});
			}
		},
		mounted() { this.fnList(); },
		beforeUnmount() { this.clearPreview(); }
	});
	app.mount("#app");
</script>
