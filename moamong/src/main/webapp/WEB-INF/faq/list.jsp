<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>자주 묻는 질문</title>

        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.js"
            integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>

        <!-- Vue -->
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

        <script src="/js/page-change.js"></script>

        <!-- 공통 헤더 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">

        <!-- 헤더 햄버거 사이드바 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">

        <!-- 공통 푸터 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">

        <!-- 고객센터 본문 공통 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/notice/list.css">

        <!-- 고객센터 왼쪽 메뉴 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cs-sidebar.css">

        <!-- FAQ 전용 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/faq/faq.css">

    </head>

    <body>

        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>
            <!-- 공통 사이드바 -->
            <%@ include file="/WEB-INF/common/sidebar.jsp" %>

                <!-- 자주 묻는 질문 영역 -->
                <div id="app">
                    <div class="cs-wrap">

                        <% request.setAttribute("csMenu", "faq" ); %>
                            <%@ include file="/WEB-INF/common/cs-side.jsp" %>

                                <!-- 우측 본문 -->
                                <section class="cs-content">

                                    <!-- 제목 / 경로 -->
                                    <div class="cs-title-area">
                                        <h2>자주 묻는 질문</h2>
                                        <div class="cs-breadcrumb">고객센터 &gt; 자주 묻는 질문</div>
                                    </div>

                                    <!-- 검색 -->
                                    <div class="cs-search">
                                        <input type="text" v-model="keyword" placeholder="검색어를 입력하세요"
                                            @input="openId = null">
                                        <button type="button">🔍︎</button>
                                    </div>

                                    <!-- 카테고리 탭 -->
                                    <ul class="faq-tab">
                                        <li v-for="c in categoryList" :key="c" :class="{ on: c == category }">
                                            <a href="javascript:;" @click="fnCategory(c)">{{ c }}</a>
                                        </li>
                                    </ul>

                                    <!-- FAQ 목록 -->
                                    <ul class="faq-list">
                                        <li v-if="filteredList.length == 0" class="faq-empty">
                                            검색 결과가 없습니다.
                                        </li>
                                        <li v-for="item in filteredList" :key="item.id"
                                            :class="{ open: openId == item.id }">

                                            <!-- 질문 -->
                                            <a href="javascript:;" class="faq-q" @click="fnToggle(item.id)">
                                                <span class="faq-icon q">Q</span>
                                                <span class="faq-cate">{{ item.category }}</span>
                                                <span class="faq-text">{{ item.question }}</span>
                                                <span class="faq-arrow"></span>
                                            </a>

                                            <!-- 답변 -->
                                            <div class="faq-a" v-if="openId == item.id">
                                                <span class="faq-icon a">A</span>
                                                <div class="faq-text">{{ item.answer }}</div>
                                            </div>

                                        </li>
                                    </ul>

                                    <!-- 1:1 문의 안내 -->
                                    <div class="faq-guide">
                                        <p>찾으시는 답변이 없으신가요?</p>
                                        <button type="button" class="cs-btn primary" @click="fnInquiry">1:1
                                            문의하기</button>
                                    </div>

                                </section>
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
                    keyword: "",            // 검색어
                    category: "전체",        // 선택된 카테고리
                    openId: null,           // 펼쳐진 질문 번호

                    // 카테고리 목록
                    categoryList: ["전체", "회원", "주문/결제", "배송", "교환/반품", "기타"],

                    // FAQ 목록 (하드코딩)
                    faqList: [
                        {
                            id: 1,
                            category: "회원",
                            question: "회원가입은 어떻게 하나요?",
                            answer: "화면 우측 상단의 '회원가입' 버튼을 눌러 이메일, 비밀번호 등 필수 정보를 입력하시면 가입이 완료됩니다."
                        },
                        {
                            id: 2,
                            category: "회원",
                            question: "비밀번호를 잊어버렸어요.",
                            answer: "로그인 화면의 '비밀번호 찾기'에서 가입하신 이메일을 입력하시면 비밀번호 재설정 안내를 보내드립니다."
                        },
                        {
                            id: 3,
                            category: "회원",
                            question: "회원 탈퇴는 어떻게 하나요?",
                            answer: "마이페이지 > 회원정보 수정 하단의 '회원 탈퇴'에서 신청하실 수 있습니다.\n탈퇴 시 보유하신 포인트와 쿠폰은 모두 소멸되니 신중히 결정해주세요."
                        },
                        {
                            id: 4,
                            category: "주문/결제",
                            question: "결제 수단에는 어떤 것이 있나요?",
                            answer: "신용/체크카드, 계좌이체, 간편결제 등을 이용하실 수 있습니다. 이용 가능한 결제 수단은 주문 단계에서 확인해주세요."
                        },
                        {
                            id: 5,
                            category: "주문/결제",
                            question: "주문을 취소하고 싶어요.",
                            answer: "상품 준비 전에는 마이페이지 > 주문내역에서 직접 취소하실 수 있습니다.\n이미 상품 준비 또는 배송이 시작된 경우에는 1:1 문의로 요청해주세요."
                        },
                        {
                            id: 6,
                            category: "주문/결제",
                            question: "선물을 받는 분 주소를 모르는데 주문할 수 있나요?",
                            answer: "선물하기 기능을 이용하시면 받는 분께 링크가 전달되고, 받는 분이 직접 배송지를 입력하실 수 있습니다."
                        },
                        {
                            id: 7,
                            category: "배송",
                            question: "배송은 얼마나 걸리나요?",
                            answer: "결제 완료 후 평균 2~3일(영업일 기준) 내에 도착합니다. 도서산간 지역이나 상품에 따라 더 걸릴 수 있습니다."
                        },
                        {
                            id: 8,
                            category: "배송",
                            question: "배송지를 변경하고 싶어요.",
                            answer: "상품 준비 전에는 마이페이지 > 주문내역에서 배송지를 변경하실 수 있습니다.\n배송이 시작된 이후에는 변경이 어려우니 택배사로 문의해주세요."
                        },
                        {
                            id: 9,
                            category: "교환/반품",
                            question: "교환/반품은 어떻게 신청하나요?",
                            answer: "상품 수령 후 7일 이내에 마이페이지 > 주문내역에서 신청하실 수 있습니다."
                        },
                        {
                            id: 10,
                            category: "교환/반품",
                            question: "교환/반품이 불가능한 경우가 있나요?",
                            answer: "고객님의 부주의로 상품이 훼손되었거나, 포장을 개봉하여 재판매가 어려운 경우에는 교환/반품이 제한될 수 있습니다."
                        },
                        {
                            id: 11,
                            category: "기타",
                            question: "고객센터 운영시간은 어떻게 되나요?",
                            answer: "평일 09:00 ~ 18:00이며, 점심시간은 12:00 ~ 13:00입니다. 주말 및 공휴일은 휴무입니다.\n운영시간 외에는 1:1 문의를 남겨주시면 순차적으로 답변드립니다."
                        }
                    ]
                };
            },

            computed: {

                // 카테고리 + 검색어로 걸러낸 목록
                filteredList() {
                    let self = this;
                    let key = self.keyword.trim();

                    return self.faqList.filter(function (item) {
                        let okCategory = self.category == "전체" || item.category == self.category;
                        let okKeyword = key == ""
                            || item.question.indexOf(key) > -1
                            || item.answer.indexOf(key) > -1;
                        return okCategory && okKeyword;
                    });
                }

            },

            methods: {

                // 카테고리 선택
                fnCategory: function (c) {
                    let self = this;
                    self.category = c;
                    self.openId = null;
                },

                // 질문 펼치기/접기
                fnToggle: function (id) {
                    let self = this;
                    self.openId = (self.openId == id) ? null : id;
                },

                // 1:1 문의 페이지 이동
                fnInquiry: function () {
                    location.href = "/inquiry/write.do";
                }

            }

        });

        app.mount('#app');
    </script>