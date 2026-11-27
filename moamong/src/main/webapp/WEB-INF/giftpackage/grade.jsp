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
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/package/list.css">
    </head>

    <body>

        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>

            <div id="app">

                <!-- 상단 배너 -->
                <div class="page-banner">
                    <img src="${pageContext.request.contextPath}/assets/banner/giftPackageBanner.png" alt="모아몽 선물 패키지">
                </div>
                <h2 class="grade-title">{{ packageGradeName }} 패키지</h2>

                <!-- 패키지 목록 -->
                <div class="package-list">

                    <div class="package-item" v-for="item in packageList" :key="item.packageId"
                        @click="fnPackageView(item.packageId)">

                        <img :src="item.thumbnailUrl || '/images/no-image.png'" :alt="item.packageName">

                        <div class="package-info">
                            <p>{{ item.packageName }}</p>
                        </div>

                    </div>

                </div>

                <!-- 페이지네이션 -->
                <div class="pagination" v-if="maxPage > 0">

                    <button @click="fnChangePage(1)" :disabled="page == 1">
                        처음
                    </button>

                    <button @click="fnChangePage(page - 1)" :disabled="page == 1">
                        이전
                    </button>

                    <button v-for="n in maxPage" :key="n" :class="{ active: page == n }" @click="fnChangePage(n)">
                        {{ n }}
                    </button>

                    <button @click="fnChangePage(page + 1)" :disabled="page == maxPage">
                        다음
                    </button>

                    <button @click="fnChangePage(maxPage)" :disabled="page == maxPage">
                        마지막
                    </button>

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
                    packageGrade: "${packageGrade}",
                    packageGradeName: "",
                    packageList: [],

                    page: 1,
                    limit: 9,
                    offset: 0,
                    maxPage: 0,
                    totalCount: 0
                };
            },

            methods: {
                // 패키지 등급별 목록 조회
                fnList: function () {
                    let self = this;

                    let param = {
                        packageGrade: self.packageGrade,
                        page: self.page
                    };

                    $.ajax({
                        url: "grade.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            self.packageList = data.packageList;
                            self.totalCount = data.totalCount;
                            self.maxPage = Math.ceil(self.totalCount / self.limit);
                        }
                    });
                },
                // 페이지 변경
                fnChangePage: function (page) {

                    if (page < 1 || page > this.maxPage) {
                        return;
                    }

                    this.page = page;
                    this.offset = (page - 1) * this.limit;

                    this.fnList();
                },

                // 패키지 상세 조회
                fnPackageView: function (packageId) {
                    location.href = "view.do?packageId=" + packageId;
                }

            },

            mounted() {
                let self = this;

                let gradeNameList = {
                    BASIC: "Basic",
                    STANDARD: "Standard",
                    PREMIUM: "Premium",
                    LUXURY: "Luxury"
                };

                self.packageGradeName = gradeNameList[self.packageGrade];

                self.fnList();
            }
        });

        app.mount('#app');
    </script>