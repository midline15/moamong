<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 마이페이지</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <!-- 공통 레이아웃 CSS (헤더 · 사이드바 · 푸터 · 마이페이지) -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypage.css">
    </head>
    <body>
        <%@ include file="/WEB-INF/common/header.jsp"%>

        <div id="app" class="mp-wrap">
            <% request.setAttribute("activeMenu", "home"); %>
            <%@ include file="/WEB-INF/common/mypageSidebar.jsp"%>

            <main class="mp-content">
                <div class="mp-head">
                    <h2>마이페이지</h2>
                    <span class="mp-breadcrumb">홈 &gt; 마이페이지</span>
                </div>

                <!-- 회원 프로필 요약 -->
                <div class="mp-card" style="display:flex; justify-content:space-between; align-items:center;">
                    <div>
                        <div style="font-size:18px; font-weight:700;">
                            {{ member.memberName }}님
                            <span style="font-size:13px; font-weight:500; color:#94764b; margin-left:6px;">
                                ({{ member.socialType ? member.socialType : member.loginId }})
                            </span>
                        </div>
                        <div style="font-size:13px; color:#85817b; margin-top:6px;">
                            이메일: {{ member.email }} · 등급: {{ member.role }}
                        </div>
                    </div>
                    <button class="mp-btn mp-btn-gold" @click="fnGoEdit">내 정보 관리</button>
                </div>

                <!-- 핵심 메뉴 요약 카드 -->
                <div style="display:grid; grid-template-columns:repeat(3, 1fr); gap:14px; margin-top:20px;">
                    <div class="mp-card" style="cursor:pointer; text-align:center;" @click="fnGoOrderList">
                        <div style="font-size:12px; color:#85817b;">주문/배송</div>
                        <div style="font-size:17px; font-weight:700; margin-top:6px;">주문 목록 &rarr;</div>
                    </div>
                    <div class="mp-card" style="cursor:pointer; text-align:center;" @click="fnGoCancelList">
                        <div style="font-size:12px; color:#85817b;">취소/반품/환불</div>
                        <div style="font-size:17px; font-weight:700; margin-top:6px;">반품 목록 &rarr;</div>
                    </div>
                    <div class="mp-card" style="cursor:pointer; text-align:center;" @click="fnGoAddress">
                        <div style="font-size:12px; color:#85817b;">배송지 설정</div>
                        <div style="font-size:17px; font-weight:700; margin-top:6px;">배송지 관리 &rarr;</div>
                    </div>
                </div>
            </main>
        </div>

        <%@ include file="/WEB-INF/common/footer.jsp"%>
    </body>

</html>

<script>
    const app = Vue.createApp({
        data() {
            return {
                member: {
                    loginId: "",
                    memberName: "",
                    email: "",
                    role: "",
                    socialType: null,
                    memberId: ""
                }
            };
        },
        methods: {
            fnGetMyInfo() {
                let self = this;
                $.ajax({
                    url: "/member/myinfo.dox",
                    type: "POST",
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            self.member = data.member;
                        }
                    }
                });
            },
            fnGoEdit() { location.href = "/member/edit.do"; },
            fnGoOrderList() { location.href = "/order/list.do"; },
            fnGoCancelList() { location.href = "/order/cancel-list.do"; },
            fnGoAddress() { location.href = "/address/list.do"; }
        },
        mounted() {
            this.fnGetMyInfo();
        }
    });
    app.mount('#app');
</script>
