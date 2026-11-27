<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>1:1문의</title>

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

        <!-- 1:1 문의 전용 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/inquiry/inquiry.css">

    </head>

    <body>

        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>
            <!-- 공통 사이드바 -->
            <%@ include file="/WEB-INF/common/sidebar.jsp" %>

                <!-- 1:1문의 영역 -->
                <div id="app">
                    <div class="cs-wrap">

                        <!-- 좌측 고객센터 메뉴 (1:1문의 활성) -->
                        <% request.setAttribute("csMenu", "inquiry" ); %>
                            <%@ include file="/WEB-INF/common/cs-side.jsp" %>

                                <!-- 우측 본문 -->
                                <section class="cs-content">

                                    <!-- 제목 / 경로 -->
                                    <div class="cs-title-area">
                                        <h2>1:1 상담문의</h2>
                                        <div class="cs-breadcrumb">고객센터 &gt; 1:1 상담문의</div>
                                    </div>

                                    <!-- 검색 -->
                                    <div class="cs-search">
                                        <input type="text" v-model="keyword" placeholder="검색어를 입력하세요"
                                            @keyup.enter="fnSearch">
                                        <button type="button" @click="fnSearch">🔍︎</button>
                                    </div>

                                    <!-- 목록 -->
                                    <table class="cs-table">
                                        <colgroup>
                                            <col style="width: 10%">
                                            <col style="width: 55%">
                                            <col style="width: 15%">
                                            <col style="width: 20%">
                                        </colgroup>
                                        <thead>
                                            <tr>
                                                <th>번호</th>
                                                <th>제목</th>
                                                <th>답변상태</th>
                                                <th>작성일</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr v-if="inquiryList.length == 0">
                                                <td colspan="4" class="empty">등록된 문의가 없습니다.</td>
                                            </tr>
                                            <tr v-for="item in inquiryList" :key="item.inqId">
                                                <td>{{ item.inqId }}</td>
                                                <td class="title">
                                                    <a href="javascript:;" @click="fnView(item)">
                                                        <svg v-if="item.isSecret" class="cs-lock" viewBox="0 0 24 24"
                                                            fill="none" stroke="currentColor" stroke-width="2"
                                                            aria-label="비밀글">
                                                            <rect x="5" y="11" width="14" height="10" rx="2"></rect>
                                                            <path d="M8 11V7a4 4 0 0 1 8 0v4"></path>
                                                        </svg>{{ item.inqTitle }}
                                                    </a>
                                                </td>
                                                <td>
                                                    <span class="cs-status"
                                                        :class="item.inqStatus == 'DONE' ? 'done' : 'wait'">
                                                        {{ item.inqStatus == 'DONE' ? '답변완료' : '답변대기' }}
                                                    </span>
                                                </td>
                                                <td>{{ item.createdAt ? item.createdAt.substring(0, 10) : '' }}</td>
                                            </tr>
                                        </tbody>
                                    </table>

                                    <!-- 페이징 -->
                                    <div class="cs-paging" v-if="totalPage > 0">
                                        <a href="javascript:;" @click="fnPage(1)">&laquo;</a>
                                        <a href="javascript:;" @click="fnPage(page - 1)">&lsaquo;</a>
                                        <a href="javascript:;" v-for="p in pageList" :key="p" :class="{ on: p == page }"
                                            @click="fnPage(p)">{{ p }}</a>
                                        <a href="javascript:;" @click="fnPage(page + 1)">&rsaquo;</a>
                                        <a href="javascript:;" @click="fnPage(totalPage)">&raquo;</a>
                                    </div>

                                    <!-- 버튼 영역 -->
                                    <div class="cs-btn-area right">
                                        <button type="button" class="cs-btn primary" @click="fnWrite">문의하기</button>
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
                    inquiryList: [],    // 1:1문의 목록
                    memberId: Number("${memberId}"),        // TODO: 로그인 세션의 회원 번호로 교체 (내 문의만 조회)
                    isLogin: "${isLogin}" == "true", //로구인여부
                    isAdmin: "${isAdmin}" == "true", //관리자여부(서버에서도다시검사함)
                    keyword: "",        // 검색어
                    page: 1,            // 현재 페이지
                    pageSize: 10,       // 한 페이지에 보여줄 개수
                    pageBlock: 5,       // 페이징 번호 몇 개씩 보여줄지
                    cnt: 0              // 전체 게시글 수
                };
            },

            computed: {

                // 전체 페이지 수
                totalPage() {
                    return Math.ceil(this.cnt / this.pageSize);
                },

                // 화면에 보여줄 페이지 번호들
                pageList() {
                    let start = Math.floor((this.page - 1) / this.pageBlock) * this.pageBlock + 1;
                    let end = Math.min(start + this.pageBlock - 1, this.totalPage);
                    let arr = [];
                    for (let i = start; i <= end; i++) arr.push(i);
                    return arr;
                }

            },

            methods: {

                // 목록 조회
                fnList: function () {
                    let self = this;
                    let param = {
                        keyword: self.keyword,
                        page: self.page
                    };

                    $.ajax({
                        url: "http://localhost:8080/inquiry/list.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                self.inquiryList = data.list;
                                self.cnt = data.cnt;
                            } else {
                                alert("문의 목록을 불러오지 못했어요. 잠시 후 다시 시도해주세요.");
                            }
                        }
                    });
                },

                // 검색 (1페이지부터 다시 조회)
                fnSearch: function () {
                    let self = this;
                    self.page = 1;
                    self.fnList();
                },

                // 페이지 이동
                fnPage: function (p) {
                    let self = this;
                    if (p < 1 || p > self.totalPage) return;
                    self.page = p;
                    self.fnList();
                },

                // 상세 페이지 이동 (남의 비밀글은 열리지 않음, 서버에서도 다시 막음)
                fnView: function (item) {
                    let self = this;
                    if (item.isSecret && item.memberId != self.memberId && !self.isAdmin) {
                        alert("비밀글입니다.");
                        return;
                    }
                    location.href = "/inquiry/view.do?inqId=" + item.inqId;
                },

                // 문의하기 페이지 이동 (로그인 필요)
                fnWrite: function () {
                    let self = this;
                    if (!self.isLogin) {
                        alert("로그인 후 이용해주세요.");
                        location.href = "/member/login.do";
                        return;
                    }
                    location.href = "/inquiry/write.do";
                }

            },

            mounted() {
                let self = this;
                self.fnList();
            }

        });

        app.mount('#app');
    </script>