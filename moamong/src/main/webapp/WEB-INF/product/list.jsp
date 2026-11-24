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

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product/list.css">
    </head>

    <body>


        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>

            <div id="app">

                <!-- 페이지 제목 -->
                <div class="page-title">
                    <h2>단품</h2>
                </div>

                <!-- 대분류 메뉴 -->
                <div class="main-category">
                    <button v-for="category in mainCategoryList" :key="category.categoryId"
                        :class="{ active: categoryId == category.categoryId }"
                        @click="categoryId = category.categoryId; fnList()">
                        {{ category.categoryName }}
                    </button>
                </div>

                <!-- 소분류별 상품 영역 -->
                <div class="sub-category-list">
                    <div class="sub-category" v-for="subCategory in subCategoryList" :key="subCategory.categoryId">

                        <div class="sub-category-header">
                            <h3>{{ subCategory.categoryName }}</h3>

                            <button class="more-button" @click="fnSubCategoryList(subCategory.categoryId)">
                                더 보기
                            </button>
                        </div>

                        <div class="product-list">
                            <div class="product-item"
                                v-for="product in productList.filter(item => item.categoryId == subCategory.categoryId)"
                                :key="product.productId" @click="fnProductView(product.productId)">

                                <img :src="product.thumbnailUrl || '/images/no-image.png'" :alt="product.productName">

                                <div class="product-info">
                                    <p>{{ product.productName }}</p>
                                </div>

                            </div>
                        </div>

                    </div>
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
                    categoryId: 1,
                    mainCategoryList: [],
                    subCategoryList: [],
                    productList: []

                };
            },
            methods: {
                fnList: function () {
                    let self = this;
                    let param = {
                        categoryId: self.categoryId
                    };
                    $.ajax({
                        url: "list.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            self.mainCategoryList = data.mainCategoryList;
                            self.subCategoryList = data.subCategoryList;
                            self.productList = data.productList;
                        }
                    });
                },
                fnSubCategoryList: function (categoryId) {
                    location.href = "subList.do?categoryId=" + categoryId;
                },
                fnProductView: function (productId) {
                    location.href = "view.do?productId=" + productId;
                }
            }, // methods
            mounted() {
                let self = this;
                self.fnList();
            }
        });

        app.mount('#app');
    </script>