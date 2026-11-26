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

        <script src="${pageContext.request.contextPath}/js/page-change.js"></script>

        <!-- 공통 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">

        <!-- 패키지 상세 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/package/view.css">
    </head>

    <body>

        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>

            <div id="app">

                <main class="product-container" v-if="info.packageName">

                    <!-- 패키지명 -->
                    <section class="product-heading">
                        <h2>{{ info.packageName }}</h2>
                    </section>

                    <!-- 패키지 구매 영역 -->
                    <section class="product-main">

                        <!-- 패키지 대표 이미지 -->
                        <div class="product-gallery">

                            <div class="main-image">
                                <img v-if="selectedImageUrl" :src="selectedImageUrl" :alt="info.packageName">

                                <div v-else class="empty-image">
                                    등록된 패키지 이미지가 없습니다.
                                </div>
                            </div>

                        </div>

                        <!-- 패키지 정보 -->
                        <div class="product-info">

                            <div class="product-title-area">
                                <div>
                                    <h2>{{ info.packageName }}</h2>
                                    <p class="product-category">
                                        모아몽 패키지 · 특별한 순간을 위한 선물
                                    </p>
                                </div>

                                <button type="button" class="wish-btn" :class="{ active: isWished }"
                                    @click="fnWishToggle" :title="isWished ? '찜 해제' : '찜하기'">

                                    {{ isWished ? '♥' : '♡' }}

                                </button>
                            </div>

                            <p class="product-price">
                                {{ Number(info.packagePrice || 0).toLocaleString() }}원
                            </p>

                            <div class="product-benefit">

                                <div class="info-line">
                                    <strong>등급</strong>
                                    <span>{{ packageGradeName }}</span>
                                </div>

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
                                    <strong>배송</strong>
                                    <span>택배 배송</span>
                                </div>

                            </div>

                        </div>

                    </section>

                    <!-- 패키지 구매 및 금액 영역 -->
                    <section class="purchase-section">

                        <!-- 패키지 구성 상품 선택 -->
                        <div class="package-item-select">
                            <h3>패키지 구성 상품 선택</h3>

                            <div v-for="item in packageItems" :key="item.packageItemId">
                                <label>
                                    {{ item.productName }}
                                    <span v-if="item.itemRole === 'MAIN'">(메인 상품)</span>
                                    <span v-else>(구성 상품)</span>
                                </label>

                                <select v-model="selectedPackageItems[item.packageItemId]">
                                    <option :value="item.productId">
                                        {{ item.productName }} (기본)
                                    </option>

                                    <option
                                        v-for="option in packageItemOptions.filter(option => option.packageItemId === item.packageItemId)"
                                        :key="option.packageItemOptionId" :value="option.optionProductId">
                                        {{ option.productName }}
                                        ({{ Number(option.additionalPrice) > 0 ? '+' : '' }}{{
                                        Number(option.additionalPrice).toLocaleString() }}원)
                                    </option>
                                </select>
                            </div>
                        </div>

                        <!-- 패키지 추가 옵션 선택 -->
                        <div class="package-extra-select">
                            <h3>추가 옵션 선택</h3>

                            <div v-for="extra in packageExtras" :key="extra.packageExtraId">
                                <label>{{ extra.extraName }}</label>

                                <select v-model="selectedPackageExtras[extra.packageExtraId]">
                                    <option
                                        v-for="option in packageExtraOptions.filter(option => option.packageExtraId === extra.packageExtraId)"
                                        :key="option.packageExtraOptionId" :value="option.packageExtraOptionId">
                                        {{ option.optionName }}
                                        <span v-if="Number(option.additionalPrice) > 0">
                                            (+{{ Number(option.additionalPrice).toLocaleString() }}원)
                                        </span>
                                        <span v-else>(추가 금액 없음)</span>
                                    </option>
                                </select>
                            </div>
                        </div>

                        <div class="purchase-product">
                            <span>
                                <strong>구매 상품 :</strong>
                                {{ info.packageName }}
                            </span>

                            <div class="quantity-control">
                                <button type="button" @click="fnQuantityChange(-1)">-</button>

                                <input type="number" v-model.number="quantity" min="1" @change="fnQuantityCheck">

                                <button type="button" @click="fnQuantityChange(1)">+</button>
                            </div>
                        </div>

                        <div class="purchase-buttons">

                            <button type="button" class="cart-btn" @click="fnAddCart"
                                :disabled="info.packageStatus !== 'SELLING'">
                                장바구니
                            </button>

                            <button type="button" class="buy-btn" :disabled="info.packageStatus !== 'SELLING'"
                                @click="fnBuy">
                                구매하기
                            </button>

                        </div>

                        <div class="purchase-total">

                            <div>
                                <strong>배송비 :</strong>
                                {{ deliveryFee.toLocaleString() }}원(3만원 이상 무료배송)
                            </div>

                            <div class="total-price">
                                <strong>총 금액 :</strong>
                                <span>{{ totalPrice.toLocaleString() }}원</span>
                            </div>

                        </div>

                    </section>

                    <!-- 패키지 상세 탭 -->
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

                        <!-- 패키지 상세 설명 -->
                        <div class="detail-content" v-show="activeTab === 'description'">

                            <div v-if="info.packageDescription" class="description-content"
                                v-html="info.packageDescription">
                            </div>

                            <div v-else class="empty-message">
                                등록된 패키지 상세 설명이 없습니다.
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
                        <%@ include file="/WEB-INF/review/review.jsp" %>

                            <!-- 문의 -->
                            <%@ include file="/WEB-INF/productInq/productInq.jsp" %>

                    </section>

                </main>

                <!-- 패키지 조회 전 -->
                <div class="empty-message" v-else-if="isLoading">
                    패키지 정보를 불러오는 중입니다.
                </div>

                <!-- 패키지 조회 실패 -->
                <div class="empty-message" v-else>
                    패키지 정보를 불러올 수 없습니다.
                </div>

            </div>

            <!-- 공통 푸터 -->
            <%@ include file="/WEB-INF/common/footer.jsp" %>


    </body>

    </html>
    <script>
        window.contextPath = "${pageContext.request.contextPath}";
    </script>

    <script src="${pageContext.request.contextPath}/js/review/review.js"></script>
    <script src="${pageContext.request.contextPath}/js/productInq/productInq.js"></script>
    <script>
        console.log("세션 ID:", "${sessionScope.sessionId}");
        const app = Vue.createApp({

            mixins: [
                window.reviewMixin,
                window.inquiryMixin
            ],

            data() {
                return {
                    isAdmin: "${sessionScope.sessionRole}" === "ADMIN",
                    isLogin: "${sessionScope.sessionId != null}",
                    
                    packageId: "${packageId}",

                    info: {},

                    selectedImageUrl: "",

                    // 패키지 구성 상품 선택 목록
                    packageItems: [],
                    packageItemOptions: [],

                    // 패키지 추가 옵션 선택 목록
                    packageExtras: [],
                    packageExtraOptions: [],

                    // 구성 상품별 선택한 상품 ID
                    selectedPackageItems: {},
                    // 추가 옵션별 선택한 옵션 ID
                    selectedPackageExtras: {},

                    quantity: 1,


                    isWished: false,

                    activeTab: "description",

                    isLoading: true,

                };
            },

            computed: {
                // 배송비
                deliveryFee() {
                    let price = Number(this.info.packagePrice || 0);

                    // 구성 상품 교체 추가 금액
                    this.packageItems.forEach(function (item) {
                        let selectedProductId = this.selectedPackageItems[item.packageItemId];

                        let option = this.packageItemOptions.find(function (option) {
                            return option.packageItemId == item.packageItemId
                                && option.optionProductId == selectedProductId;
                        });

                        if (option) {
                            price += Number(option.additionalPrice || 0);
                        }
                    }, this);

                    // 패키지 추가 옵션 금액
                    this.packageExtras.forEach(function (extra) {
                        let selectedOptionId = this.selectedPackageExtras[extra.packageExtraId];

                        let option = this.packageExtraOptions.find(function (option) {
                            return option.packageExtraOptionId == selectedOptionId;
                        });

                        if (option) {
                            price += Number(option.additionalPrice || 0);
                        }
                    }, this);

                    // 수량 반영 후 무료배송 여부 판단
                    return price * this.quantity >= 30000 ? 0 : 3000;
                },

                // 등급 이름
                packageGradeName() {

                    let gradeNameList = {
                        BASIC: "Basic",
                        STANDARD: "Standard",
                        PREMIUM: "Premium",
                        LUXURY: "Luxury"
                    };

                    return gradeNameList[this.info.packageGrade] || "";
                },

                // 총 금액
                totalPrice() {
                    let price = Number(this.info.packagePrice || 0);

                    // 구성 상품 교체에 따른 추가 금액
                    this.packageItems.forEach(function (item) {
                        let selectedProductId = this.selectedPackageItems[item.packageItemId];

                        let option = this.packageItemOptions.find(function (option) {
                            return option.packageItemId == item.packageItemId
                                && option.optionProductId == selectedProductId;
                        });

                        if (option) {
                            price += Number(option.additionalPrice || 0);
                        }
                    }, this);

                    // 패키지 추가 옵션 금액
                    this.packageExtras.forEach(function (extra) {
                        let selectedOptionId = this.selectedPackageExtras[extra.packageExtraId];

                        let option = this.packageExtraOptions.find(function (option) {
                            return option.packageExtraOptionId == selectedOptionId;
                        });

                        if (option) {
                            price += Number(option.additionalPrice || 0);
                        }
                    }, this);

                    return (price * this.quantity) + this.deliveryFee;
                },

            },

            methods: {

                // 패키지 정보 조회
                fnPackageView: function () {
                    let self = this;

                    let param = {
                        packageId: self.packageId
                    };

                    $.ajax({
                        url: "view.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {

                            self.info = data.info || {};

                            // 패키지 구성 상품 목록
                            self.packageItems = data.packageItemList || [];
                            // 각 구성 상품의 기본 상품을 최초 선택값으로 설정
                            self.packageItems.forEach(function (item) {
                                self.selectedPackageItems[item.packageItemId] = item.productId;
                            });

                            // 패키지 구성 상품 교체 옵션 목록
                            self.packageItemOptions = data.packageItemOptionList || [];

                            // 패키지 추가 구성 유형 목록
                            self.packageExtras = data.packageExtraList || [];

                            // 패키지 추가 구성 옵션 목록
                            self.packageExtraOptions = data.packageExtraOptionList || [];
                            // 추가 옵션별 첫 번째 옵션을 기본 선택값으로 설정
                            self.packageExtras.forEach(function (extra) {
                                let option = self.packageExtraOptions.find(function (item) {
                                    return item.packageExtraId === extra.packageExtraId;
                                });

                                if (option) {
                                    self.selectedPackageExtras[extra.packageExtraId] = option.packageExtraOptionId;
                                }
                            });

                            self.selectedImageUrl = self.info.thumbnailUrl || "";

                            self.isLoading = false;

                        },
                        error: function (xhr) {

                            console.log(xhr.responseText);

                            self.isLoading = false;

                            alert("패키지 정보를 불러오지 못했습니다.");

                        }
                    });
                },

                // 수량 변경
                fnQuantityChange: function (amount) {

                    let nextQuantity = this.quantity + amount;

                    if (nextQuantity < 1) {
                        return;
                    }

                    this.quantity = nextQuantity;

                },

                // 수량 직접 입력 확인
                fnQuantityCheck: function () {

                    if (!this.quantity || this.quantity < 1) {
                        this.quantity = 1;
                    }

                },

                // 찜하기 및 찜 해제
                fnWishToggle: function () {
                    let self = this;

                    let param = {
                        packageId: self.packageId
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

                    if (!confirm("장바구니에 패키지를 담으시겠습니까?")) {
                        return;
                    }

                    // 패키지 구성 상품 선택 정보
                    let packageItems = self.packageItems.map(function (item) {
                        return {
                            packageItemId: item.packageItemId,
                            selectedProductId: self.selectedPackageItems[item.packageItemId]
                        };
                    });

                    // 패키지 추가 옵션 선택 정보
                    let packageExtras = self.packageExtras.map(function (extra) {
                        return {
                            packageExtraOptionId: self.selectedPackageExtras[extra.packageExtraId]
                        };
                    });

                    // 서버 전송 데이터
                    let param = {
                        packageId: self.packageId,
                        quantity: self.quantity,
                        packageItems: packageItems,
                        packageExtras: packageExtras
                    };

                    $.ajax({
                        url: "${pageContext.request.contextPath}/cart/add-json.dox",
                        dataType: "json",
                        type: "POST",
                        contentType: "application/json",
                        data: JSON.stringify(param),
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

                    if (!confirm("패키지를 구매하시겠습니까?")) {
                        return;
                    }

                    let self = this;

                    $.ajax({
                        url: "${pageContext.request.contextPath}/order/direct-buy-json.dox",
                        type: "POST",
                        contentType: "application/json",
                        data: JSON.stringify({
                            packageId: self.packageId,
                            quantity: self.quantity,

                            packageItems: self.packageItems.map(function (item) {
                                return {
                                    packageItemId: item.packageItemId,
                                    selectedProductId: self.selectedPackageItems[item.packageItemId]
                                };
                            }),

                            packageExtras: self.packageExtras.map(function (extra) {
                                return {
                                    packageExtraOptionId: self.selectedPackageExtras[extra.packageExtraId]
                                };
                            })
                        }),
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
                        packageId: self.packageId
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


            },

            mounted() {

                let self = this;

                self.fnPackageView();
                self.fnWishCheck();

            }

        });

        app.mount("#app");
    </script>