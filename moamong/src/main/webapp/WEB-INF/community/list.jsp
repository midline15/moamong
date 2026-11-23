<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>소셜</title>

        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.1.js"
            integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>

        <!-- Vue -->
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

        <script src="/js/page-change.js"></script>

        <!-- 공통 헤더 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <!-- 공통 사이드바 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <!-- 공통 푸터 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <!-- 색상 변수 / 푸터 하단 고정 (community.css 가 이 변수를 사용) -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/notice/list.css">
        <!-- 커뮤니티 css -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/community/community.css">

    </head>

    <body>

        <!-- 공통 헤더 -->
        <%@ include file="/WEB-INF/common/header.jsp" %>
            <!-- 공통 사이드바 -->
            <%@ include file="/WEB-INF/common/sidebar.jsp" %>

                <!-- 커뮤니티 영역 -->
                <div id="app">
                    <div class="cm-wrap">

                        <!-- 타이틀 -->
                        <h2 class="cm-title"><span>소셜</span></h2>

                        <!-- 상단 박스 (태그 탭 + 글쓰기) -->
                        <div class="cm-box">

                            <!-- 해시태그 탭 -->
                            <ul class="cm-tab">
                                <li v-for="t in tabList" :key="t.value" :class="{ on: t.value == tag }">
                                    <a href="javascript:;" @click="fnTab(t.value)">{{ t.label }}</a>
                                </li>
                            </ul>

                            <!-- 글쓰기 -->
                            <div class="cm-write">
                                <div class="cm-write-main">
                                    <div class="cm-avatar">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                                            <circle cx="12" cy="8" r="4"></circle>
                                            <path d="M4 21c0-4.4 3.6-7 8-7s8 2.6 8 7z"></path>
                                        </svg>
                                    </div>
                                    <textarea ref="content" v-model="content" rows="2" maxlength="1000"
                                        :placeholder="isLogin ? '오늘은 어떤 소식을 올려볼까요?' : '로그인 후 글을 올릴 수 있어요.'"
                                        :disabled="!isLogin" @input="fnResize"></textarea>
                                    <span class="cm-count">{{ content.length }}/1000</span>
                                </div>

                                <!-- 첨부 이미지 미리보기 -->
                                <ul class="cm-preview" v-if="imageList.length > 0">
                                    <li v-for="(img, idx) in imageList" :key="img.imageUrl">
                                        <img :src="img.imageUrl" :alt="img.imageOriginName">
                                        <button type="button" @click="fnImageRemove(idx)">&times;</button>
                                    </li>
                                </ul>

                                <div class="cm-write-tool">
                                    <div class="cm-tools">
                                        <!-- 사진 -->
                                        <input type="file" ref="imageFile" accept="image/*" multiple
                                            style="display:none" @change="fnImageSelect">
                                        <button type="button" class="cm-icon-btn" title="사진 첨부" :disabled="!isLogin"
                                            @click="$refs.imageFile.click()">
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="1.6">
                                                <rect x="3" y="4" width="18" height="16" rx="2"></rect>
                                                <circle cx="9" cy="10" r="1.6"></circle>
                                                <path d="M3 17l5-4.5 4 3.5 3-2.5 6 5"></path>
                                            </svg>
                                        </button>
                                        <!-- 해시태그 -->
                                        <button type="button" class="cm-icon-btn" title="해시태그" :disabled="!isLogin"
                                            @click="fnHash">
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="1.6">
                                                <path d="M9 3L7 21M17 3l-2 18M4 8.5h17M3 15.5h17"></path>
                                            </svg>
                                        </button>

                                        <!-- 구매한 상품 표시 (TODO: 구성품 기능 완료 후 연결, 지금은 공개안함 고정) -->
                                         <!-- 사용자 최근 일주일 구매 물건 목록 작게 띄워서 표시할상품 체크? 선택하는거 하고 공개. -->
                                        <label class="cm-switch disabled" title="준비 중인 기능이에요">
                                            <input type="checkbox" v-model="showPurchase" disabled>
                                            <span class="track"><span class="knob"></span></span>
                                            <em>구매한 상품 표시</em>
                                            <small>공개안함</small>
                                        </label>
                                    </div>

                                    <button type="button" class="cm-submit"
                                        :disabled="!isLogin || posting || content.trim() == ''"
                                        @click="fnWrite">게시</button>
                                </div>
                            </div>
                        </div>

                        <!-- 피드 -->
                        <div class="cm-feed">

                            <div class="cm-empty" v-if="!loading && postList.length == 0">
                                아직 올라온 소식이 없어요.
                            </div>

                            <article class="cm-post" v-for="p in postList" :key="p.postId">

                                <!-- 작성자 -->
                                <header class="cm-post-head">
                                    <div class="cm-avatar">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                                            <circle cx="12" cy="8" r="4"></circle>
                                            <path d="M4 21c0-4.4 3.6-7 8-7s8 2.6 8 7z"></path>
                                        </svg>
                                    </div>
                                    <div class="who">
                                        <div class="name">
                                            <strong>{{ p.displayName }}</strong>
                                            <!-- 로그인 방식 (TODO: 아이콘 이미지 생기면 <img> 로 교체) -->
                                            <span class="cm-social" v-if="p.socialType"
                                                :class="fnSocial(p.socialType).cls">{{ fnSocial(p.socialType).label
                                                }}</span>
                                        </div>
                                        <time>{{ fnAgo(p.createdAt) }}</time>
                                    </div>

                                    <!-- 더보기 (본인 글 또는 관리자) -->
                                    <div class="cm-more" v-if="p.memberId == memberId || isAdmin">
                                        <button type="button"
                                            @click.stop="menuId = (menuId == p.postId ? null : p.postId)">&middot;&middot;&middot;</button>
                                        <ul v-if="menuId == p.postId">
                                            <li><a href="javascript:;" @click="fnDelete(p)">삭제</a></li>
                                        </ul>
                                    </div>
                                </header>

                                <!-- 이미지 -->
                                <div class="cm-images" :class="'n' + Math.min((p.imageList || []).length, 4)"
                                    v-if="p.imageList && p.imageList.length > 0">
                                    <img v-for="img in p.imageList" :key="img.imageUrl" :src="img.imageUrl"
                                        :alt="img.imageOriginName">
                                </div>

                                <!-- 내용 -->
                                <p class="cm-text">{{ p.postContent }}</p>

                                <!-- 해시태그 -->
                                <div class="cm-tags" v-if="p.tagList && p.tagList.length > 0">
                                    <a href="javascript:;" v-for="t in p.tagList" :key="t" @click="fnTab(t)">{{ '#' + t
                                        }}</a>
                                </div>

                                <!-- 좋아요 / 댓글 -->
                                <footer class="cm-action">
                                    <button type="button" class="like" :class="{ on: p.liked == 1 }" @click="fnLike(p)">
                                        <svg width="22" height="22" viewBox="0 0 24 24" stroke="currentColor"
                                            stroke-width="1.6" :fill="p.liked == 1 ? 'currentColor' : 'none'">
                                            <path
                                                d="M12 20.5s-8-5-8-11A4.5 4.5 0 0 1 12 6.8 4.5 4.5 0 0 1 20 9.5c0 6-8 11-8 11z">
                                            </path>
                                        </svg>
                                        <span>{{ p.likeCnt }}</span>
                                    </button>
                                    <button type="button" class="comment" :class="{ on: p.open }"
                                        @click="fnToggleComment(p)">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
                                            stroke="currentColor" stroke-width="1.6">
                                            <path d="M4 5h16v11H9l-5 4z"></path>
                                        </svg>
                                        <span>{{ p.commentCnt }}</span>
                                    </button>
                                </footer>

                                <!-- 댓글 영역 (아래로 펼쳐짐) -->
                                <div class="cm-comments" :class="{ open: p.open }">
                                    <div class="cm-comments-inner">

                                        <div class="cm-c-state" v-if="p.cLoading">댓글을 불러오는 중...</div>
                                        <div class="cm-c-state" v-else-if="p.loaded && p.comments.length == 0">
                                            첫 댓글을 남겨보세요.
                                        </div>

                                        <!-- 댓글 목록 -->
                                        <ul class="cm-c-list">
                                            <li v-for="c in fnParents(p)" :key="c.commentId">

                                                <!-- 댓글 -->
                                                <div class="cm-c-item">
                                                    <div class="cm-c-body">
                                                        <div class="cm-c-top">
                                                            <strong>{{ c.displayName }}</strong>
                                                            <span class="cm-social" v-if="c.socialType"
                                                                :class="fnSocial(c.socialType).cls">{{
                                                                fnSocial(c.socialType).label }}</span>
                                                            <time>{{ fnAgo(c.createdAt) }}</time>
                                                        </div>
                                                        <p class="cm-c-text deleted"
                                                            v-if="c.commentStatus == 'DELETED'">삭제된 댓글입니다.</p>
                                                        <p class="cm-c-text" v-else>{{ c.commentContent }}</p>
                                                        <div class="cm-c-btns" v-if="c.commentStatus != 'DELETED'">
                                                            <a href="javascript:;" v-if="isLogin"
                                                                @click="fnReply(p, c, $event)">답글</a>
                                                            <a href="javascript:;" class="del"
                                                                v-if="c.memberId == memberId || isAdmin"
                                                                @click="fnCommentDelete(p, c)">삭제</a>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- 대댓글 -->
                                                <ul class="cm-c-reply" v-if="fnReplies(p, c.commentId).length > 0">
                                                    <li class="cm-c-item" v-for="r in fnReplies(p, c.commentId)"
                                                        :key="r.commentId">
                                                        <div class="cm-c-body">
                                                            <div class="cm-c-top">
                                                                <strong>{{ r.displayName }}</strong>
                                                                <span class="cm-social" v-if="r.socialType"
                                                                    :class="fnSocial(r.socialType).cls">{{
                                                                    fnSocial(r.socialType).label }}</span>
                                                                <time>{{ fnAgo(r.createdAt) }}</time>
                                                            </div>
                                                            <p class="cm-c-text">{{ r.commentContent }}</p>
                                                            <div class="cm-c-btns">
                                                                <a href="javascript:;" v-if="isLogin"
                                                                    @click="fnReply(p, r, $event)">답글</a>
                                                                <a href="javascript:;" class="del"
                                                                    v-if="r.memberId == memberId || isAdmin"
                                                                    @click="fnCommentDelete(p, r)">삭제</a>
                                                            </div>
                                                        </div>
                                                    </li>
                                                </ul>

                                            </li>
                                        </ul>

                                        <!-- 댓글 입력 -->
                                        <div class="cm-c-write">
                                            <div class="cm-c-to" v-if="p.replyTo">
                                                <span>{{ '@' + p.replyTo.name }}님에게 답글</span>
                                                <a href="javascript:;" @click="p.replyTo = null">취소</a>
                                            </div>
                                            <div class="cm-c-input">
                                                <input type="text" v-model="p.commentText" maxlength="1000"
                                                    :placeholder="isLogin ? '댓글을 입력하세요' : '로그인 후 댓글을 남길 수 있어요.'"
                                                    :disabled="!isLogin" @keyup.enter="fnCommentAdd(p)">
                                                <button type="button"
                                                    :disabled="!isLogin || p.cPosting || p.commentText.trim() == ''"
                                                    @click="fnCommentAdd(p)">등록</button>
                                            </div>
                                        </div>

                                    </div>
                                </div>

                            </article>

                            <div class="cm-loading" v-if="loading">불러오는 중...</div>

                            <!-- 페이징 -->
                            <div class="cm-paging" v-if="totalPage > 1">
                                <a href="javascript:;" class="nav" @click="fnPage(page - 1)">&lsaquo;</a>
                                <a href="javascript:;" v-for="n in pageList" :key="n" :class="{ on: n == page }"
                                    @click="fnPage(n)">{{ n }}</a>
                                <a href="javascript:;" class="nav" @click="fnPage(page + 1)">&rsaquo;</a>
                            </div>

                            <!-- 마지막 페이지 안내 -->
                            <div class="cm-end" v-if="!loading && postList.length > 0 && page >= totalPage">
                                더 이상 소식이 없어요.
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
                    postList: [],                           // 게시글 목록
                    isLogin: "${isLogin}" == "true",        // 로그인 여부 (서버에서도 다시 검사함)
                    memberId: Number("${memberId}"),        // 내 회원 번호 (내 글 표시용)
                    isAdmin: "${isAdmin}" == "true",        // 관리자 여부 (서버에서도 다시 검사함)
                    tag: "",                                // 선택된 해시태그 ("" 이면 전체)
                    page: 1,                                // 현재 페이지
                    pageSize: 5,                            // 한 페이지에 보여줄 개수 (서버와 동일)
                    pageBlock: 5,                           // 페이징 번호 몇 개씩 보여줄지
                    cnt: 0,                                 // 전체 게시글 수
                    loading: false,                         // 불러오는 중
                    token: 0,                               // 탭 전환 시 이전 요청 무시용

                    content: "",                            // 작성 내용
                    imageList: [],                          // 첨부한 이미지 정보
                    posting: false,                         // 등록 중
                    showPurchase: false,                    // 구매 상품 표시 (아직 사용 안 함)
                    menuId: null,                           // 더보기 메뉴가 열린 게시글

                    // 기본 탭
                    baseTab: ["감성템", "일상", "리뷰", "추천"]
                };
            },

            computed: {

                // 탭 목록 (전체 + 기본 태그, 그 외 태그를 골랐으면 그 태그도 추가)
                tabList() {
                    let self = this;
                    let arr = [{ label: "전체", value: "" }];
                    self.baseTab.forEach(function (t) {
                        arr.push({ label: "#" + t, value: t });
                    });
                    if (self.tag != "" && self.baseTab.indexOf(self.tag) == -1) {
                        arr.push({ label: "#" + self.tag, value: self.tag });
                    }
                    return arr;
                },

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

                // 목록 조회 (페이지 번호 방식)
                fnList: function () {
                    let self = this;
                    if (self.loading) return;

                    self.loading = true;
                    let token = self.token;
                    let param = { page: self.page };
                    if (self.tag != "") param.tag = self.tag;

                    $.ajax({
                        url: "http://localhost:8080/community/list.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (token != self.token) return;    // 탭이 바뀌었으면 무시
                            if (data.result == "success") {
                                data.list.forEach(function (p) {
                                    p.imageList = p.imageList || [];
                                    p.tagList = p.tagList || [];
                                    p.liking = false;
                                    // 댓글 영역용 값
                                    p.open = false;         // 펼쳐졌는지
                                    p.loaded = false;       // 댓글을 불러왔는지
                                    p.comments = [];        // 댓글 전체 (대댓글 포함)
                                    p.cLoading = false;     // 댓글 불러오는 중
                                    p.cPosting = false;     // 댓글 등록 중
                                    p.commentText = "";     // 입력 중인 댓글
                                    p.replyTo = null;       // 답글 대상 { id, name }
                                });
                                self.postList = data.list;
                                self.cnt = data.cnt;
                            } else {
                                alert("게시글을 불러오지 못했습니다.");
                            }
                        },
                        complete: function () {
                            if (token != self.token) return;
                            self.loading = false;
                        }
                    });
                },

                // 1페이지부터 다시 조회 (탭 변경, 글 등록 후)
                fnReset: function () {
                    let self = this;
                    self.token++;
                    self.page = 1;
                    self.loading = false;
                    self.fnList();
                },

                // 페이지 이동
                fnPage: function (n) {
                    let self = this;
                    if (n < 1 || n > self.totalPage || n == self.page) return;
                    self.page = n;
                    self.fnList();
                    window.scrollTo({ top: 0, behavior: "smooth" });
                },

                // 탭(해시태그) 선택
                fnTab: function (value) {
                    let self = this;
                    if (self.tag == value) return;
                    self.tag = value;
                    self.fnReset();
                },

                // 글 등록
                fnWrite: function () {
                    let self = this;

                    if (!self.isLogin) {
                        alert("로그인 후 이용해주세요.");
                        return;
                    }
                    if (self.content.trim() == "") {
                        alert("내용을 입력해주세요.");
                        return;
                    }

                    self.posting = true;
                    let param = {
                        postContent: self.content,
                        images: JSON.stringify(self.imageList)
                    };

                    $.ajax({
                        url: "http://localhost:8080/community/add.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                self.content = "";
                                self.imageList = [];
                                self.tag = "";      // 전체 탭으로 돌아가서 새 글이 바로 보이게
                                self.$nextTick(self.fnResize);
                                self.fnReset();
                            } else {
                                alert(data.msg || "등록에 실패했습니다.");
                            }
                        },
                        complete: function () {
                            self.posting = false;
                        }
                    });
                },

                // 글 삭제 (본인 글 또는 관리자)
                fnDelete: function (p) {
                    let self = this;
                    self.menuId = null;
                    if (!confirm("정말 삭제하시겠습니까?")) return;

                    let param = {
                        postId: p.postId
                    };

                    $.ajax({
                        url: "http://localhost:8080/community/delete.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                // 지운 뒤 목록을 다시 불러옴 (현재 페이지가 비면 이전 페이지로)
                                if (self.postList.length == 1 && self.page > 1) self.page--;
                                self.fnList();
                            } else {
                                alert(data.msg || "삭제에 실패했습니다.");
                            }
                        }
                    });
                },

                // 좋아요 토글 (한 계정당 1번, 다시 누르면 취소)
                fnLike: function (p) {
                    let self = this;
                    if (!self.isLogin) {
                        alert("로그인 후 이용해주세요.");
                        return;
                    }
                    if (p.liking) return;   // 처리 중이면 무시
                    p.liking = true;

                    let param = {
                        postId: p.postId
                    };

                    $.ajax({
                        url: "http://localhost:8080/community/like.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                p.liked = data.liked ? 1 : 0;
                                p.likeCnt = data.likeCnt;
                            } else {
                                alert(data.msg || "처리에 실패했습니다.");
                            }
                        },
                        complete: function () {
                            p.liking = false;
                        }
                    });
                },

                // 댓글 영역 열기/닫기 (처음 열 때만 불러옴)
                fnToggleComment: function (p) {
                    let self = this;
                    p.open = !p.open;
                    if (p.open && !p.loaded) self.fnCommentList(p);
                },

                // 댓글 목록 조회
                fnCommentList: function (p) {
                    let param = {
                        postId: p.postId
                    };
                    p.cLoading = true;

                    $.ajax({
                        url: "http://localhost:8080/community/comment-list.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                p.comments = data.list;
                                p.loaded = true;
                            } else {
                                alert("댓글을 불러오지 못했습니다.");
                            }
                        },
                        complete: function () {
                            p.cLoading = false;
                        }
                    });
                },

                // 최상위 댓글
                fnParents: function (p) {
                    return p.comments.filter(function (c) { return !c.parentCommentId; });
                },

                // 대댓글
                fnReplies: function (p, commentId) {
                    return p.comments.filter(function (c) { return c.parentCommentId == commentId; });
                },

                // 답글 달기 (대댓글에 답하면 같은 묶음에 붙음)
                fnReply: function (p, c, e) {
                    p.replyTo = { id: c.parentCommentId || c.commentId, name: c.displayName };
                    let inner = e.target.closest(".cm-comments-inner");
                    let box = inner ? inner.querySelector(".cm-c-input input") : null;
                    if (box) box.focus();
                },

                // 댓글 등록
                fnCommentAdd: function (p) {
                    let self = this;
                    if (!self.isLogin) {
                        alert("로그인 후 이용해주세요.");
                        return;
                    }
                    if (p.commentText.trim() == "" || p.cPosting) return;
                    p.cPosting = true;

                    let param = {
                        postId: p.postId,
                        commentContent: p.commentText
                    };
                    if (p.replyTo) param.parentCommentId = p.replyTo.id;

                    $.ajax({
                        url: "http://localhost:8080/community/comment-add.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                p.commentText = "";
                                p.replyTo = null;
                                p.commentCnt = data.commentCnt;
                                self.fnCommentList(p);
                            } else {
                                alert(data.msg || "댓글 등록에 실패했습니다.");
                            }
                        },
                        complete: function () {
                            p.cPosting = false;
                        }
                    });
                },

                // 댓글 삭제 (본인 댓글 또는 관리자)
                fnCommentDelete: function (p, c) {
                    let self = this;
                    if (!confirm("댓글을 삭제하시겠습니까?")) return;

                    let param = {
                        commentId: c.commentId,
                        postId: p.postId
                    };

                    $.ajax({
                        url: "http://localhost:8080/community/comment-delete.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,

                        success: function (data) {
                            console.log(data);
                            if (data.result == "success") {
                                p.commentCnt = data.commentCnt;
                                self.fnCommentList(p);
                            } else {
                                alert(data.msg || "삭제에 실패했습니다.");
                            }
                        }
                    });
                },

                // 이미지 선택 (최대 4장)
                fnImageSelect: function (e) {
                    let self = this;
                    let files = Array.from(e.target.files);
                    e.target.value = "";    // 같은 파일 다시 선택 가능하게 초기화

                    if (self.imageList.length + files.length > 4) {
                        alert("이미지는 최대 4장까지 올릴 수 있습니다.");
                        return;
                    }

                    files.forEach(function (file) {
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
                    });
                },

                // 첨부 이미지 제거
                fnImageRemove: function (idx) {
                    this.imageList.splice(idx, 1);
                },

                // 커서 위치에 # 넣기
                fnHash: function () {
                    let self = this;
                    if (self.content.length >= 1000) return;

                    let ta = self.$refs.content;
                    let pos = ta.selectionStart;
                    self.content = self.content.slice(0, pos) + "#" + self.content.slice(pos);

                    self.$nextTick(function () {
                        ta.focus();
                        ta.setSelectionRange(pos + 1, pos + 1);
                        self.fnResize();
                    });
                },

                // 입력창 높이 자동 조절
                fnResize: function () {
                    let ta = this.$refs.content;
                    ta.style.height = "auto";
                    ta.style.height = Math.min(ta.scrollHeight, 240) + "px";
                },

                // 로그인 방식 표시 (TODO: 아이콘 이미지 생기면 경로로 교체)
                fnSocial: function (type) {
                    let map = {
                        GOOGLE: { label: "구글", cls: "google" },
                        NAVER: { label: "네이버", cls: "naver" },
                        KAKAO: { label: "카카오", cls: "kakao" }
                    };
                    return map[type] || { label: type, cls: "" };
                },

                // 작성 시간 (2시간 전)
                fnAgo: function (str) {
                    if (!str) return "";
                    let time = new Date(str.replace(" ", "T"));
                    let min = Math.floor((new Date() - time) / 60000);

                    if (min < 1) return "방금 전";
                    if (min < 60) return min + "분 전";
                    if (min < 60 * 24) return Math.floor(min / 60) + "시간 전";
                    if (min < 60 * 24 * 7) return Math.floor(min / (60 * 24)) + "일 전";
                    return str.substring(0, 10).replace(/-/g, ".");
                }

            },

            mounted() {
                let self = this;
                self.fnList();

                // 바깥을 누르면 더보기 메뉴 닫기
                document.addEventListener("click", function () {
                    self.menuId = null;
                });
            }

        });

        app.mount('#app');
    </script>