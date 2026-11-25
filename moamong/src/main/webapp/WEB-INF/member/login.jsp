<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 로그인</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <!-- 공통 레이아웃 & 로그인/회원가입/아이디,비번찾기 전용 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member/auth.css">
    </head>
    <body>
        <%@ include file="/WEB-INF/common/header.jsp"%>

        <main id="app" class="auth-wrap">
            <div class="auth-card">
                <span class="auth-eyebrow">WELCOME TO MOAMONG</span>
                <h2 class="auth-title">로그인</h2>

                <div class="auth-group">
                    <input class="auth-input" v-model="memberId" @keyup.enter="fnLogin" placeholder="아이디를 입력해주세요">
                </div>

                <div class="auth-group">
                    <input class="auth-input" type="password" v-model="password" @keyup.enter="fnLogin" placeholder="비밀번호를 입력해주세요">
                </div>

                <button class="auth-btn auth-btn-gold" @click="fnLogin" style="margin-top:6px;">로그인</button>

                <div class="auth-benefit-tip">
                    첫 구매라면 <strong>누구나 10% 할인쿠폰</strong> 혜택을 드립니다!
                </div>

                <div class="auth-links">
                    <a href="/member/join.do" style="font-weight:700; color:#765a36;">회원가입</a>
                    <span>|</span>
                    <a href="/member/find-account.do">아이디 / 비밀번호 찾기</a>
                </div>

                <div class="auth-divider">간편 소셜 로그인</div>
                <div class="social-circle-group">
                    <button type="button" class="social-circle-btn social-kakao" title="카카오 로그인" @click="fnSocialLogin('KAKAO')">K</button>
                    <button type="button" class="social-circle-btn social-naver" title="네이버 로그인" @click="fnSocialLogin('NAVER')">N</button>
                    <button type="button" class="social-circle-btn social-google" title="구글 로그인" @click="fnSocialLogin('GOOGLE')">G</button>
                </div>
            </div>

            <!-- 휴면 계정 해제 모달 -->
            <div v-if="showDormantModal" class="auth-modal-overlay">
                <div class="auth-modal-box">
                    <h3 style="margin-bottom:10px; font-size:18px; color:#765a36;">휴면 계정 안내</h3>
                    <p style="font-size:13px; color:#5c5346; line-height:1.6; margin-bottom:16px;" v-if="!isSocialDormant">
                        30일 이상 미접속으로 휴면 전환된 계정입니다.<br>
                        비밀번호를 다시 입력해 휴면을 해제해주세요.
                    </p>
                    <p style="font-size:13px; color:#5c5346; line-height:1.6; margin-bottom:16px;" v-else>
                        30일 이상 미접속으로 휴면 전환된 소셜 계정입니다.<br>
                        아래 버튼을 누르시면 휴면이 즉시 해제됩니다.
                    </p>
                    <div class="auth-group" v-if="!isSocialDormant">
                        <input class="auth-input" ref="dormantInput" type="password" v-model="dormantPwd"
                        @keyup.enter="fnActivateDormant" placeholder="비밀번호 확인">
                    </div>
                    <div style="display:flex; gap:8px; margin-top:12px;">
                        <button class="auth-btn auth-btn-gold" @click="fnActivateDormant">휴면 해제</button>
                        <button class="auth-btn" @click="showDormantModal = false; dormantPwd = '';">취소</button>
                    </div>
                </div>
            </div>
        </main>

        <%@ include file="/WEB-INF/common/footer.jsp"%>
    </body>
</html>
<script>
    const app = Vue.createApp({
        data() {
            return {
                memberId: "",
                password: "",
                showDormantModal: false,
                isSocialDormant: false,
                dormantPwd: ""
            };
        },
        mounted() {
            const params = new URLSearchParams(window.location.search);
            if (params.get("dormant") === "social") {
                this.isSocialDormant = true;
                this.showDormantModal = true;
            }
        },
        methods: {
            fnLogin: function () {
                let self = this;
                if (!self.memberId || self.memberId.trim() === "") {
                    alert("아이디를 입력해주세요.");
                    return;
                }
                if (!self.password || self.password.trim() === "") {
                    alert("비밀번호를 입력해주세요.");
                    return;
                }
                $.ajax({
                    url: "/member/login.dox",
                    dataType: "json",
                    type: "POST",
                    data: { memberId: self.memberId.trim(), pwd: self.password },
                    success: function (data) {
                        if (data.isInactive) {
                            self.isSocialDormant = false;
                            self.showDormantModal = true;
                            self.$nextTick(() => {
                                if (self.$refs.dormantInput) self.$refs.dormantInput.focus();
                            });
                            return;
                        }
                        alert(data.message);
                        if (data.loginFlg) location.href = "/";
                    }
                });
            },
            fnActivateDormant: function () {
                let self = this;
                let url = self.isSocialDormant ? "/member/activate-social-dormant.dox" : "/member/activate-dormant.dox";
                let param = self.isSocialDormant ? {} : { memberId: self.memberId.trim(), pwd: self.dormantPwd };
                if (!self.isSocialDormant && (!self.dormantPwd || self.dormantPwd.trim() === "")) {
                    alert("비밀번호를 입력해주세요.");
                    return;
                }
                $.ajax({
                    url: url,
                    dataType: "json",
                    type: "POST",
                    data: param,
                    success: function (data) {
                        alert(data.message);
                        if (data.result === "success") location.href = "/";
                    }
                });
            },
            fnJoin: function () { location.href = "/member/join.do"; },
            fnSocialLogin: function (provider) { location.href = "/oauth2/authorization/" + provider.toLowerCase(); }
        }
    });
    app.mount('#app');
</script>
