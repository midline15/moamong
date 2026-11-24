
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>모아몽</title>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4="
        crossorigin="anonymous"></script>

    <!-- Vue -->
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

    <script src="/js/page-change.js"></script>

    <!-- 공통 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            color: #222;
            font-family: Arial, sans-serif;
        }

        /* 상품 목록 영역 */
        .product-container {
            width: 100%;
            max-width: 1200px;
            margin: 30px auto 60px;
            padding: 0 30px;
        }

        /* 상품 목록 제목 및 정렬 */
        .product-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 1px solid #eee;
        }

        .product-title {
            margin: 0;
            font-size: 24px;
            font-weight: 700;
        }

        .sort-area {
            display: flex;
            gap: 10px;
        }

        .sort-btn {
            padding: 5px 0;
            border: none;
            background: none;
            color: #555;
            font-size: 12px;
            cursor: pointer;
        }

        .sort-btn.active {
            color: #222;
            font-weight: bold;
        }

        /* 상품 그리드 */
        .product-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            column-gap: 50px;
            row-gap: 30px;
        }

        /* 상품 카드 */
        .product-card {
            min-width: 0;
            cursor: pointer;
        }

        .product-image {
            width: 100%;
            aspect-ratio: 4 / 3;
            background-color: #d9d9d9;
            overflow: hidden;
        }

        .product-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .product-name {
            margin: 7px 0 3px;
            font-size: 14px;
            font-weight: 600;
        }

        .product-description {
            margin: 0;
            color: #555;
            font-size: 12px;
            line-height: 1.5;
        }

        .empty-message {
            grid-column: 1 / -1;
            padding: 80px 0;
            text-align: center;
            color: #888;
        }

        /* 페이지네이션 */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin-top: 35px;
        }

        .page-btn {
            padding: 5px;
            border: none;
            background: none;
            color: #555;
            font-size: 12px;
            cursor: pointer;
        }

        .page-btn.active {
            color: #e76f8a;
            font-weight: bold;
        }

        .page-btn:disabled {
            color: #ccc;
            cursor: default;
        }

        @media (max-width: 768px) {
            .product-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 25px 15px;
            }

            .product-container {
                padding: 0 16px;
            }
        }

        @media (max-width: 480px) {
            .product-grid {
                grid-template-columns: 1fr;
            }

            .product-header {
                align-items: flex-start;
                flex-direction: column;
                gap: 12px;
            }
        }
    </style>
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
                    <button class="sort-btn"
                        :class="{ active: sortType === 'latest' }"
                        @click="fnSort('latest')">
                        최신순
                    </button>

                    <button class="sort-btn"
                        :class="{ active: sortType === 'price' }"
                        @click="fnSort('price')">
                        가격순
                    </button>

                    <button class="sort-btn"
                        :class="{ active: sortType === 'popular' }"
                        @click="fnSort('popular')">
                        인기순
                    </button>
                </div>
            </div>

            <!-- 상품 카드 -->
            <div class="product-grid">

                <div class="product-card"
                    v-for="product in productList"
                    :key="product.productId"
                    @click="fnProductView(product.productId)">

                    <div class="product-image">
                        <img v-if="product.thumbnailUrl"
                            :src="product.thumbnailUrl"
                            :alt="product.productName">

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

                <button class="page-btn"
                    @click="fnChangePage(1)"
                    :disabled="page === 1">
                    «
                </button>

                <button class="page-btn"
                    @click="fnChangePage(page - 1)"
                    :disabled="page === 1">
                    ‹
                </button>

                <button class="page-btn"
                    v-for="n in maxPage"
                    :key="n"
                    :class="{ active: page === n }"
                    @click="fnChangePage(n)">
                    {{ n }}
                </button>

                <button class="page-btn"
                    @click="fnChangePage(page + 1)"
                    :disabled="page === maxPage">
                    ›
                </button>

                <button class="page-btn"
                    @click="fnChangePage(maxPage)"
                    :disabled="page === maxPage">
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
