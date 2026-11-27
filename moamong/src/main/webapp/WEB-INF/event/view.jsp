<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>이벤트 상세</title>

        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.js"
            integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>

        <!-- Vue -->
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

        <!-- HTML 안전하게 출력하기 위한 라이브러리 -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/dompurify/3.1.6/purify.min.js"></script>
        <script src="/js/page-change.js"></script>

        <!-- 공통 헤더 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <!-- 공통 사이드바 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <!-- 공통 푸터 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <!-- 고객센터 공통 css (색상 변수 / 버튼 / 푸터 하단 고정) -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/notice/list.css">
        <!-- 고객센터 상세/작성 css (상세 헤더, 본문 출력) -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/notice/view.css">
        <!-- 이벤트 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/event/event.css">

    </head>

    <body>

        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>
            <!-- 공통 사이드바 -->
            <%@ include file="/WEB-INF/common/sidebar.jsp" %>

                <!-- 이벤트 상세 영역 -->
                <div id="app">
                    <div class="ev-wrap detail">

                        <!-- 제목 / 경로 -->
                        <div class="cs-title-area">
                            <h2>이벤트</h2>
                            <div class="cs-breadcrumb">이벤트 &gt; 상세</div>
                        </div>

                        <!-- 상세 -->
                        <div class="cs-view" v-if="info.eventId">

                            <!-- 제목 / 정보 -->
                            <div class="cs-view-head">
                                <h3>
                                    <span class="ev-badge inline" :class="badge.cls">{{ badge.text }}</span>
                                    {{ info.eventTitle }}
                                </h3>
                                <div class="cs-view-info">
                                    <span>기간 {{ fnDate(info.startedAt) }} ~ {{ fnDate(info.endedAt) }}</span>
                                </div>
                            </div>

                            <!-- 내용 -->
                            <div class="cs-view-body cs-html" v-html="safeContent"></div>

                        </div>

                        <!-- 버튼 영역 -->
                        <div class="cs-btn-area">
                            <button type="button" class="cs-btn" @click="fnList">목록</button>

                            <!-- 관리자만 -->
                            <div class="right-group" v-if="isAdmin">
                                <button type="button" class="cs-btn" @click="fnEdit">수정</button>
                                <button type="button" class="cs-btn danger" @click="fnDelete">삭제</button>
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
                    eventId: "${eventId}",      // 컨트롤러에서 넘겨받은 이벤트 번호
                    isAdmin: "${isAdmin}" == "true",    // 관리자 여부 (서버에서도 다시 검사함)
                    info: {}                    // 이벤트 상세 정보
                };
            },

            computed: {

                // 화면에 출력할 내용 (위험한 코드 제거)
                safeContent() {
                    return DOMPurify.sanitize(this.info.eventContent || "");
                },

                // 상태 뱃지
                badge() {
                    let item = this.info;
                    if (item.eventStatus == "HIDDEN") return { text: "숨김", cls: "end" };
                    if (item.eventStatus == "ENDED") return { text: "종료", cls: "end" };
                    if (item.eventStatus == "READY") return { text: "예정", cls: "ready" };
                    return { text: "진행중", cls: "ing" };
                }

            },

            methods: {

                // 상세 조회
                fnView: function () {
                    let self = this;
                    let param = {
                        eventId: self.eventId
                    };

                    $.ajax({
                        url: "/event/view.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                self.info = data.info;
                            } else {
                                alert(data.msg || "이벤트를 불러오지 못했습니다.");
                                location.href = "/event/list.do";
                            }
                        }
                    });
                },

                // 날짜 표시 (2026-12-20 10:00:00 -> 2026.12.20)
                fnDate: function (str) {
                    return str ? str.substring(0, 10).replace(/-/g, ".") : "";
                },

                // 목록으로
                fnList: function () {
                    location.href = "/event/list.do";
                },

                // 수정 페이지 이동
                fnEdit: function () {
                    let self = this;
                    location.href = "/event/write.do?eventId=" + self.eventId;
                },

                // 삭제
                fnDelete: function () {
                    let self = this;
                    if (!confirm("정말 삭제하시겠습니까?")) return;

                    let param = {
                        eventId: self.eventId
                    };

                    $.ajax({
                        url: "/event/delete.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                alert("삭제되었습니다.");
                                location.href = "/event/list.do";
                            } else {
                                alert(data.msg || "삭제에 실패했습니다.");
                            }
                        }
                    });
                }

            },

            mounted() {
                let self = this;
                self.fnView();
            }

        });

        app.mount('#app');
    </script>