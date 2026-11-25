<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>1:1문의 작성</title>

        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.js"
            integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>

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

                <!-- 1:1문의 작성 영역 -->
                <div id="app">
                    <div class="cs-wrap">

                        <!-- 좌측 고객센터 메뉴 (1:1문의 활성) -->
                        <% request.setAttribute("csMenu", "inquiry" ); %>
                            <%@ include file="/WEB-INF/common/cs-side.jsp" %>

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
                                            <input type="text" v-model="inqTitle" placeholder="제목을 입력하세요"
                                                maxlength="100">
                                        </div>

                                        <div class="cs-form-row">
                                            <label>문의 내용</label>
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
                <%@ include file="/WEB-INF/common/footer.jsp" %>

    </body>

    </html>

    <script>
        // 에디터 객체 (jQuery 객체, Vue data에 넣으면 프록시 문제가 생겨서 밖에 둠)
        let editor = null;

        const app = Vue.createApp({

            data() {
                return {
                    inqId: "${inqId}",          // 있으면 수정, 없으면 등록
                    memberId: 1,                // TODO: 로그인 세션의 회원 번호로 교체
                    inqTitle: "",               // 제목
                    imageList: []               // 업로드한 이미지 정보 (INQ_IMAGE 저장용)
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

                    editor = $(self.$refs.editor);
                    editor.summernote({
                        lang: "ko-KR",
                        height: 380,
                        placeholder: "문의 내용을 입력하세요",
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
                    formData.append("type", "inquiry");

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

                // 서버에 올라간 임시 이미지 삭제 (DB에 연결된 사진은 서버가 보호함)
                fnImageDelete: function (urls) {
                    if (!urls || urls.length == 0) return;
                    $.ajax({
                        url: "http://localhost:8080/common/image-delete.dox",
                        dataType: "json",
                        type: "POST",
                        data: { urls: JSON.stringify(urls) }
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
                                // 기존에 올린 이미지 정보 (수정 시 유지하기 위해)
                                self.imageList = data.imageList || [];
                                // 에디터에 기존 내용 채우기
                                editor.summernote("code", data.info.inqContent || "");
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

                    // 입력값 체크 (이미지만 넣은 경우는 비어있지 않은 것으로 처리됨)
                    if (self.inqTitle.trim() == "") {
                        alert("제목을 입력해주세요.");
                        return;
                    }
                    if (editor.summernote("isEmpty")) {
                        alert("문의 내용을 입력해주세요.");
                        return;
                    }

                    // 본문에 실제로 남아있는 이미지만 저장 (지운 이미지는 제외)
                    let html = editor.summernote("code");
                    let images = self.imageList.filter(function (img) {
                        return html.indexOf(img.imageUrl) > -1;
                    });

                    let param = {
                        inqId: self.inqId,
                        memberId: self.memberId,
                        inqTitle: self.inqTitle,
                        inqContent: html,                       // HTML로 저장 (색상/정렬/크기 포함)
                        images: JSON.stringify(images)          // INQ_IMAGE 저장용
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
                                    // 본문에서 지운 사진은 서버 파일도 정리
                                    let removed = self.imageList.filter(function (img) {
                                        return html.indexOf(img.imageUrl) == -1;
                                    });
                                    self.fnImageDelete(removed.map(function (img) { return img.imageUrl; }));
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
                    // 이번 작성에서 올린 사진 정리 (이미 저장된 글의 사진은 서버가 보호)
                    self.fnImageDelete(self.imageList.map(function (img) { return img.imageUrl; }));

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
                // 창을 닫거나 이동할 때, 올리기만 하고 저장 안 한 사진 정리
                window.addEventListener("pagehide", function () {
                    if (self.imageList.length == 0) return;
                    let form = new FormData();
                    form.append("urls", JSON.stringify(self.imageList.map(function (img) { return img.imageUrl; })));
                    navigator.sendBeacon("http://localhost:8080/common/image-delete.dox", form);
                });
            }

        });

        app.mount('#app');
    </script>