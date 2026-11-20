<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>1:1문의 작성</title>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4="
        crossorigin="anonymous"></script>

    <!-- Vue -->
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

    <!-- Toast UI Editor (텍스트 에디터) -->
    <link rel="stylesheet" href="https://uicdn.toast.com/editor/3.2.2/toastui-editor.min.css">
    <script src="https://uicdn.toast.com/editor/3.2.2/toastui-editor-all.min.js"></script>
    <script src="https://uicdn.toast.com/editor/3.2.2/i18n/ko-kr.js"></script>

    <!-- HTML 안전하게 출력하기 위한 라이브러리 -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/dompurify/3.1.6/purify.min.js"></script>
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
    <!-- 고객센터 공통 css (레이아웃/버튼) -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/notice/list.css">
    <!-- 고객센터 상세/작성 css -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/notice/view.css">
    <!-- 1:1문의 css -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/inquiry/inquiry.css">

</head>

<body>

    <!-- 공통 헤더 -->
    <%@ include file="/WEB-INF/common/header.jsp"%>
    <!-- 공통 사이드바 -->
    <%@ include file="/WEB-INF/common/sidebar.jsp"%>

    <!-- 1:1문의 작성 영역 -->
    <div id="app">
        <div class="cs-wrap">

            <!-- 좌측 고객센터 메뉴 (1:1문의 활성) -->
            <% request.setAttribute("csMenu", "inquiry"); %>
            <%@ include file="/WEB-INF/common/cs-side.jsp"%>

            <!-- 우측 본문 -->
            <section class="cs-content">

                <!-- 제목 / 경로 -->
                <div class="cs-title-area">
                    <h2>{{ isEdit ? '문의 수정' : '문의하기' }}</h2>
                    <div class="cs-breadcrumb">고객센터 &gt; 1:1 상담문의</div>
                </div>

                <!-- 작성 폼 -->
                <div class="cs-form">

                    <div class="cs-form-row">
                        <label>제목</label>
                        <input type="text" v-model="inqTitle"
                            placeholder="제목을 입력하세요" maxlength="100">
                    </div>

                    <div class="cs-form-row">
                        <label>문의 내용</label>
                        <!-- 텍스트 에디터 영역 -->
                        <div class="cs-editor" ref="editor"></div>
                    </div>

                </div>

                <!-- 버튼 영역 -->
                <div class="cs-btn-area">
                    <button type="button" class="cs-btn" @click="fnCancel">취소</button>
                    <div class="right-group">
                        <button type="button" class="cs-btn primary" @click="fnSave">
                            {{ isEdit ? '수정' : '등록' }}
                        </button>
                    </div>
                </div>

            </section>
        </div>
    </div>

    <!-- 공통 푸터 -->
    <%@ include file="/WEB-INF/common/footer.jsp"%>

</body>
</html>

<script>
    // 에디터 객체 (Vue data에 넣으면 프록시 문제가 생겨서 밖에 둠)
    let editor = null;

    const app = Vue.createApp({

        data() {
            return {
                inqId: "${inqId}",          // 있으면 수정, 없으면 등록
                memberId: 1,                // TODO: 로그인 세션의 회원 번호로 교체
                inqTitle: ""                // 제목
            };
        },

        computed: {

            // 수정 모드 여부
            isEdit() {
                return this.inqId != "";
            }

        },

        methods: {

            // 에디터 생성
            fnEditor: function () {
                let self = this;

                editor = new toastui.Editor({
                    el: self.$refs.editor,
                    height: "380px",
                    initialEditType: "wysiwyg",     // 바로 보이는 대로 편집
                    hideModeSwitch: true,           // 마크다운 전환 버튼 숨김
                    language: "ko-KR",
                    placeholder: "문의 내용을 입력하세요",
                    // 이미지는 base64로 DB에 들어가 너무 커져서 뺌
                    toolbarItems: [
                        ["heading", "bold", "italic", "strike"],
                        ["hr", "quote"],
                        ["ul", "ol"],
                        ["table", "link"]
                    ]
                });
            },

            // 수정일 때 기존 내용 불러오기
            fnInfo: function () {
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
                            // 답변 완료된 문의는 수정 불가
                            if (data.info.inqStatus == "DONE") {
                                alert("답변이 완료된 문의는 수정할 수 없습니다.");
                                location.href = "/inquiry/view.do?inqId=" + self.inqId;
                                return;
                            }
                            self.inqTitle = data.info.inqTitle;
                            // 에디터에 기존 내용 채우기
                            editor.setHTML(data.info.inqContent || "");
                        } else {
                            alert(data.msg || "문의를 불러오지 못했습니다.");
                            location.href = "/inquiry/list.do";
                        }
                    }
                });
            },

            // 저장 (등록/수정)
            fnSave: function () {
                let self = this;

                // 입력값 체크 (에디터가 비어있는지는 마크다운 기준으로 확인)
                if (self.inqTitle.trim() == "") {
                    alert("제목을 입력해주세요.");
                    return;
                }
                if (editor.getMarkdown().trim() == "") {
                    alert("문의 내용을 입력해주세요.");
                    return;
                }

                let param = {
                    inqId: self.inqId,
                    memberId: self.memberId,
                    inqTitle: self.inqTitle,
                    inqContent: editor.getHTML()    // HTML로 저장
                };

                let url = self.isEdit
                    ? "http://localhost:8080/inquiry/update.dox"
                    : "http://localhost:8080/inquiry/add.dox";

                $.ajax({
                    url: url,
                    dataType: "json",
                    type: "POST",
                    data: param,

                    success: function (data) {
                        console.log(data);
                        if (data.result == "success") {
                            alert(self.isEdit ? "수정되었습니다." : "등록되었습니다.");
                            if (self.isEdit) {
                                location.href = "/inquiry/view.do?inqId=" + self.inqId;
                            } else {
                                location.href = "/inquiry/list.do";
                            }
                        } else {
                            alert(data.msg || "저장에 실패했습니다.");
                        }
                    }
                });
            },

            // 취소
            fnCancel: function () {
                let self = this;
                if (!confirm("작성을 취소하시겠습니까?")) return;

                if (self.isEdit) {
                    location.href = "/inquiry/view.do?inqId=" + self.inqId;
                } else {
                    location.href = "/inquiry/list.do";
                }
            }

        },

        mounted() {
            let self = this;
            self.fnEditor();
            if (self.isEdit) {
                self.fnInfo();
            }
        }

    });

    app.mount('#app');
</script>