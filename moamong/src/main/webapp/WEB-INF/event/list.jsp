<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>이벤트</title>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4="
        crossorigin="anonymous"></script>

    <!-- Vue -->
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

    <script src="/js/page-change.js"></script>

    <!-- 공통 헤더 CSS -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/header.css">
    <!-- 공통 사이드바 css -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/sidebar.css">
    <!-- 공통 푸터 css -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/footer.css">
    <!-- 고객센터 공통 css (색상 변수 / 버튼 / 푸터 하단 고정) -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/notice/list.css">
    <!-- 이벤트 css -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/event/event.css">

</head>

<body>

    <!-- 공통 헤더 -->
    <%@ include file="/WEB-INF/common/header.jsp"%>
    <!-- 공통 사이드바 -->
    <%@ include file="/WEB-INF/common/sidebar.jsp"%>

    <!-- 이벤트 영역 -->
    <div id="app">
        <div class="ev-wrap">

            <!-- 타이틀 -->
            <div class="ev-hero">
                <span class="ev-eyebrow">EVENT</span>
                <h2>이벤트</h2>
                <p>지금, 가장 특별한 소식을 만나보세요!</p>
            </div>

            <!-- 상태 탭 -->
            <ul class="ev-tab">
                <li v-for="t in tabList" :key="t.value" :class="{ on: t.value == status }">
                    <a href="javascript:;" @click="fnTab(t.value)">{{ t.label }}</a>
                </li>
            </ul>

            <!-- 이벤트 카드 목록 -->
            <div class="ev-empty" v-if="eventList.length == 0">
                등록된 이벤트가 없습니다.
            </div>

            <ul class="ev-grid" v-else>
                <li class="ev-card" v-for="item in eventList" :key="item.eventId"
                    @click="fnView(item.eventId)">

                    <!-- 썸네일 + 상태 뱃지 -->
                    <div class="ev-thumb">
                        <img v-if="item.thumbnailUrl" :src="item.thumbnailUrl" :alt="item.eventTitle">
                        <div class="ev-noimg" v-else>NO IMAGE</div>
                        <span class="ev-badge" :class="fnBadge(item).cls">{{ fnBadge(item).text }}</span>
                    </div>

                    <!-- 제목 + 기간 -->
                    <div class="ev-info">
                        <div class="ev-text">
                            <strong>{{ item.eventTitle }}</strong>
                            <span class="ev-date">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
                                    <rect x="3" y="5" width="18" height="16" rx="2"></rect>
                                    <path d="M3 10h18M8 3v4M16 3v4"></path>
                                </svg>
                                {{ fnDate(item.startedAt) }} ~ {{ fnDate(item.endedAt) }}
                            </span>
                        </div>
                        <span class="ev-arrow">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M5 12h14M13 6l6 6-6 6"></path>
                            </svg>
                        </span>
                    </div>

                </li>
            </ul>

            <!-- 페이징 -->
            <div class="ev-paging" v-if="totalPage > 0">
                <a href="javascript:;" class="nav" @click="fnPage(page - 1)">&lsaquo;</a>
                <a href="javascript:;" v-for="p in pageList" :key="p"
                    :class="{ on: p == page }" @click="fnPage(p)">{{ p }}</a>
                <a href="javascript:;" class="nav" @click="fnPage(page + 1)">&rsaquo;</a>
            </div>

            <!-- 버튼 영역 (관리자만) -->
            <div class="cs-btn-area right" v-if="isAdmin">
                <button type="button" class="cs-btn primary" @click="fnWrite">글쓰기</button>
            </div>

        </div>
    </div>

    <!-- 공통 푸터 -->
    <%@ include file="/WEB-INF/common/footer.jsp"%>

</body>
</html>

<script>
    const app = Vue.createApp({

        data() {
            return {
                eventList: [],              // 이벤트 목록
                isAdmin: "${isAdmin}" == "true",    // 관리자 여부 (컨트롤러에서 전달, 서버에서도 다시 검사함),        // 관리자 여부 (컨트롤러에서 전달, 서버에서도 다시 검사함)
                status: "",                 // 선택된 상태 탭 ("" 이면 전체)
                page: 1,                    // 현재 페이지
                pageSize: 6,                // 한 페이지에 보여줄 개수 (서버와 동일)
                pageBlock: 5,               // 페이징 번호 몇 개씩 보여줄지
                cnt: 0,                     // 전체 게시글 수

                // 상태 탭
                tabList: [
                    { label: "전체", value: "" },
                    { label: "진행중 이벤트", value: "ONGOING" },
                    { label: "예정 이벤트", value: "READY" },
                    { label: "종료된 이벤트", value: "ENDED" }
                ]
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
                    status: self.status,
                    page: self.page
                };

                $.ajax({
                    url: "http://localhost:8080/event/list.dox",
                    dataType: "json",
                    type: "POST",
                    data: param,

                    success: function (data) {
                        console.log(data);
                        if (data.result == "success") {
                            self.eventList = data.list;
                            self.cnt = data.cnt;
                        } else {
                            alert("목록을 불러오지 못했습니다.");
                        }
                    }
                });
            },

            // 탭 선택 (1페이지부터 다시 조회)
            fnTab: function (value) {
                let self = this;
                self.status = value;
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

            // 날짜 표시 (2026-12-20 10:00:00 -> 26.12.20)
            fnDate: function (str) {
                return str ? str.substring(2, 10).replace(/-/g, ".") : "";
            },

            // 상태 뱃지 (진행중 / D-3 / 예정 / 종료 / 숨김)
            fnBadge: function (item) {
                if (item.eventStatus == "HIDDEN") return { text: "숨김", cls: "end" };
                if (item.eventStatus == "ENDED") return { text: "종료", cls: "end" };
                if (item.eventStatus == "READY") return { text: "예정", cls: "ready" };

                // 진행중이면서 종료까지 3일 이하 남았으면 D-day 표시
                let end = new Date(item.endedAt.replace(" ", "T"));
                let days = Math.ceil((end - new Date()) / (1000 * 60 * 60 * 24));
                if (days <= 3) {
                    return { text: days <= 0 ? "D-Day" : "D-" + days, cls: "ing" };
                }
                return { text: "진행중", cls: "ing" };
            },

            // 상세 페이지 이동
            fnView: function (eventId) {
                location.href = "/event/view.do?eventId=" + eventId;
            },

            // 글쓰기 페이지 이동
            fnWrite: function () {
                location.href = "/event/write.do";
            }

        },

        mounted() {
            let self = this;
            self.fnList();
        }

    });

    app.mount('#app');
</script>