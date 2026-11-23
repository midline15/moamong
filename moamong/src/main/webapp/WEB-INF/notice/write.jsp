<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>공지사항 작성</title>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4="
        crossorigin="anonymous"></script>

    <!-- Vue -->
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

    <!-- Summernote (텍스트 에디터) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/summernote/0.9.0/summernote-lite.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/summernote/0.9.0/summernote-lite.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/summernote/0.9.0/lang/summernote-ko-KR.min.js"></script>

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
    <!-- 공지사항 css (공통 레이아웃) -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/notice/list.css">
    <!-- 공지사항 상세/작성 css -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/notice/view.css">

</head>

<body>

    <!-- 공통 헤더 -->
    <%@ include file="/WEB-INF/common/header.jsp"%>
    <!-- 공통 사이드바 -->
    <%@ include file="/WEB-INF/common/sidebar.jsp"%>

    <!-- 공지사항 작성 영역 -->
    <div id="app">
        <div class="cs-wrap">

            <!-- 좌측 고객센터 메뉴 -->
            <%@ include file="/WEB-INF/common/cs-side.jsp"%>

            <!-- 우측 본문 -->
            <section class="cs-content">

                <!-- 제목 / 경로 -->
                <div class="cs-title-area">
                    <h2>{{ isEdit ? '공지사항 수정' : '공지사항 등록' }}</h2>
                    <div class="cs-breadcrumb">고객센터 &gt; 공지사항</div>
                </div>

                <!-- 작성 폼 -->
                <div class="cs-form">

                    <div class="cs-form-row">
                        <label>제목</label>
                        <input type="text" v-model="noticeTitle"
                            placeholder="제목을 입력하세요" maxlength="100">
                    </div>

                    <div class="cs-form-row">
                        <label>상단 고정</label>
                        <label class="check">
                            <input type="checkbox" v-model="isPinned"> 공지로 상단에 고정
                        </label>
                    </div>

                    <div class="cs-form-row">
                        <label>내용</label>
                        <!-- 텍스트 에디터 영역 -->
                        <div class="cs-editor"><textarea ref="editor"></textarea></div>
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
    // 에디터 객체 (jQuery 객체, Vue data에 넣으면 프록시 문제가 생겨서 밖에 둠)
    let editor = null;

    const app = Vue.createApp({

        data() {
            return {
                noticeId: "${noticeId}",    // 있으면 수정, 없으면 등록
                adminId: 1,                 // TODO: 로그인 세션의 관리자 번호로 교체
                noticeTitle: "",            // 제목
                isPinned: false,            // 상단 고정 여부
                imageList: []               // 업로드한 이미지 정보 (NOTICE_IMAGE 저장용)
            };
        },

        computed: {

            // 수정 모드 여부
            isEdit() {
                return this.noticeId != "";
            }

        },

        methods: {

            // 에디터 생성
            fnEditor: function () {
                let self = this;

                editor = $(self.$refs.editor);
                editor.summernote({
                    lang: "ko-KR",
                    height: 420,
                    placeholder: "내용을 입력하세요",
                    dialogsInBody: true,
                    fontSizes: ["11", "12", "13", "14", "16", "18", "20", "24", "28", "32"],
                    toolbar: [
                        ["style", ["style"]],
                        ["font", ["bold", "italic", "underline", "strikethrough", "clear"]],
                        ["fontsize", ["fontsize"]],
                        ["color", ["color"]],               // 글자색 + 배경색
                        ["para", ["ul", "ol", "paragraph"]],// paragraph 안에 좌/중/우/양쪽 정렬
                        ["table", ["table"]],
                        ["insert", ["link", "picture", "hr"]]
                    ],
                    callbacks: {
                        // 이미지 첨부 / 붙여넣기 / 드래그 시 서버로 업로드
                        onImageUpload: function (files) {
                            for (let i = 0; i < files.length; i++) {
                                self.fnImageUpload(files[i]);
                            }
                        }
                    }
                });
            },

            // 이미지 업로드
            fnImageUpload: function (file) {
                let self = this;

                // 용량 체크 (5MB)
                if (file.size > 5 * 1024 * 1024) {
                    alert("이미지는 5MB 이하만 올릴 수 있습니다.");
                    return;
                }

                let formData = new FormData();
                formData.append("file", file);

                $.ajax({
                    url: "http://localhost:8080/common/image-upload.dox",
                    dataType: "json",
                    type: "POST",
                    data: formData,
                    processData: false,     // FormData는 그대로 전송
                    contentType: false,

                    success: function (data) {
                        console.log(data);
                        if (data.result == "success") {
                            // 에디터에 이미지 삽입
                            editor.summernote("insertImage", data.imageUrl, function ($image) {
                                $image.attr("alt", data.imageOriginName);
                            });
                            // 저장할 때 쓸 이미지 정보 보관
                            self.imageList.push({
                                imageUrl: data.imageUrl,
                                imageOriginName: data.imageOriginName,
                                imageName: data.imageName,
                                imageSize: data.imageSize
                            });
                        } else {
                            alert(data.msg || "이미지 업로드에 실패했습니다.");
                        }
                    }
                });
            },

            // 수정일 때 기존 내용 불러오기 (조회수 증가 X)
            fnInfo: function () {
                let self = this;
                let param = {
                    noticeId: self.noticeId
                };

                $.ajax({
                    url: "http://localhost:8080/notice/view.dox",
                    dataType: "json",
                    type: "POST",
                    data: param,

                    success: function (data) {
                        console.log(data);
                        if (data.result == "success") {
                            self.noticeTitle = data.info.noticeTitle;
                            self.isPinned = data.info.isPinned ? true : false;
                            // 기존에 올린 이미지 정보 (수정 시 유지하기 위해)
                            self.imageList = data.imageList || [];
                            // 에디터에 기존 내용 채우기
                            editor.summernote("code", data.info.noticeContent || "");
                        } else {
                            alert(data.msg || "공지사항을 불러오지 못했습니다.");
                            location.href = "/notice/list.do";
                        }
                    }
                });
            },

            // 저장 (등록/수정)
            fnSave: function () {
                let self = this;

                // 입력값 체크 (이미지만 넣은 경우는 비어있지 않은 것으로 처리됨)
                if (self.noticeTitle.trim() == "") {
                    alert("제목을 입력해주세요.");
                    return;
                }
                if (editor.summernote("isEmpty")) {
                    alert("내용을 입력해주세요.");
                    return;
                }

                // 본문에 실제로 남아있는 이미지만 저장 (지운 이미지는 제외)
                let html = editor.summernote("code");
                let images = self.imageList.filter(function (img) {
                    return html.indexOf(img.imageUrl) > -1;
                });

                let param = {
                    noticeId: self.noticeId,
                    adminId: self.adminId,
                    noticeTitle: self.noticeTitle,
                    noticeContent: html,                    // HTML로 저장 (색상/정렬/크기 포함)
                    isPinned: self.isPinned ? 1 : 0,
                    images: JSON.stringify(images)          // NOTICE_IMAGE 저장용
                };

                let url = self.isEdit
                    ? "http://localhost:8080/notice/update.dox"
                    : "http://localhost:8080/notice/add.dox";

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
                                location.href = "/notice/view.do?noticeId=" + self.noticeId;
                            } else {
                                location.href = "/notice/list.do";
                            }
                        } else {
                            alert("저장에 실패했습니다.");
                        }
                    }
                });
            },

            // 취소
            fnCancel: function () {
                let self = this;
                if (!confirm("작성을 취소하시겠습니까?")) return;

                if (self.isEdit) {
                    location.href = "/notice/view.do?noticeId=" + self.noticeId;
                } else {
                    location.href = "/notice/list.do";
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