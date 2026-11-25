<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽</title>

        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.js"
            integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>

        <!-- Vue -->
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

        <script src="/js/page-change.js"></script>

        <!-- 공통 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">

        <!-- 상품 상세 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product/view.css">
    </head>

    <body>

        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>

            <div id="app">

                <main class="product-container" v-if="info.productName">

                    <!-- 상품명 및 카테고리 -->
                    <section class="product-heading">
                        <h2>{{ info.productName }}</h2>

                        <div class="category-menu">
                            <button type="button" class="active">액세서리</button>
                            <button type="button">생활용품</button>
                            <button type="button">패션</button>
                            <button type="button">소품</button>
                            <button type="button">푸드</button>
                        </div>
                    </section>

                    <!-- 상품 구매 영역 -->
                    <section class="product-main">

                        <!-- 상품 이미지 영역 -->
                        <div class="product-gallery">

                            <div class="main-image">
                                <img v-if="selectedImageUrl" :src="selectedImageUrl" :alt="info.productName">

                                <div v-else class="empty-image">
                                    등록된 상품 이미지가 없습니다.
                                </div>
                            </div>

                        </div>

                        <!-- 상품 정보 영역 -->
                        <div class="product-info">

                            <div class="product-title-area">
                                <div>
                                    <h2>{{ info.productName }}</h2>
                                    <p class="product-category">모아몽 상품 · 특별한 순간을 위한 선물</p>
                                </div>

                                <button type="button" class="wish-btn" :class="{ active: isWished }"
                                    @click="fnWishToggle" :title="isWished ? '찜 해제' : '찜하기'">

                                    {{ isWished ? '♥' : '♡' }}

                                </button>
                            </div>

                            <p class="product-price">
                                {{ Number(info.price || 0).toLocaleString() }}원
                            </p>

                            <div class="product-benefit">

                                <div class="info-line">
                                    <strong>쿠폰</strong>
                                    <span>첫 구매 고객 쿠폰 혜택</span>
                                    <span class="info-guide">쿠폰 보기</span>
                                </div>

                                <div class="info-line">
                                    <strong>적립</strong>
                                    <span>멤버십 포인트 적립</span>
                                    <span class="info-guide">포인트 안내</span>
                                </div>

                                <div class="info-line">
                                    <strong>결제</strong>
                                    <span>카드사별 혜택 안내</span>
                                    <span class="info-guide">자세히 보기</span>
                                </div>

                                <div class="info-line">
                                    <strong>배송</strong>
                                    <span>택배 배송</span>
                                </div>

                            </div>

                            <!-- 옵션 선택 -->
                            <div class="option-area">

                                <label for="productOption">옵션</label>

                                <select id="productOption" v-model.number="selectedOptionPrice">
                                    <option :value="0">기본 구성</option>
                                </select>

                            </div>

                        </div>

                    </section>

                    <!-- 상품 구매 및 금액 영역 -->
                    <section class="purchase-section">

                        <div class="purchase-product">
                            <span><strong>구매 상품 :</strong> {{ info.productName }}</span>

                            <div class="quantity-control">
                                <button type="button" @click="fnQuantityChange(-1)">-</button>
                                <input type="number" v-model.number="quantity" min="1" :max="Number(info.stockQuantity)"
                                    @change="fnQuantityCheck">
                                <button type="button" @click="fnQuantityChange(1)">+</button>
                            </div>
                        </div>

                        <div class="purchase-option">
                            <span>
                                <strong>선택한 옵션 :</strong>
                                {{ selectedOptionPrice > 0 ? '고급 포장' : '기본 구성' }}
                                <span v-if="selectedOptionPrice > 0">
                                    (+ {{ selectedOptionPrice.toLocaleString() }}원)
                                </span>
                            </span>
                        </div>

                        <div class="purchase-buttons">

                            <button type="button" class="cart-btn" @click="fnAddCart"
                                :disabled="info.productStatus !== 'SELLING' || Number(info.stockQuantity) <= 0">
                                장바구니
                            </button>

                            <button type="button" class="buy-btn"
                                :disabled="info.productStatus !== 'SELLING' || Number(info.stockQuantity) <= 0"
                                @click="fnBuy">
                                구매하기
                            </button>

                        </div>

                        <div class="purchase-total">
                            <div>
                                <strong>배송비 :</strong>
                                {{ deliveryFee.toLocaleString() }}원
                            </div>

                            <div class="total-price">
                                <strong>총 금액 :</strong>
                                <span>{{ totalPrice.toLocaleString() }}원</span>
                            </div>
                        </div>

                    </section>

                    <!-- 상품 상세 탭 -->
                    <section class="detail-section">

                        <div class="detail-tabs">

                            <button type="button" :class="{ active: activeTab === 'description' }"
                                @click="activeTab = 'description'">
                                상품정보
                            </button>

                            <button type="button" :class="{ active: activeTab === 'review' }" @click="fnReviewTab">
                                리뷰
                            </button>

                            <button type="button" :class="{ active: activeTab === 'inquiry' }" @click="fnInqTab">
                                문의
                            </button>

                        </div>

                        <!-- 상품 상세 설명 -->
                        <div class="detail-content" v-if="activeTab === 'description'">

                            <div v-if="info.productDescription" class="description-content"
                                v-html="info.productDescription">
                            </div>

                            <div v-else class="empty-message">
                                등록된 상품 상세 설명이 없습니다.
                            </div>


                            <!-- 배송 및 교환 안내 -->
                            <section class="delivery-section">

                                <h3>배송/교환/반품 안내</h3>

                                <div class="delivery-table-area">

                                    <h4>배송안내</h4>

                                    <table class="guide-table">
                                        <tbody>
                                            <tr>
                                                <th>택배 배송</th>
                                                <td>
                                                    <strong>3,000원</strong><br>
                                                    배송 기간은 결제 완료 후 영업일 기준으로 안내됩니다.
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>배송 기간</th>
                                                <td>
                                                    상품 준비 및 배송 상황에 따라 배송 기간이 달라질 수 있습니다.
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>

                                    <h4>반품/교환</h4>

                                    <table class="guide-table">
                                        <tbody>
                                            <tr>
                                                <th>반품 배송비</th>
                                                <td>왕복 배송비 6,000원</td>
                                            </tr>
                                            <tr>
                                                <th>교환 및 반품 안내</th>
                                                <td>
                                                    <ol>
                                                        <li>상품 수령 후 교환 및 반품 가능 여부를 확인해 주세요.</li>
                                                        <li>상품의 사용 흔적이나 훼손이 있는 경우 제한될 수 있습니다.</li>
                                                        <li>단순 변심에 의한 반품은 배송비가 발생할 수 있습니다.</li>
                                                        <li>상품에 문제가 있는 경우 고객센터로 문의해 주세요.</li>
                                                    </ol>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>

                                </div>

                            </section>

                        </div>

                        <!-- 리뷰 -->
                        <div class="review-section" v-else-if="activeTab === 'review'">

                            <!-- 리뷰 제목 -->
                            <div class="review-heading">
                                <div>
                                    <strong>구매 리뷰</strong>
                                    <span>{{ reviewTotalCount }}</span>
                                </div>
                                <button type="button" class="review-write-btn">
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

                                    <button type="button" :class="{ active: selectedRating === 0 }"
                                        @click="selectedRating = 0">
                                        전체
                                    </button>

                                    <button type="button" v-for="rating in [5, 4, 3, 2, 1]" :key="rating"
                                        :class="{ active: selectedRating === rating }" @click="selectedRating = rating">
                                        {{ rating }}점
                                    </button>

                                </div>

                                <!-- 리뷰 목록 -->
                                <div class="review-list">

                                    <div class="review-item" v-for="review in filteredReviewList"
                                        :key="review.reviewId">

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
                                            <div class="review-image-list"
                                                v-if="review.imageList && review.imageList.length > 0">

                                                <img v-for="image in review.imageList" :key="image.imageId"
                                                    :src="image.imageUrl" alt="리뷰 이미지">

                                            </div>

                                        </div>

                                    </div>

                                </div>

                                <!-- 페이지네이션 -->
                                <div class="review-pagination" v-if="reviewMaxPage > 1">

                                    <button type="button" @click="fnReviewPage(reviewPage - 1)"
                                        :disabled="reviewPage === 1">
                                        이전
                                    </button>

                                    <button type="button" v-for="n in reviewMaxPage" :key="n"
                                        :class="{ active: reviewPage === n }" @click="fnReviewPage(n)">
                                        {{ n }}
                                    </button>

                                    <button type="button" @click="fnReviewPage(reviewPage + 1)"
                                        :disabled="reviewPage === reviewMaxPage">
                                        다음
                                    </button>

                                </div>

                            </template>

                        </div>

                        <!-- 문의 -->
                        <div class="inquiry-section" v-else-if="activeTab === 'inquiry'">

                            <!-- 문의 제목 -->
                            <div class="inquiry-heading">
                                <div>
                                    <strong>상품 문의</strong>
                                    <span>{{ inquiryTotalCount }}</span>
                                </div>

                                <button type="button" class="inquiry-write-btn" @click="fnInqWrite">
                                    문의 작성
                                </button>
                            </div>

                            <!-- 문의 상태 필터 -->
                            <div class="inquiry-filter">

                                <button type="button" :class="{ active: selectedInqStatus === 'ALL' }"
                                    @click="fnInqStatus('ALL')">
                                    전체 ({{ inquiryTotalCount }})
                                </button>

                                <button type="button" :class="{ active: selectedInqStatus === 'ANSWERED' }"
                                    @click="fnInqStatus('ANSWERED')">
                                    답변완료 ({{ inquiryAnsweredCount }})
                                </button>

                                <button type="button" :class="{ active: selectedInqStatus === 'WAITING' }"
                                    @click="fnInqStatus('WAITING')">
                                    미답변 ({{ inquiryWaitingCount }})
                                </button>

                            </div>

                            <!-- 문의가 없는 경우 -->
                            <div class="empty-message" v-if="inquiryList.length === 0">
                                등록된 문의가 없습니다.
                            </div>

                            <template v-else>

                                <!-- 문의 목록 -->
                                <div class="inquiry-list">

                                    <div class="inquiry-item" v-for="inquiry in inquiryList" :key="inquiry.inqId">

                                        <!-- 문의 작성자 및 상태 -->
                                        <div class="inquiry-info">
                                            <span class="inquiry-status"
                                                :class="inquiry.inqStatus === 'ANSWERED' ? 'answered' : 'waiting'">
                                                {{ inquiry.inqStatus === 'ANSWERED' ? '답변완료' : '미답변' }}
                                            </span>

                                            <span class="inquiry-member">
                                                {{ inquiry.memberName }}
                                            </span>

                                            <span class="inquiry-date">
                                                {{ inquiry.createdAt ? inquiry.createdAt.substring(0, 10) : '' }}
                                            </span>
                                        </div>

                                        <!-- 문의 상품 및 제목 -->
                                        <div class="inquiry-content">
                                            <span class="inquiry-product-name">
                                                {{ inquiry.productName }}
                                            </span>

                                            <div class="inquiry-text">
                                                <span class="inquiry-secret" v-if="inquiry.isSecret === 'Y'">
                                                    비밀 문의
                                                </span>

                                                <strong>{{ inquiry.inqContent }}</strong>
                                            </div>
                                        </div>

                                        <!-- 문의 수정 및 삭제 버튼 -->
                                        <div class="inquiry-manage-btn"
                                            v-if="!isAdmin && inquiry.memberId == '${sessionScope.sessionId}'">

                                            <!-- 미답변 문의만 수정 가능 -->
                                            <button type="button" v-if="inquiry.inqStatus === 'WAITING'"
                                                @click="fnInqEdit(inquiry)">
                                                수정
                                            </button>

                                            <!-- 답변 상태와 관계없이 본인 문의 삭제 가능 -->
                                            <button type="button" @click="fnInqDelete(inquiry.inqId)">
                                                삭제
                                            </button>
                                        </div>

                                        <!-- 관리자 답변 작성 버튼 -->
                                        <button type="button" class="inquiry-answer-write-btn"
                                            v-if="isAdmin && inquiry.inqStatus === 'WAITING'"
                                            @click="fnInqAnswerWrite(inquiry)">
                                            답변 작성
                                        </button>

                                        <!-- 답변 펼쳐보기 -->
                                        <!-- 관리자 답변 -->
                                        <div class="inquiry-answer"
                                            v-if="inquiry.inqStatus === 'ANSWERED' && inquiry.answerContent">

                                            <button type="button" @click="inquiry.showAnswer = !inquiry.showAnswer">
                                                {{ inquiry.showAnswer ? '답변 접기' : '답변 펼쳐보기' }}
                                            </button>

                                            <div class="inquiry-answer-content" v-if="inquiry.showAnswer">
                                                <strong>관리자 답변</strong>
                                                <p>{{ inquiry.answerContent }}</p>

                                                <!-- 관리자 답변 수정 및 삭제 -->
                                                <div class="inquiry-manage-btn" v-if="isAdmin">
                                                    <button type="button" @click="fnInqAnswerEdit(inquiry)">
                                                        수정
                                                    </button>
                                                    <button type="button" @click="fnInqAnswerDelete(inquiry.inqId)">
                                                        삭제
                                                    </button>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- 관리자 답변 작성 모달 -->
                                        <div class="inquiry-write-modal" v-if="showInqAnswer">
                                            <div class="inquiry-write-content">
                                                <h3>상품 문의 답변 작성</h3>

                                                <button type="button" class="inquiry-close-btn"
                                                    @click="showInqAnswer = false">
                                                    닫기
                                                </button>

                                                <div class="inquiry-form">
                                                    <label for="answerContent">답변 내용</label>

                                                    <textarea id="answerContent" v-model="answerContent"
                                                        placeholder="문의에 대한 답변을 입력해 주세요." rows="5"></textarea>

                                                    <button type="button" class="inquiry-submit-btn"
                                                        @click="fnInqAnswerAdd">
                                                        답변 등록
                                                    </button>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- 관리자 답변 수정 모달 -->
                                        <div class="inquiry-write-modal" v-if="showInqAnswerEdit">
                                            <div class="inquiry-write-content">
                                                <button type="button" class="inquiry-close-btn"
                                                    @click="showInqAnswerEdit = false">
                                                    ×
                                                </button>

                                                <h3>답변 수정</h3>

                                                <div class="inquiry-form">
                                                    <textarea v-model="editAnswerContent" placeholder="답변 내용을 입력해 주세요.">
                                                    </textarea>
                                                </div>

                                                <button type="button" class="inquiry-submit-btn"
                                                    @click="fnInqAnswerEditSave">
                                                    수정하기
                                                </button>
                                            </div>
                                        </div>

                                    </div>

                                </div>

                                <!-- 페이지네이션 -->
                                <div class="inquiry-pagination" v-if="inquiryMaxPage > 1">

                                    <button type="button" @click="fnInqPage(inquiryPage - 1)"
                                        :disabled="inquiryPage === 1">
                                        이전
                                    </button>

                                    <button type="button" v-for="n in inquiryMaxPage" :key="n"
                                        :class="{ active: inquiryPage === n }" @click="fnInqPage(n)">
                                        {{ n }}
                                    </button>

                                    <button type="button" @click="fnInqPage(inquiryPage + 1)"
                                        :disabled="inquiryPage === inquiryMaxPage">
                                        다음
                                    </button>

                                </div>

                            </template>

                            <!-- 문의 작성 창 -->
                            <div class="inquiry-write-modal" v-if="showInqWrite">
                                <div class="inquiry-write-content">

                                    <h3>상품 문의 작성</h3>

                                    <button type="button" class="inquiry-close-btn" @click="fnInqWriteClose">
                                        닫기
                                    </button>

                                    <!-- 문의 내용 -->
                                    <div class="inquiry-form">
                                        <label for="inqContent">문의 내용</label>

                                        <textarea id="inqContent" v-model="inqContent"
                                            placeholder="상품에 대한 문의 내용을 입력해 주세요." rows="5">
                                        </textarea>

                                        <!-- 비밀 문의 -->
                                        <label class="inquiry-secret-check">
                                            <input type="checkbox" :checked="isSecret === 'Y'"
                                                @change="isSecret = $event.target.checked ? 'Y' : 'N'">
                                            비밀 문의로 작성
                                        </label>

                                        <!-- 등록 버튼 -->
                                        <button type="button" class="inquiry-submit-btn" @click="fnInqAdd">
                                            문의 등록
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- 문의 수정 모달 -->
                            <div class="inquiry-write-modal" v-if="showInqEdit">
                                <div class="inquiry-write-content">
                                    <h3>상품 문의 수정</h3>

                                    <button type="button" class="inquiry-close-btn" @click="showInqEdit = false">
                                        닫기
                                    </button>

                                    <div class="inquiry-form">
                                        <label for="editInqContent">문의 내용</label>

                                        <textarea id="editInqContent" v-model="editInqContent"
                                            placeholder="문의 내용을 입력해 주세요." rows="5"></textarea>

                                        <label class="inquiry-secret-check">
                                            <input type="checkbox" :checked="editIsSecret === 'Y'"
                                                @change="editIsSecret = $event.target.checked ? 'Y' : 'N'">
                                            비밀 문의로 작성
                                        </label>

                                        <button type="button" class="inquiry-submit-btn" @click="fnInqEditSave">
                                            수정 완료
                                        </button>
                                    </div>
                                </div>
                            </div>

                        </div>

                    </section>

                </main>

                <!-- 상품 조회 전 -->
                <div class="empty-message" v-else-if="isLoading">
                    상품 정보를 불러오는 중입니다.
                </div>

                <!-- 상품 조회 실패 -->
                <div class="empty-message" v-else>
                    상품 정보를 불러올 수 없습니다.
                </div>

            </div>

            <!-- 공통 푸터 -->
            <%@ include file="/WEB-INF/common/footer.jsp" %>

    </body>

    </html>

    <script>
        const app = Vue.createApp({

            data() {
                return {
                    isAdmin: "${sessionScope.sessionRole}" === "ADMIN",
                    isLogin: "${sessionScope.sessionId != null}",

                    productId: "${productId}",

                    info: {},

                    thumbnailUrl: "",

                    detailImageList: [],

                    selectedImageUrl: "",

                    quantity: 1,

                    selectedOptionPrice: 0,

                    deliveryFee: 3000,

                    isWished: false,

                    activeTab: "description",

                    isLoading: true,
                    // 리뷰 목록
                    reviewList: [],

                    // 리뷰 페이지
                    reviewPage: 1,
                    reviewLimit: 5,
                    reviewTotalCount: 0,
                    reviewMaxPage: 0,
                    // 선택한 별점 필터 (0이면 전체)
                    selectedRating: 0,

                    // 문의 목록
                    inquiryList: [],

                    // 문의 전체 개수
                    inquiryTotalCount: 0,

                    // 문의 답변 상태별 개수
                    inquiryAnsweredCount: 0,
                    inquiryWaitingCount: 0,

                    // 문의 상태 필터
                    selectedInqStatus: "ALL",

                    // 문의 페이지
                    inquiryPage: 1,
                    inquiryLimit: 5,
                    inquiryMaxPage: 0,

                    // 문의 작성 창 표시 여부
                    showInqWrite: false,

                    // 문의 작성
                    inqContent: "",
                    isSecret: "N",

                    // 문의 답변 작성
                    showInqAnswer: false,
                    answerInqId: "",
                    answerContent: "",

                    // 문의 수정
                    showInqEdit: false,
                    editInqId: "",
                    editInqContent: "",
                    editIsSecret: "N",

                    // 문의 답변 수정
                    showInqAnswerEdit: false,
                    editAnswerInqId: "",
                    editAnswerContent: "",
                };
            },

            computed: {

                // 배송비
                deliveryFee() {
                    let price = Number(this.info.price || 0)
                        + this.selectedOptionPrice;

                    let total = price * this.quantity;

                    return total >= 30000 ? 0 : 3000;
                },

                // 총 상품 금액
                totalPrice() {
                    let price = Number(this.info.price || 0);
                    return (price + this.selectedOptionPrice) * this.quantity + this.deliveryFee;
                },

                filteredReviewList: function () {
                    if (this.selectedRating === 0) {
                        return this.reviewList;
                    }

                    return this.reviewList.filter(function (review) {
                        return review.rating === this.selectedRating;
                    }, this);
                }

            },

            methods: {

                // 상품 정보 조회
                fnProductView: function () {
                    let self = this;

                    let param = {
                        productId: self.productId
                    };

                    $.ajax({
                        url: "view.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {

                            self.info = data.info || {};

                            let imageList = self.info.productImageList || [];

                            // 대표 이미지 조회
                            let thumbnail = imageList.find(function (image) {
                                return image.imageType === "THUMBNAIL";
                            });

                            // 상세 이미지 조회
                            self.detailImageList = imageList.filter(function (image) {
                                return image.imageType === "DETAIL";
                            });

                            self.thumbnailUrl = thumbnail ? thumbnail.imageUrl : "";

                            self.selectedImageUrl = self.thumbnailUrl;

                            self.isLoading = false;

                        },
                        error: function (xhr) {

                            console.log(xhr.responseText);

                            self.isLoading = false;

                            alert("상품 정보를 불러오지 못했습니다.");

                        }
                    });
                },

                // 이미지 선택
                fnSelectImage: function (imageUrl) {
                    this.selectedImageUrl = imageUrl;
                },

                // 수량 변경
                fnQuantityChange: function (amount) {

                    let maxQuantity = Number(this.info.stockQuantity) || 0;
                    let nextQuantity = this.quantity + amount;

                    if (nextQuantity < 1) {
                        return;
                    }

                    if (nextQuantity > maxQuantity) {
                        alert("재고 수량을 초과할 수 없습니다.");
                        return;
                    }

                    this.quantity = nextQuantity;

                },

                // 수량 직접 입력 확인
                fnQuantityCheck: function () {

                    let maxQuantity = Number(this.info.stockQuantity) || 0;

                    if (!this.quantity || this.quantity < 1) {
                        this.quantity = 1;
                    }

                    if (this.quantity > maxQuantity) {
                        alert("재고 수량을 초과할 수 없습니다.");
                        this.quantity = maxQuantity;
                    }

                },

                // 찜하기 및 찜 해제
                fnWishToggle: function () {
                    let self = this;

                    let param = {
                        productId: self.productId
                    };

                    $.ajax({
                        url: "/wishlist/toggle.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {

                            if (data.result == "success") {
                                self.isWished = data.wished;
                                alert(data.message);
                            } else {
                                alert(data.message);
                            }

                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                            alert("찜하기 처리 중 오류가 발생했습니다.");
                        }
                    });
                },

                // 장바구니 담기
                fnAddCart: function () {
                    let self = this;

                    if (!confirm("장바구니에 상품을 담으시겠습니까?")) {
                        return;
                    }

                    let param = {
                        productId: self.productId,
                        quantity: self.quantity
                    };

                    $.ajax({
                        url: "${pageContext.request.contextPath}/cart/add.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {

                            if (data.result === "success") {
                                alert(data.message);
                            } else {
                                alert(data.message || "장바구니 담기에 실패했습니다.");
                            }

                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                            alert("장바구니 담기 중 오류가 발생했습니다.");
                        }
                    });
                },

                // 구매하기
                fnBuy: function () {

                    if (!confirm("상품을 구매하시겠습니까?")) {
                        return;
                    }

                    let self = this;

                    $.ajax({
                        url: "${pageContext.request.contextPath}/order/direct-buy.dox",
                        type: "POST",
                        data: {
                            productId: self.productId,
                            quantity: self.quantity
                        },
                        dataType: "json",
                        success: function (data) {

                            if (data.result === "success") {
                                location.href = "${pageContext.request.contextPath}/order/checkout.do";
                            } else {
                                alert(data.message || "바로 구매 요청에 실패했습니다.");
                            }

                        },
                        error: function () {
                            alert("바로 구매 처리 중 오류가 발생했습니다.");
                        }
                    });

                },

                // 기존 찜 여부 조회
                fnWishCheck: function () {
                    let self = this;

                    let param = {
                        productId: self.productId
                    };

                    $.ajax({
                        url: "/wishlist/check.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {

                            if (data.result == "success") {
                                self.isWished = data.wished;
                            }

                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                        }
                    });
                },
                // 리뷰 탭 클릭
                fnReviewTab: function () {
                    this.activeTab = "review";
                    this.fnReviewList(1);
                },

                // 리뷰 목록 조회
                fnReviewList: function (page) {
                    let self = this;

                    let param = {
                        packageId: self.packageId,
                        page: page
                    };

                    $.ajax({
                        url: "${pageContext.request.contextPath}/review/list.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {

                            self.reviewList = data.reviewList || [];
                            self.reviewTotalCount = data.totalCount || 0;
                            self.reviewPage = page;
                            self.reviewMaxPage = Math.ceil(self.reviewTotalCount / self.reviewLimit);

                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                            alert("리뷰 목록을 불러오지 못했습니다.");
                        }
                    });
                },

                // 리뷰 페이지 변경
                fnReviewPage: function (page) {
                    if (page < 1 || page > this.reviewMaxPage) {
                        return;
                    }

                    this.fnReviewList(page);
                },

                // 문의 탭 클릭
                fnInqTab: function () {
                    this.activeTab = "inquiry";
                    this.fnInqList(1);
                },

                // 문의 목록 조회
                fnInqList: function (page) {
                    let self = this;

                    let param = {
                        productId: self.productId,
                        page: page,
                        inqStatus: self.selectedInqStatus,
                    };

                    $.ajax({
                        url: "${pageContext.request.contextPath}/productInq/list.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {

                            self.inquiryList = data.inquiryList || [];
                            self.inquiryTotalCount = data.totalCount || 0;
                            self.inquiryAnsweredCount = data.answeredCount || 0;
                            self.inquiryWaitingCount = data.waitingCount || 0;

                            self.inquiryPage = page;
                            self.inquiryMaxPage = Math.ceil(
                                (data.filteredCount || 0) / self.inquiryLimit
                            );

                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                            alert("문의 목록을 불러오지 못했습니다.");
                        }
                    });
                },
                // 문의 상태 필터 변경
                fnInqStatus: function (status) {
                    if (this.selectedInqStatus === status) {
                        return;
                    }

                    this.selectedInqStatus = status;
                    this.fnInqList(1);
                },

                // 문의 페이지 변경
                fnInqPage: function (page) {
                    if (page < 1 || page > this.inquiryMaxPage) {
                        return;
                    }

                    this.fnInqList(page);
                },

                // 상품 문의 등록
                fnInqAdd: function () {
                    let self = this;

                    if (!self.inqContent.trim()) {
                        alert("문의 내용을 입력해 주세요.");
                        return;
                    }

                    let param = {
                        productId: self.productId,
                        inqContent: self.inqContent,
                        isSecret: self.isSecret
                    };

                    $.ajax({
                        url: "${pageContext.request.contextPath}/productInq/add.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {

                            if (data.result === "success") {
                                alert("문의가 등록되었습니다.");

                                self.inqContent = "";
                                self.isSecret = "N";
                                self.showInqWrite = false;

                                self.selectedInqStatus = "ALL";
                                self.fnInqList(1);

                            } else {
                                alert("문의 등록에 실패했습니다.");
                            }
                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                            alert("문의 등록 중 오류가 발생했습니다.");
                        }
                    });
                },
                // 문의 작성 창 열기
                fnInqWrite: function () {

                    if (this.isLogin !== "true") {
                        alert("로그인 후 문의를 작성할 수 있습니다.");
                        return;
                    }

                    this.showInqWrite = true;
                },
                // 문의 작성 창 닫기
                fnInqWriteClose: function () {
                    this.showInqWrite = false;
                    this.inqContent = "";
                    this.isSecret = "N";
                },

                // 문의 답변 작성창 열기
                fnInqAnswerWrite: function (inquiry) {
                    this.answerInqId = inquiry.inqId;
                    this.answerContent = "";
                    this.showInqAnswer = true;
                },

                // 상품 문의 답변 등록
                fnInqAnswerAdd: function () {
                    let self = this;

                    if (!self.answerContent.trim()) {
                        alert("답변 내용을 입력해 주세요.");
                        return;
                    }

                    let param = {
                        inqId: self.answerInqId,
                        answerContent: self.answerContent
                    };

                    $.ajax({
                        url: "${pageContext.request.contextPath}/productInq/answer.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            if (data.result === "success") {
                                alert("답변이 등록되었습니다.");
                                self.showInqAnswer = false;
                                self.answerContent = "";
                                self.answerInqId = "";
                                self.fnInqList(self.inquiryPage);
                            } else {
                                alert(data.message || "답변 등록에 실패했습니다.");
                            }
                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                            alert("답변 등록 중 오류가 발생했습니다.");
                        }
                    });
                },

                // 문의 수정창 열기
                fnInqEdit: function (inquiry) {
                    this.editInqId = inquiry.inqId;
                    this.editInqContent = inquiry.inqContent;
                    this.editIsSecret = inquiry.isSecret;
                    this.showInqEdit = true;
                },

                // 상품 문의 수정
                fnInqEditSave: function () {
                    let self = this;

                    if (!self.editInqContent.trim()) {
                        alert("문의 내용을 입력해 주세요.");
                        return;
                    }

                    let param = {
                        inqId: self.editInqId,
                        inqContent: self.editInqContent,
                        isSecret: self.editIsSecret
                    };

                    $.ajax({
                        url: "${pageContext.request.contextPath}/productInq/edit.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            if (data.result === "success") {
                                alert("문의가 수정되었습니다.");
                                self.showInqEdit = false;
                                self.editInqId = "";
                                self.editInqContent = "";
                                self.editIsSecret = "N";
                                self.fnInqList(self.inquiryPage);
                            } else {
                                alert(data.message || "문의 수정에 실패했습니다.");
                            }
                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                            alert("문의 수정 중 오류가 발생했습니다.");
                        }
                    });
                },

                // 상품 문의 삭제
                fnInqDelete: function (inqId) {
                    let self = this;

                    if (!confirm("문의를 삭제하시겠습니까?")) {
                        return;
                    }

                    $.ajax({
                        url: "${pageContext.request.contextPath}/productInq/remove.dox",
                        dataType: "json",
                        type: "POST",
                        data: {
                            inqId: inqId
                        },
                        success: function (data) {
                            if (data.result === "success") {
                                alert("문의가 삭제되었습니다.");
                                self.fnInqList(self.inquiryPage);
                            } else {
                                alert(data.message || "문의 삭제에 실패했습니다.");
                            }
                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                            alert("문의 삭제 중 오류가 발생했습니다.");
                        }
                    });
                },

                // 관리자 답변 수정창 열기
                fnInqAnswerEdit: function (inquiry) {
                    this.editAnswerInqId = inquiry.inqId;
                    this.editAnswerContent = inquiry.answerContent;
                    this.showInqAnswerEdit = true;
                },

                // 상품 문의 답변 수정
                fnInqAnswerEditSave: function () {
                    let self = this;

                    if (!self.editAnswerContent.trim()) {
                        alert("답변 내용을 입력해 주세요.");
                        return;
                    }

                    let param = {
                        inqId: self.editAnswerInqId,
                        answerContent: self.editAnswerContent
                    };

                    $.ajax({
                        url: "${pageContext.request.contextPath}/productInq/answerEdit.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            if (data.result === "success") {
                                alert("답변이 수정되었습니다.");
                                self.showInqAnswerEdit = false;
                                self.editAnswerInqId = "";
                                self.editAnswerContent = "";
                                self.fnInqList(self.inquiryPage);
                            } else {
                                alert(data.message || "답변 수정에 실패했습니다.");
                            }
                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                            alert("답변 수정 중 오류가 발생했습니다.");
                        }
                    });
                },

                // 관리자 답변 삭제
                fnInqAnswerDelete: function (inqId) {
                    let self = this;

                    if (!confirm("관리자 답변을 삭제하시겠습니까?")) {
                        return;
                    }

                    $.ajax({
                        url: "${pageContext.request.contextPath}/productInq/answerRemove.dox",
                        dataType: "json",
                        type: "POST",
                        data: {
                            inqId: inqId
                        },
                        success: function (data) {
                            if (data.result === "success") {
                                alert("답변이 삭제되었습니다.");
                                self.fnInqList(self.inquiryPage);
                            } else {
                                alert(data.message || "답변 삭제에 실패했습니다.");
                            }
                        },
                        error: function (xhr) {
                            console.log(xhr.responseText);
                            alert("답변 삭제 중 오류가 발생했습니다.");
                        }
                    });
                },

            },

            mounted() {

                let self = this;

                self.fnProductView();
                self.fnWishCheck();

            }

        });

        app.mount("#app");
    </script>