<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <title>모아몽 - 작성글 관리</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypage.css">
    </head>
    <body>
        <%@ include file="/WEB-INF/common/header.jsp"%>

        <div id="app" class="mp-wrap">
            <%@ include file="/WEB-INF/common/mypageSidebar.jsp"%>

            <main class="mp-main">
                <div class="mp-head">
                    <h2>작성글 관리</h2>
                    <span style="font-size:13px; color:#85817b;">총 <strong>{{ list.length }}</strong>건</span>
                </div>

                <div v-if="list.length === 0" class="mp-card" style="text-align:center; padding:60px 20px; color:#85817b;">
                    작성한 STORY 게시글이 없습니다.
                    <div style="margin-top:16px;">
                        <a href="/community/list.do" class="mp-btn mp-btn-gold">STORY 구경하러 가기</a>
                    </div>
                </div>

                <div v-for="item in list" :key="item.postId" class="mp-card" style="display:flex; gap:16px; align-items:center;">
                    <img v-if="item.thumbnailUrl" :src="item.thumbnailUrl" alt="썸네일"
                    style="width:72px; height:72px; border-radius:8px; object-fit:cover; border:1px solid #e3d6c1; flex-shrink:0;">

                    <div style="flex:1; min-width:0;">
                        <div style="display:flex; align-items:center; gap:8px; margin-bottom:6px;">
                            <span class="mp-badge">{{ item.postStatus === 'HIDDEN' ? '관리자 숨김' : 'STORY' }}</span>
                            <span style="font-size:12px; color:#85817b;">{{ item.createdAt }}</span>
                        </div>
                        <div style="font-size:14px; font-weight:600; color:#29251f; line-height:1.5; word-break:break-word;">
                            {{ item.postStatus === 'HIDDEN' ? '관리자에 의해 숨김 처리된 게시글입니다.' : item.postContent }}
                        </div>
                        <div style="font-size:12px; color:#85817b; margin-top:6px;">
                            ♥ 좋아요 {{ item.likeCnt }} · 💬 댓글 {{ item.commentCnt }}
                        </div>
                    </div>

                    <div style="display:flex; flex-direction:column; gap:6px; flex-shrink:0;">
                        <a :href="'/community/list.do?postId=' + item.postId" class="mp-btn">STORY 이동</a>
                        <button type="button" class="mp-btn mp-btn-danger" @click="fnRemove(item.postId)">삭제</button>
                    </div>
                </div>
            </main>
        </div>

        <%@ include file="/WEB-INF/common/footer.jsp"%>
    </body>
</html>
<script>
    const app = Vue.createApp({
        data() { return { list: [] }; },
        methods: {
            fnLoad() {
                $.post("/member/mypost-list.dox", (res) => {
                    if (res.result === "success") this.list = res.list || [];
                }, "json");
            },
            
            fnGoOrigin(item) {
                const pid = item.postId || item.POST_ID || item.post_id;
                sessionStorage.setItem("targetPostId", pid);
                sessionStorage.removeItem("targetCommentId");
                location.href = "/community/list.do";
            },
            
            fnRemove(postId) {
                if (!confirm("작성한 게시글을 삭제하시겠습니까?")) return;
                $.post("/member/mypost-remove.dox", { postId: postId }, (res) => {
                    alert(res.message);
                    if (res.result === "success") this.fnLoad();
                }, "json");
            }
        },
        mounted() { this.fnLoad(); }
    });
    app.mount("#app");
</script>
