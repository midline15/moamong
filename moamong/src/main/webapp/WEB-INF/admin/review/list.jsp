
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>리뷰 관리</title>

    <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
    <script src="/js/page-change.js"></script>

    <link rel="stylesheet" href="/css/admin/adminLayout.css">
    <link rel="stylesheet" href="/css/admin/default.css">
    <link rel="stylesheet" href="/css/admin/review/list.css">
</head>

<body>

    <%@ include file="/WEB-INF/common/adminHeader.jsp"%>

    <div class="adm-shell">

        <%@ include file="/WEB-INF/common/adminSidebar.jsp"%>

        <main class="adm-main">

            <div id="app">

                <!-- 페이지 제목 -->
                <div class="page-title">
                    <h3>리뷰 관리</h3>
                </div>

                <div class="breadcrumb">
                    상품 관리 / 리뷰 관리
                </div>

                <div class="content-area">

                    <!-- 1. 리뷰 통계 -->
                    <div class="review-stats">

                        <div class="stats-card">
                            <div class="stats-title">전체 리뷰</div>
                            <div class="stats-value">
                                <strong>{{ reviewStats.totalReview }}</strong>건
                            </div>
                        </div>

                        <div class="stats-card">
                            <div class="stats-title">평균 별점</div>
                            <div class="stats-value">
                                <strong>{{ reviewStats.avgRating ?? 0 }}</strong>점
                            </div>
                        </div>

                        <div class="stats-card">
                            <div class="stats-title">숨김 리뷰</div>
                            <div class="stats-value">
                                <strong>{{ reviewStats.hiddenReview }}</strong>건
                            </div>
                        </div>

                        <div class="stats-card">
                            <div class="stats-title">사진 리뷰</div>
                            <div class="stats-value">
                                <strong>{{ reviewStats.photoReview }}</strong>건
                            </div>
                        </div>

                    </div>

                    <!-- 2. 리뷰 검색 -->
                    <div class="review-search">

                        <h3>리뷰 검색</h3>

                        <div class="search-row">

                            <div class="search-item">
                                <label>검색어</label>
                                <input
                                    type="text"
                                    v-model="keyword"
                                    placeholder="작성자, 상품명 또는 리뷰 내용"
                                    @keyup.enter="fnSearch">
                            </div>

                            <div class="search-item">
                                <label>리뷰 상태</label>
                                <select v-model="reviewStatus">
                                    <option value="">전체 상태</option>
                                    <option value="ACTIVE">정상</option>
                                    <option value="HIDDEN">숨김</option>
                                </select>
                            </div>

                            <div class="search-item">
                                <label>별점</label>
                                <select v-model="rating">
                                    <option value="">전체 별점</option>
                                    <option value="5">5점</option>
                                    <option value="4">4점</option>
                                    <option value="3">3점</option>
                                    <option value="2">2점</option>
                                    <option value="1">1점</option>
                                </select>
                            </div>

                            <div class="search-item">
                                <label>상품 유형</label>
                                <select v-model="reviewType">
                                    <option value="">전체 유형</option>
                                    <option value="PRODUCT">일반 상품</option>
                                    <option value="PACKAGE">패키지</option>
                                </select>
                            </div>

                        </div>

                        <div class="search-row">

                            <div class="search-item">
                                <label>작성 시작일</label>
                                <input type="date" v-model="startDate">
                            </div>

                            <div class="search-item">
                                <label>작성 종료일</label>
                                <input type="date" v-model="endDate">
                            </div>

                        </div>

                        <div class="search-buttons">

                            <button class="btn-reset" @click="fnReset">
                                초기화
                            </button>

                            <button class="btn-search" @click="fnSearch">
                                검색
                            </button>

                        </div>

                    </div>

                    <!-- 3. 리뷰 목록 -->
                    <div class="review-list">

                        <div class="list-header">
                            <h3>리뷰 목록</h3>
                            <span>총 {{ totalCount }}건</span>
                        </div>

                        <table class="review-table">

                            <thead>
                                <tr>
                                    <th>상품 정보</th>
                                    <th>작성자</th>
                                    <th>별점</th>
                                    <th>리뷰 내용 및 사진</th>
                                    <th>작성일</th>
                                    <th>상태</th>
                                    <th>관리</th>
                                </tr>
                            </thead>

                            <tbody>

                                <tr
                                    v-for="review in reviewList"
                                    :key="review.reviewId">

                                    <!-- 상품 정보 -->
                                    <td class="product-info">

                                        <img
                                            v-if="review.productThumb"
                                            :src="review.productThumb"
                                            alt="상품 이미지"
                                            class="product-thumb">

                                        <span v-else class="no-image">
                                            이미지 없음
                                        </span>

                                        <div>
                                            <span class="product-type">
                                                {{ review.reviewType === 'PRODUCT' ? '일반 상품' : '패키지' }}
                                            </span>

                                            <strong>
                                                {{ review.productName || '-' }}
                                            </strong>
                                        </div>

                                    </td>

                                    <!-- 작성자 -->
                                    <td>
                                        {{ review.memberName || '-' }}
                                    </td>

                                    <!-- 별점 -->
                                    <td class="review-rating">
                                        <span>★</span>
                                        {{ review.rating }}점
                                    </td>

                                    <!-- 리뷰 내용 및 사진 -->
                                    <td class="review-content">

                                        <div class="review-text">
                                            {{ review.reviewContent || '-' }}
                                        </div>

                                        <div
                                            class="review-images"
                                            v-if="review.imageList && review.imageList.length > 0">

                                            <img
                                                v-for="(image, index) in review.imageList.slice(0, 3)"
                                                :key="image.imageId || index"
                                                :src="image.imageUrl"
                                                alt="리뷰 사진"
                                                class="review-thumb">

                                            <span
                                                v-if="review.imageList.length > 3"
                                                class="more-images">
                                                +{{ review.imageList.length - 3 }}
                                            </span>

                                        </div>

                                    </td>

                                    <!-- 작성일 -->
                                    <td>
                                        {{ review.createdAt || '-' }}
                                    </td>

                                    <!-- 리뷰 상태 -->
                                    <td>
                                        <span
                                            class="status-badge"
                                            :class="review.reviewStatus === 'ACTIVE' ? 'active' : 'hidden'">

                                            {{ fnStatusName(review.reviewStatus) }}

                                        </span>
                                    </td>

                                    <!-- 관리 -->
                                    <td>

                                        <button
                                            v-if="review.reviewStatus === 'ACTIVE'"
                                            class="btn-hide"
                                            @click="fnChangeStatus(review, 'HIDDEN')">
                                            숨김
                                        </button>

                                        <button
                                            v-else-if="review.reviewStatus === 'HIDDEN'"
                                            class="btn-restore"
                                            @click="fnChangeStatus(review, 'ACTIVE')">
                                            복구
                                        </button>

                                        <button
                                            v-if="review.reviewStatus !== 'DELETE'"
                                            class="btn-hide"
                                            @click="fnChangeStatus(review, 'DELETE')">
                                            삭제
                                        </button>

                                    </td>

                                </tr>

                                <!-- 조회 결과 없음 -->
                                <tr v-if="reviewList.length === 0">
                                    <td colspan="7">
                                        조회된 리뷰가 없습니다.
                                    </td>
                                </tr>

                            </tbody>

                        </table>

                        <!-- 페이지 이동 -->
                        <div class="pagination">

                            <button
                                @click="fnPage(1)"
                                :disabled="currentPage == 1">
                                처음
                            </button>

                            <button
                                @click="fnPage(currentPage - 1)"
                                :disabled="currentPage == 1">
                                이전
                            </button>

                            <button
                                v-for="page in visiblePages"
                                :key="page"
                                @click="fnPage(page)"
                                :class="{ active: currentPage == page }">
                                {{ page }}
                            </button>

                            <button
                                @click="fnPage(currentPage + 1)"
                                :disabled="currentPage >= totalPages">
                                다음
                            </button>

                            <button
                                @click="fnPage(totalPages)"
                                :disabled="currentPage >= totalPages">
                                마지막
                            </button>

                        </div>

                    </div>

                </div>

            </div>

        </main>

    </div>

    <script>

        const app = Vue.createApp({

            // 화면 데이터
            data() {

                return {

                    // 검색 조건
                    keyword: "",
                    reviewStatus: "",
                    rating: "",
                    reviewType: "",
                    startDate: "",
                    endDate: "",

                    // 페이지 정보
                    currentPage: 1,
                    pageSize: 10,

                    // 리뷰 목록
                    reviewList: [],

                    // 전체 리뷰 수
                    totalCount: 0,

                    // 리뷰 통계
                    reviewStats: {
                        totalReview: 0,
                        avgRating: 0,
                        hiddenReview: 0,
                        photoReview: 0
                    }

                };

            },

            // 계산된 데이터
            computed: {

                // 전체 페이지 수
                totalPages() {

                    return Math.max(
                        1,
                        Math.ceil(this.totalCount / this.pageSize)
                    );

                },

                // 화면에 표시할 페이지 번호
                visiblePages() {

                    let pageGroupSize = 5;

                    let startPage =
                        Math.floor((this.currentPage - 1) / pageGroupSize)
                        * pageGroupSize + 1;

                    let endPage = Math.min(
                        startPage + pageGroupSize - 1,
                        this.totalPages
                    );

                    let pages = [];

                    for (let i = startPage; i <= endPage; i++) {
                        pages.push(i);
                    }

                    return pages;

                }

            },

            // 화면 함수
            methods: {

                // 관리자 리뷰 목록 조회
                fnList() {

                    let self = this;

                    let param = {

                        keyword: self.keyword,
                        reviewStatus: self.reviewStatus,
                        rating: self.rating,
                        reviewType: self.reviewType,
                        startDate: self.startDate,
                        endDate: self.endDate,
                        page: self.currentPage

                    };

                    $.ajax({

                        url: "/admin/review/list.dox",
                        type: "POST",
                        dataType: "json",
                        data: param,

                        success: function(data) {

                            if (data.result === "success") {

                                self.reviewList = data.list || [];
                                self.totalCount = Number(data.count) || 0;

                            } else {

                                alert(data.message || "리뷰 목록 조회에 실패했습니다.");

                            }

                        },

                        error: function() {

                            alert("리뷰 목록 조회 중 서버 통신 오류가 발생했습니다.");

                        }

                    });

                },

                // 관리자 리뷰 통계 조회
                fnStats() {

                    let self = this;

                    $.ajax({

                        url: "/admin/review/stats.dox",
                        type: "POST",
                        dataType: "json",

                        success: function(data) {

                            if (data.result === "success") {

                                self.reviewStats = Object.assign(
                                    {},
                                    self.reviewStats,
                                    data.stats || {}
                                );

                            } else {

                                alert(data.message || "리뷰 통계 조회에 실패했습니다.");

                            }

                        },

                        error: function() {

                            alert("리뷰 통계 조회 중 서버 통신 오류가 발생했습니다.");

                        }

                    });

                },

                // 리뷰 상태 한글 변환
                fnStatusName(status) {

                    const statusMap = {
                        ACTIVE: "정상",
                        HIDDEN: "숨김",
                        DELETE: "삭제"
                    };

                    return statusMap[status] || "-";

                },

                // 리뷰 상태 변경
                fnChangeStatus(review, status) {

                    let message = "";

                    if (status === "HIDDEN") {
                        message = "이 리뷰를 숨김 처리하시겠습니까?";
                    } else if (status === "ACTIVE") {
                        message = "이 리뷰를 다시 정상 상태로 복구하시겠습니까?";
                    } else if (status === "DELETE") {
                        message = "이 리뷰를 삭제 처리하시겠습니까?\n삭제 후에는 기본 리뷰 목록에서 조회되지 않습니다.";
                    }

                    if (!confirm(message)) {
                        return;
                    }

                    let self = this;

                    $.ajax({

                        url: "/admin/review/status.dox",
                        type: "POST",
                        dataType: "json",

                        data: {
                            reviewId: review.reviewId,
                            reviewStatus: status
                        },

                        success: function(data) {

                            if (data.result === "success") {

                                alert(data.message || "리뷰 상태가 변경되었습니다.");

                                self.fnList();
                                self.fnStats();

                            } else {

                                alert(data.message || "리뷰 상태 변경에 실패했습니다.");

                            }

                        },

                        error: function() {

                            alert("리뷰 상태 변경 중 서버 통신 오류가 발생했습니다.");

                        }

                    });

                },

                // 검색
                fnSearch() {

                    if (this.startDate && this.endDate
                        && this.startDate > this.endDate) {

                        alert("작성 시작일은 종료일보다 늦을 수 없습니다.");
                        return;

                    }

                    this.currentPage = 1;
                    this.fnList();

                },

                // 검색 조건 초기화
                fnReset() {

                    this.keyword = "";
                    this.reviewStatus = "";
                    this.rating = "";
                    this.reviewType = "";
                    this.startDate = "";
                    this.endDate = "";

                    this.currentPage = 1;

                    this.fnList();

                },

                // 페이지 이동
                fnPage(page) {

                    page = Number(page);

                    if (page < 1 || page > this.totalPages) {
                        return;
                    }

                    this.currentPage = page;
                    this.fnList();

                }

            },

            // 최초 실행
            mounted() {

                this.fnList();
                this.fnStats();

            }

        });

        app.mount("#app");

    </script>

</body>

</html>
