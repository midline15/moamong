<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>1:1문의 상세</title>

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
        <!-- 고객센터 공통 css (레이아웃/버튼) -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/notice/list.css">
        <!-- 고객센터 상세/작성 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/notice/view.css">
        <!-- 1:1문의 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/inquiry/inquiry.css">

    </head>

    <body>

        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>
            <!-- 공통 사이드바 -->
            <%@ include file="/WEB-INF/common/sidebar.jsp" %>

                <!-- 1:1문의 상세 영역 -->
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

                                    <!-- 문의 상세 -->
                                    <div class="cs-view" v-if="info.inqId">

                                        <!-- 제목 / 정보 -->
                                        <div class="cs-view-head">
                                            <h3>
                                                <span class="cs-status" :class="isDone ? 'done' : 'wait'">
                                                    {{ isDone ? '답변완료' : '답변대기' }}
                                                </span>
                                                <span class="cs-secret" v-if="info.isSecret">
                                                    <svg class="cs-lock" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2">
                                                        <rect x="5" y="11" width="14" height="10" rx="2"></rect>
                                                        <path d="M8 11V7a4 4 0 0 1 8 0v4"></path>
                                                    </svg>비밀글
                                                </span>
                                                {{ info.inqTitle }}
                                            </h3>
                                            <div class="cs-view-info">
                                                <span>작성일 {{ info.createdAt ? info.createdAt.substring(0, 10) : ''
                                                    }}</span>
                                            </div>
                                        </div>

                                        <!-- 문의 내용 -->
                                        <div class="cs-view-body cs-html" v-html="safeContent"></div>

                                        <!-- 답변 영역 -->
                                        <div class="cs-answer" v-if="isDone">
                                            <div class="cs-answer-head">
                                                <strong>답변</strong>
                                                <span>{{ info.answeredAt ? info.answeredAt.substring(0, 10) : ''
                                                    }}</span>
                                            </div>
                                            <div class="cs-answer-body">{{ info.answerContent }}</div>
                                        </div>

                                        <!-- 답변 대기 안내 (일반 회원용) -->
                                        <div class="cs-answer empty" v-if="!isDone && !isAdmin">
                                            아직 답변이 등록되지 않았습니다. 빠른 시일 내에 답변드리겠습니다.
                                        </div>

                                        
                                        <div class="cs-answer-form" v-if="isAdmin">
                                            <label>{{ isDone ? '답변 수정' : '답변 등록' }}</label>
                                            <textarea v-model="answerContent" placeholder="답변 내용을 입력하세요"></textarea>
                                            <div class="cs-btn-area right">
                                                <button type="button" class="cs-btn primary" @click="fnAnswer">
                                                    {{ isDone ? '답변 수정' : '답변 등록' }}
                                                </button>
                                            </div>
                                        </div>

                                    </div>

                                    <!-- 버튼 영역 -->
                                    <div class="cs-btn-area">
                                        <button type="button" class="cs-btn" @click="fnList">목록</button>

                                        <div class="right-group">
                                            <!-- 작성자만, 답변 완료 전에만 수정 가능 -->
                                            <button type="button" class="cs-btn" v-if="isOwner && !isDone"
                                                @click="fnEdit">수정</button>
                                            <!-- 작성자 또는 관리자만 삭제 -->
                                            <button type="button" class="cs-btn danger" v-if="isOwner || isAdmin"
                                                @click="fnDelete">삭제</button>
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
                    inqId: "${inqId}",          // 컨트롤러에서 넘겨받은 문의 번호
                    info: {},                   // 문의 상세 정보
                    memberId: Number("${memberId}"), // 내 회원 번호
                    isAdmin: "${isAdmin}" == "true",              // TODO: 로그인 세션의 관리자 여부로 교체 (테스트용 true)
                    adminId: 1,                 // TODO: 로그인 세션의 관리자 번호로 교체
                    answerContent: ""           // 답변 입력값
                };
            },

            computed: {

                // 답변 완료 여부
                isDone() {
                    return this.info.inqStatus == "DONE";
                },
                // 내가 쓴 문의인지
                isOwner() {
                    return this.info.memberId == this.memberId;
                },
                // 화면에 출력할 내용 (위험한 코드 제거)
                safeContent() {
                    return DOMPurify.sanitize(this.info.inqContent || "");
                }

            },

            methods: {

                // 상세 조회
                fnView: function () {
                    let self = this;
                    let param = {
                        inqId: self.inqId
                    };

                    $.ajax({
                        url: "http://localhost:8080/inquiry/view.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                self.info = data.info;
                                // 기존 답변이 있으면 입력창에 채우기 (수정용)
                                self.answerContent = data.info.answerContent || "";
                            } else {
                                alert(data.msg || "문의를 불러오지 못했습니다.");
                                location.href = "/inquiry/list.do";
                            }
                        }
                    });
                },

                // 답변 등록/수정 (관리자)
                fnAnswer: function () {
                    let self = this;

                    if (self.answerContent.trim() == "") {
                        alert("답변 내용을 입력해주세요.");
                        return;
                    }

                    let param = {
                        inqId: self.inqId,
                        answerContent: self.answerContent
                    };

                    $.ajax({
                        url: "http://localhost:8080/inquiry/answer.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                alert("답변이 등록되었어요.");
                                self.fnView();
                            } else {
                                alert(data.msg || "답변을 등록하지 못했어요. 잠시 후 다시 시도해주세요.");
                            }
                        }
                    });
                },

                // 목록으로
                fnList: function () {
                    location.href = "/inquiry/list.do";
                },

                // 수정 페이지 이동
                fnEdit: function () {
                    let self = this;
                    location.href = "/inquiry/write.do?inqId=" + self.inqId;
                },

                // 삭제
                fnDelete: function () {
                    let self = this;
                    if (!confirm("정말 삭제하시겠습니까?")) return;

                    let param = {
                        inqId: self.inqId
                    };

                    $.ajax({
                        url: "http://localhost:8080/inquiry/delete.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                alert("삭제되었습니다.");
                                location.href = "/inquiry/list.do";
                            } else {
                                alert(data.msg || "삭제하지 못했어요. 잠시 후 다시 시도해주세요.");
                                if (data.msg == "로그인 후 이용해주세요.") location.href = "/member/login.do";
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