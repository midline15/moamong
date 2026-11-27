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
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product/subList.css">

    </head>

    <body>

        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>

            <!-- 상품 목록 -->
            <div id="app">
                <main class="product-container">

                    <!-- 제목 및 정렬 -->
                    <div class="product-header">
                        <h2 class="product-title">{{ categoryName }}</h2>

                        <div class="sort-area">
                            <button class="sort-btn" :class="{ active: sortType === 'latest' }"
                                @click="fnSort('latest')">
                                최신순
                            </button>

                            <button class="sort-btn" :class="{ active: sortType === 'price' }" @click="fnSort('price')">
                                가격순
                            </button>

                            <button class="sort-btn" :class="{ active: sortType === 'popular' }"
                                @click="fnSort('popular')">
                                인기순
                            </button>
                        </div>
                    </div>

                    <!-- 상품 카드 -->
                    <div class="product-grid">

                        <div class="product-card" v-for="product in productList" :key="product.productId"
                            @click="fnProductView(product.productId)">

                            <div class="product-image">
                                <img v-if="product.thumbnailUrl" :src="product.thumbnailUrl" :alt="product.productName">

                            </div>

                            <p class="product-name">
                                {{ product.productName }}
                            </p>

                            <p class="product-description">
                                {{ product.productDescription }}
                            </p>

                        </div>

                        <div class="empty-message" v-if="productList.length === 0">
                            등록된 상품이 없습니다.
                        </div>

                    </div>

                    <!-- 페이지네이션 -->
                    <div class="pagination" v-if="maxPage > 0">

                        <button class="page-btn" @click="fnChangePage(1)" :disabled="page === 1">
                            «
                        </button>

                        <button class="page-btn" @click="fnChangePage(page - 1)" :disabled="page === 1">
                            ‹
                        </button>

                        <button class="page-btn" v-for="n in maxPage" :key="n" :class="{ active: page === n }"
                            @click="fnChangePage(n)">
                            {{ n }}
                        </button>

                        <button class="page-btn" @click="fnChangePage(page + 1)" :disabled="page === maxPage">
                            ›
                        </button>

                        <button class="page-btn" @click="fnChangePage(maxPage)" :disabled="page === maxPage">
                            »
                        </button>

                    </div>

                </main>
            </div>

            <!-- 공통 푸터 -->
            <%@ include file="/WEB-INF/common/footer.jsp" %>

    </body>

    </html>

    <script>
        const app = Vue.createApp({
            data() {
                return {
                    categoryId: "${categoryId}",
                    categoryName: "${categoryName}",

                    page: 1,
                    limit: 9,
                    offset: 0,
                    maxPage: 0,

                    productList: [],

                    sortType: "latest",
                    priceSortOrder: "ASC"
                };
            },
            methods: {
                fnSubProductList: function () {
                    let self = this;

                    let param = {
                        categoryId: self.categoryId,
                        limit: self.limit,
                        offset: self.offset,
                        sortType: self.sortType,
                        priceSortOrder: self.priceSortOrder
                    };

                    $.ajax({
                        url: "subList.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            self.productList = data.productList;
                            self.maxPage = Math.ceil(data.totalCount / self.limit);
                        }
                    });
                },
                fnChangePage: function (page) {
                    if (page < 1 || page > this.maxPage) {
                        return;
                    }

                    this.page = page;
                    this.offset = (page - 1) * this.limit;
                    this.fnSubProductList();
                },
                fnProductView: function (productId) {
                    location.href = "view.do?productId=" + productId;
                },
                fnSort: function (type) {
                    if (type === "price") {
                        if (this.sortType === "price") {
                            this.priceSortOrder =
                                this.priceSortOrder === "ASC" ? "DESC" : "ASC";
                        } else {
                            this.priceSortOrder = "ASC";
                        }
                    }

                    this.sortType = type;
                    this.page = 1;
                    this.offset = 0;

                    this.fnSubProductList();
                }
            },
            mounted() {
                this.fnSubProductList();
            }
        });

        app.mount('#app');
    </script>