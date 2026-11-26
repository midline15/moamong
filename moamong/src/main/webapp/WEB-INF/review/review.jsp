<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/review/review.css">
    <!-- 리뷰 -->
    <div class="review-section" v-show="activeTab === 'review'">

        <!-- 리뷰 제목 -->
        <div class="review-heading">
            <div>
                <strong>구매 리뷰</strong>
                <span>{{ reviewTotalCount }}</span>
            </div>
            <button type="button" class="review-write-btn" @click="fnReviewWrite">
                리뷰 작성
            </button>
        </div>

        <p class="review-guide">
            구매하신 분들이 남겨주신 소중한 후기입니다.
        </p>

        <!-- 리뷰가 없는 경우 -->
        <div class="empty-message" v-if="reviewTotalCount === 0">
            등록된 리뷰가 없습니다.
        </div>

        <template v-else>

            <!-- 별점 필터 -->
            <div class="review-filter">

                <button type="button" :class="{ active: selectedRating === 0 }" @click="selectedRating = 0">
                    전체
                </button>

                <button type="button" v-for="rating in [5, 4, 3, 2, 1]" :key="rating"
                    :class="{ active: selectedRating === rating }" @click="selectedRating = rating">
                    {{ rating }}점
                </button>

            </div>

            <!-- 리뷰 목록 -->
            <div class="review-list">

                <div class="review-item" v-for="review in filteredReviewList" :key="review.reviewId">

                    <!-- 리뷰 별점 -->
                    <div class="review-rating">
                        <span v-for="n in 5" :key="n" :class="{ active: n <= review.rating }">
                            ★
                        </span>

                        <div class="review-member">
                            회원 {{ review.memberId }}
                        </div>

                        <div class="review-date">
                            {{ review.createdAt ? review.createdAt.substring(0, 10) : '' }}
                        </div>
                    </div>

                    <!-- 리뷰 내용 -->
                    <div class="review-content">

                        <div class="review-content-rating">
                            별점 {{ review.rating }}점
                        </div>

                        <p>{{ review.reviewContent }}</p>

                        <!-- 리뷰 이미지 -->
                        <div class="review-image-list" v-if="review.imageList && review.imageList.length > 0">

                            <img v-for="image in review.imageList" :key="image.imageId" :src="image.imageUrl"
                                alt="리뷰 이미지">

                        </div>

                    </div>

                    <!-- 리뷰 수정 및 삭제 버튼 -->
                    <div class="review-manage-btn" v-if="isAdmin || review.memberId == '${sessionScope.sessionId}'">

                        <!-- 본인이 작성한 리뷰는 관리자 여부와 관계없이 수정 가능 -->
                        <button type="button" v-if="review.memberId == '${sessionScope.sessionId}'"
                            @click="fnReviewEdit(review)">
                            수정
                        </button>

                        <!-- 본인 리뷰 또는 관리자라면 삭제 가능 -->
                        <button type="button" v-if="isAdmin || review.memberId == '${sessionScope.sessionId}'"
                            @click="fnReviewDelete(review.reviewId)">
                            삭제
                        </button>

                    </div>

                </div>

            </div>

            <!-- 리뷰 수정 모달 -->
            <div class="review-write-modal" v-if="showReviewEdit">
                <div class="review-write-content">

                    <h3>리뷰 수정</h3>

                    <button type="button" class="review-close-btn" @click="showReviewEdit = false">
                        닫기
                    </button>

                    <!-- 별점 -->
                    <div class="review-form">
                        <label>별점</label>

                        <div class="review-rating-select">
                            <button type="button" v-for="n in 5" :key="n" :class="{ active: n <= editReviewRating }"
                                @click="editReviewRating = n">
                                ★
                            </button>
                        </div>

                        <!-- 리뷰 내용 -->
                        <label for="editReviewContent">리뷰 내용</label>
                        <textarea id="editReviewContent" v-model="editReviewContent" placeholder="리뷰 내용을 입력해 주세요."
                            rows="5">
            </textarea>

                        <!-- 기존 이미지 -->
                        <div class="review-image-list" v-if="editReviewImageList.length > 0">

                            <div v-for="image in editReviewImageList" :key="image.imageId">

                                <img :src="image.imageUrl" alt="기존 리뷰 이미지">

                                <button type="button" @click="fnReviewImageDelete(image.imageId)">
                                    삭제
                                </button>

                            </div>

                        </div>

                        <!-- 새 이미지 -->
                        <label for="editReviewFiles">이미지 추가</label>
                        <input type="file" id="editReviewFiles" multiple accept="image/*" @change="fnReviewFileChange">

                        <button type="button" class="review-submit-btn" @click="fnReviewEditSave">
                            수정 완료
                        </button>
                    </div>

                </div>
            </div>

            <!-- 페이지네이션 -->
            <div class="review-pagination" v-if="reviewMaxPage > 1">

                <button type="button" @click="fnReviewPage(reviewPage - 1)" :disabled="reviewPage === 1">
                    이전
                </button>

                <button type="button" v-for="n in reviewMaxPage" :key="n" :class="{ active: reviewPage === n }"
                    @click="fnReviewPage(n)">
                    {{ n }}
                </button>

                <button type="button" @click="fnReviewPage(reviewPage + 1)" :disabled="reviewPage === reviewMaxPage">
                    다음
                </button>

            </div>

        </template>

    </div>