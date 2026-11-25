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

                            <button type="button" :class="{ active: activeTab === 'inquiry' }"
                                @click="activeTab = 'inquiry'">
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
                        <div class="empty-message tab-empty" v-else>
                            등록된 문의가 없습니다.
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

            },

            mounted() {

                let self = this;

                self.fnProductView();
                self.fnWishCheck();

            }

        });

        app.mount("#app");
    </script>