<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>공지사항 상세</title>

        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.js"
            integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>

        <!-- Vue -->
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <!-- HTML 안전하게 출력하기 위한 라이브러리 -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/dompurify/3.1.6/purify.min.js"></script>
        <!-- <script src="/js/page-change.js"></script> -->

        <!-- 공통 헤더 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <!-- 공통 사이드바 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <!-- 공통 푸터 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <!-- 공지사항 css (공통 레이아웃) -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/notice/list.css">
        <!-- 공지사항 상세/작성 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/notice/view.css">

    </head>

    <body>

        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>
            <!-- 공통 사이드바 -->
            <%@ include file="/WEB-INF/common/sidebar.jsp" %>

                <!-- 공지사항 상세 영역 -->
                <div id="app">
                    <div class="cs-wrap">

                        <!-- 좌측 고객센터 메뉴 -->
                        <%@ include file="/WEB-INF/common/cs-side.jsp" %>

                            <!-- 우측 본문 -->
                            <section class="cs-content">

                                <!-- 제목 / 경로 -->
                                <div class="cs-title-area">
                                    <h2>공지사항</h2>
                                    <div class="cs-breadcrumb">고객센터 &gt; 공지사항</div>
                                </div>

                                <!-- 상세 -->
                                <div class="cs-view" v-if="info.noticeId">

                                    <!-- 제목 / 정보 -->
                                    <div class="cs-view-head">
                                        <h3>
                                            <span class="badge" v-if="info.isPinned">공지</span>
                                            {{ info.noticeTitle }}
                                        </h3>
                                        <div class="cs-view-info">
                                            <span>작성일 {{ info.createdAt ? info.createdAt.substring(0, 10) : '' }}</span>
                                            <span>조회수 {{ info.viewCount }}</span>
                                        </div>
                                    </div>

                                    <!-- 내용 -->
                                    <div class="cs-view-body cs-html" v-html="safeContent"></div>

                                </div>

                                <!-- 버튼 영역 -->
                                <div class="cs-btn-area">
                                    <button type="button" class="cs-btn" @click="fnList">목록</button>

                                    <!-- TODO: 관리자만 보이게 -->
                                    <div class="right-group" v-if="isAdmin">
                                        <button type="button" class="cs-btn" @click="fnEdit">수정</button>
                                        <button type="button" class="cs-btn danger" @click="fnDelete">삭제</button>
                                    </div>
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
                    noticeId: "${noticeId}",    // 컨트롤러에서 넘겨받은 공지사항 번호
                    isAdmin: "${isAdmin}" == "true",    // 관리자 여부 (서버에서도 다시 검사함)
                    info: {}                    // 공지사항 상세 정보
                };
            },
            computed: {

                // 화면에 출력할 내용 (위험한 코드 제거)
                safeContent() {
                    return DOMPurify.sanitize(this.info.noticeContent || "");
                }

            },

            methods: {

                // 상세 조회 (조회수 증가)
                fnView: function () {
                    let self = this;
                    let param = {
                        noticeId: self.noticeId,
                        addView: "Y"
                    };

                    $.ajax({
                        url: "http://localhost:8080/notice/view.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                self.info = data.info;
                            } else {
                                alert(data.msg || "공지사항을 불러오지 못했습니다.");
                                location.href = "/notice/list.do";
                            }
                        }
                    });
                },

                // 목록으로
                fnList: function () {
                    location.href = "/notice/list.do";
                },

                // 수정 페이지 이동
                fnEdit: function () {
                    let self = this;
                    location.href = "/notice/write.do?noticeId=" + self.noticeId;
                },

                // 삭제
                fnDelete: function () {
                    let self = this;
                    if (!confirm("정말 삭제하시겠습니까?")) return;

                    let param = {
                        noticeId: self.noticeId
                    };

                    $.ajax({
                        url: "http://localhost:8080/notice/delete.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                alert("삭제되었습니다.");
                                location.href = "/notice/list.do";
                            } else {
                                alert("삭제에 실패했습니다.");
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