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
                <h2 class="sr-only">패키지</h2>

                <!-- 대상/ 목적 카테고리 -->
                <div class="main-category">
                    <!-- 대상 카테고리 -->
                    <button v-for="item in targetCategoryList" :key="item.code"
                        :class="{ active: selectedCategory == item.code }" @click="fnCategorySelect(item.code)">
                        {{ item.name }}
                    </button>

                    <!-- 목적 카테고리 -->
                    <button v-for="item in purposeCategoryList" :key="item.code"
                        :class="{ active: selectedCategory == item.code }" @click="fnCategorySelect(item.code)">
                        {{ item.name }}
                    </button>
                </div>

                <!-- 패키지 목록 영역 -->
                <template v-for="grade in packageGradeList" :key="grade.code">

                    <div class="package-section" v-if="fnGradeList(grade.code).length > 0">

                        <!-- 등급 제목 및 더보기 -->
                        <div class="sub-category-header">
                            <h3>{{ grade.name }}</h3>

                            <button class="more-button" @click="fnGradeMore(grade.code)">
                                더보기
                            </button>
                        </div>

                        <!-- 등급별 패키지 목록 -->
                        <div class="package-list">

                            <div class="package-item" v-for="item in fnGradeList(grade.code)" :key="item.packageId"
                                @click="fnPackageView(item.packageId)">

                                <img :src="item.thumbnailUrl || '/images/no-image.png'" :alt="item.packageName">

                                <div class="package-info">
                                    <p>{{ item.packageName }}</p>
                                </div>

                            </div>

                        </div>

                    </div>

                </template>

            </div>

            <!-- 공통 푸터 -->
            <%@ include file="/WEB-INF/common/footer.jsp" %>

                <script>
                    const app = Vue.createApp({
                        data() {
                            return {
                                selectedCategory: "FAMILY",
                                targetType: "FAMILY",
                                purposeType: "",

                                targetCategoryList: [
                                    { code: "FAMILY", name: "가족" },
                                    { code: "COUPLE", name: "연인" },
                                    { code: "FRIEND", name: "친구" },
                                    { code: "COLLEAGUE", name: "동료" },
                                    { code: "SELF", name: "나에게" }
                                ],

                                purposeCategoryList: [
                                    { code: "BIRTHDAY_ANNIVERSARY", name: "생일·기념일" },
                                    { code: "THANKS", name: "감사·답례" },
                                    { code: "CONGRATULATIONS", name: "축하·응원" },
                                    { code: "COMFORT", name: "위로·격려" },
                                    { code: "HEART", name: "마음전달" }
                                ],

                                packageGradeList: [
                                    { code: "BASIC", name: "Basic" },
                                    { code: "STANDARD", name: "Standard" },
                                    { code: "PREMIUM", name: "Premium" },
                                    { code: "LUXURY", name: "Luxury" }
                                ],

                                packageList: []
                            };
                        },

                        methods: {
                            // 대상 / 목적 카테고리 선택
                            fnCategorySelect: function (code) {
                                if (this.selectedCategory === code) {
                                    return;
                                }

                                this.selectedCategory = code;

                                if (this.targetCategoryList.some(item => item.code === code)) {
                                    this.targetType = code;
                                    this.purposeType = "";
                                } else {
                                    this.targetType = "";
                                    this.purposeType = code;
                                }

                                this.fnList();
                            },

                            // 패키지 목록 조회
                            fnList: function () {
                                let self = this;

                                let param = {
                                    targetType: self.targetType,
                                    purposeType: self.purposeType
                                };

                                $.ajax({
                                    url: "list.dox",
                                    dataType: "json",
                                    type: "POST",
                                    data: param,
                                    success: function (data) {
                                        self.packageList = data.packageList;
                                    }
                                });
                            },

                            // 등급별 패키지 목록 조회
                            fnGradeList: function (packageGrade) {
                                return this.packageList
                                    .filter(item => item.packageGrade == packageGrade)
                                    .slice(0, 5);
                            },

                            // 등급별 더보기
                            fnGradeMore: function (packageGrade) {
                                location.href = "grade.do?packageGrade=" + packageGrade;
                            },

                            // 패키지 상세 조회
                            fnPackageView: function (packageId) {
                                location.href = "view.do?packageId=" + packageId;
                            }

                        },

                        mounted() {
                            const params = new URLSearchParams(window.location.search);
                            const qTarget = (params.get("target") || "").trim();
                            const qPurpose = (params.get("purpose") || "").trim();

                            // 한글명·가운뎃점(ㆍ vs ·)·영문코드 모두 매칭
                            const normalize = (s) => s.replace(/[ㆍ·\s]/g, "");

                            if (qTarget) {
                                const found = this.targetCategoryList.find(
                                    item => item.code === qTarget || normalize(item.name) === normalize(qTarget)
                                );
                                if (found) {
                                    this.selectedCategory = found.code;
                                    this.targetType = found.code;
                                    this.purposeType = "";
                                }
                            } else if (qPurpose) {
                                const found = this.purposeCategoryList.find(
                                    item => item.code === qPurpose || normalize(item.name) === normalize(qPurpose)
                                );
                                if (found) {
                                    this.selectedCategory = found.code;
                                    this.targetType = "";
                                    this.purposeType = found.code;
                                }
                            }

                            this.fnList();
                        }

                    });

                    app.mount('#app');
                </script>

    </body>

    </html>