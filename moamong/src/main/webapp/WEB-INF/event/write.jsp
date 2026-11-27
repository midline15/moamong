<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>이벤트 작성</title>

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
    <!-- 고객센터 상세/작성 css (작성 폼, 에디터) -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/notice/view.css">
    <!-- 이벤트 css -->
    <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/event/event.css">

</head>

<body>

    <!-- 공통 헤더 -->
    <%@ include file="/WEB-INF/common/header.jsp"%>
    <!-- 공통 사이드바 -->
    <%@ include file="/WEB-INF/common/sidebar.jsp"%>

    <!-- 이벤트 작성 영역 -->
    <div id="app">
        <div class="ev-wrap detail">

            <!-- 제목 / 경로 -->
            <div class="cs-title-area">
                <h2>{{ isEdit ? '이벤트 수정' : '이벤트 등록' }}</h2>
                <div class="cs-breadcrumb">이벤트 &gt; {{ isEdit ? '수정' : '등록' }}</div>
            </div>

            <!-- 작성 폼 -->
            <div class="cs-form">

                <div class="cs-form-row">
                    <label>제목</label>
                    <input type="text" v-model="eventTitle"
                        placeholder="제목을 입력하세요" maxlength="200">
                </div>

                <div class="cs-form-row">
                    <label>상태</label>
                    <select class="ev-input" v-model="eventStatus">
                        <option value="READY">예정</option>
                        <option value="ONGOING">진행중</option>
                        <option value="ENDED">종료</option>
                        <option value="HIDDEN">숨김</option>
                    </select>
                </div>

                <div class="cs-form-row">
                    <label>기간</label>
                    <div class="ev-period">
                        <input type="datetime-local" class="ev-input" v-model="startedAt">
                        <span>~</span>
                        <input type="datetime-local" class="ev-input" v-model="endedAt">
                    </div>
                </div>

                <div class="cs-form-row">
                    <label>썸네일</label>
                    <div class="ev-thumb-upload">
                        <div class="preview">
                            <img v-if="thumbnail" :src="thumbnail.imageUrl" alt="썸네일">
                            <span v-else>목록 카드에 보일 대표 이미지</span>
                        </div>
                        <input type="file" ref="thumbFile" accept="image/*" style="display:none"
                            @change="fnThumbSelect">
                        <button type="button" class="cs-btn" @click="$refs.thumbFile.click()">
                            {{ thumbnail ? '썸네일 변경' : '썸네일 선택' }}
                        </button>
                    </div>
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
                eventId: "${eventId}",      // 있으면 수정, 없으면 등록
                eventTitle: "",             // 제목
                eventStatus: "READY",       // 상태 (READY / ONGOING / ENDED / HIDDEN)
                startedAt: "",              // 시작 일시
                endedAt: "",                // 종료 일시
                thumbnail: null,            // 썸네일 정보 (EVENT_IMAGE THUMBNAIL)
                imageList: []               // 본문 이미지 정보 (EVENT_IMAGE DETAIL)
            };
        },

        computed: {

            // 수정 모드 여부
            isEdit() {
                return this.eventId != "";
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
                        ["color", ["color"]],
                        ["para", ["ul", "ol", "paragraph"]],
                        ["table", ["table"]],
                        ["insert", ["link", "picture", "hr"]]
                    ],
                    callbacks: {
                        // 이미지 첨부 / 붙여넣기 / 드래그 시 서버로 업로드
                        onImageUpload: function (files) {
                            for (let i = 0; i < files.length; i++) {
                                self.fnImageUpload(files[i], function (data) {
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
                                });
                            }
                        }
                    }
                });
            },

            // 이미지 업로드 (공통 업로드 사용, 성공하면 callback 실행)
            fnImageUpload: function (file, callback) {
                // 용량 체크 (5MB)
                if (file.size > 5 * 1024 * 1024) {
                    alert("이미지는 5MB 이하만 올릴 수 있습니다.");
                    return;
                }

                let formData = new FormData();
                formData.append("file", file);
                formData.append("type", "event");

                $.ajax({
                    url: "/common/image-upload.dox",
                    dataType: "json",
                    type: "POST",
                    data: formData,
                    processData: false,     // FormData는 그대로 전송
                    contentType: false,

                    success: function (data) {
                        console.log(data);
                        if (data.result == "success") {
                            callback(data);
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
                    url: "/common/image-delete.dox",
                    dataType: "json",
                    type: "POST",
                    data: { urls: JSON.stringify(urls) }
                });
            },

            // 썸네일 선택
            fnThumbSelect: function (e) {
                let self = this;
                let file = e.target.files[0];
                if (!file) return;

                self.fnImageUpload(file, function (data) {
                    self.thumbnail = {
                        imageUrl: data.imageUrl,
                        imageOriginName: data.imageOriginName,
                        imageName: data.imageName,
                        imageSize: data.imageSize
                    };
                });
                e.target.value = "";    // 같은 파일 다시 선택 가능하게 초기화
            },

            // 수정일 때 기존 내용 불러오기
            fnInfo: function () {
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
                            self.eventTitle = data.info.eventTitle;
                            self.eventStatus = data.info.eventStatus;
                            // 2026-12-20 10:00:00 -> 2026-12-20T10:00 (datetime-local 형식)
                            self.startedAt = data.info.startedAt.replace(" ", "T").substring(0, 16);
                            self.endedAt = data.info.endedAt.replace(" ", "T").substring(0, 16);

                            // 기존 이미지 정보 (수정 시 유지하기 위해)
                            let images = data.imageList || [];
                            self.thumbnail = images.find(function (img) { return img.imageType == "THUMBNAIL"; }) || null;
                            self.imageList = images.filter(function (img) { return img.imageType == "DETAIL"; });

                            // 에디터에 기존 내용 채우기
                            editor.summernote("code", data.info.eventContent || "");
                        } else {
                            alert(data.msg || "이벤트를 불러오지 못했습니다.");
                            location.href = "/event/list.do";
                        }
                    }
                });
            },

            // datetime-local 값을 DB 형식으로 (2026-12-20T10:00 -> 2026-12-20 10:00:00)
            fnToDb: function (value) {
                return value.replace("T", " ") + ":00";
            },

            // 저장 (등록/수정)
            fnSave: function () {
                let self = this;

                // 입력값 체크
                if (self.eventTitle.trim() == "") {
                    alert("제목을 입력해주세요.");
                    return;
                }
                if (self.startedAt == "" || self.endedAt == "") {
                    alert("이벤트 기간을 입력해주세요.");
                    return;
                }
                if (self.startedAt > self.endedAt) {
                    alert("종료 일시는 시작 일시보다 빠를 수 없습니다.");
                    return;
                }
                if (!self.thumbnail) {
                    alert("썸네일을 선택해주세요.");
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
                    eventId: self.eventId,
                    eventTitle: self.eventTitle,
                    eventContent: html,                         // HTML로 저장
                    startedAt: self.fnToDb(self.startedAt),
                    endedAt: self.fnToDb(self.endedAt),
                    eventStatus: self.eventStatus,
                    thumbnail: JSON.stringify(self.thumbnail),  // THUMBNAIL 저장용
                    images: JSON.stringify(images)              // DETAIL 저장용
                };

                let url = self.isEdit
                    ? "/event/update.dox"
                    : "/event/add.dox";

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
                                location.href = "/event/view.do?eventId=" + self.eventId;
                            } else {
                                location.href = "/event/list.do";
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
                    location.href = "/event/view.do?eventId=" + self.eventId;
                } else {
                    location.href = "/event/list.do";
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