<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 회원가입</title>
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
                <span class="auth-eyebrow">JOIN MOAMONG</span>
                <h2 class="auth-title">회원가입</h2>

                <!-- 피그마 시안 반영: 약관 동의 영역 -->
                <div class="terms-box">
                    <label class="terms-item terms-all">
                        <input type="checkbox" v-model="agreeAll" @change="fnToggleAll">
                        <span>약관 전체 동의</span>
                    </label>
                    <label class="terms-item">
                        <input type="checkbox" v-model="agreeTerms" @change="fnSyncAll">
                        <span>[필수] 모아몽 이용약관 동의</span>
                    </label>
                    <label class="terms-item">
                        <input type="checkbox" v-model="agreePrivacy" @change="fnSyncAll">
                        <span>[필수] 개인정보 수집 및 이용 동의</span>
                    </label>
                </div>

                <div class="auth-group">
                    <label class="auth-label">아이디 *</label>
                    <div class="auth-input-row">
                        <input class="auth-input" v-model="loginId" @input="isIdChecked = false" placeholder="영문, 숫자 4~20자">
                        <button type="button" class="auth-btn auth-btn-gold auth-btn-sm" @click="fnIdCheck">중복확인</button>
                    </div>
                    <div v-if="isIdChecked" style="font-size:12px; color:#2b8a3e; margin-top:5px;">✓ 사용 가능한 아이디입니다.</div>
                </div>

                <div class="auth-group">
                    <label class="auth-label">비밀번호 *</label>
                    <input class="auth-input" type="password" v-model="password" placeholder="영문, 숫자, 특수문자 포함 8자 이상">
                </div>

                <div class="auth-group">
                    <label class="auth-label">비밀번호 확인 *</label>
                    <input class="auth-input" type="password" v-model="passwordConfirm" placeholder="비밀번호 재입력">
                </div>

                <div class="auth-group">
                    <label class="auth-label">이름 *</label>
                    <input class="auth-input" v-model="memberName" placeholder="실명 입력">
                </div>

                <div class="auth-group">
                    <label class="auth-label">이메일 *</label>
                    <input class="auth-input" v-model="email" placeholder="example@domain.com">
                </div>

                <div class="auth-group">
                    <label class="auth-label">휴대폰 번호 <span style="font-weight:400; color:#9a8f80;">(선택)</span></label>
                    <input class="auth-input" v-model="phone" placeholder="010-0000-0000">
                </div>

                <button class="auth-btn auth-btn-gold" @click="fnJoin" style="margin-top:10px;">가입 완료하기</button>
                <div class="auth-links">
                    <a href="/member/login.do">이미 계정이 있으신가요? 로그인</a>
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
                agreeAll: false,
                agreeTerms: false,
                agreePrivacy: false,
                loginId: "",
                password: "",
                passwordConfirm: "",
                memberName: "",
                email: "",
                phone: "",
                isIdChecked: false
            };
        },
        methods: {
            fnToggleAll() {
                this.agreeTerms = this.agreeAll;
                this.agreePrivacy = this.agreeAll;
            },
            fnSyncAll() {
                this.agreeAll = this.agreeTerms && this.agreePrivacy;
            },
            fnIdCheck: function () {
                let self = this;
                let idRegex = /^[a-zA-Z0-9]{4,20}$/;
                if (!idRegex.test(self.loginId.trim())) {
                    alert("아이디는 영문 또는 숫자 4~20자로 입력해주세요.");
                    return;
                }
                $.ajax({
                    url: "/member/id-duplicate-check.dox",
                    dataType: "json",
                    type: "POST",
                    data: { loginId: self.loginId.trim() },
                    success: function (data) {
                        alert(data.message);
                        self.isIdChecked = (data.result === "success" && !data.isDuplicate);
                    }
                });
            },
            fnJoin: function () {
                let self = this;
                let pwdRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;
                let emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
                let phoneRegex = /^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$/;
                
                if (!self.agreeTerms || !self.agreePrivacy) {
                    alert("필수 약관에 모두 동의해주세요.");
                    return;
                }
                if (!self.isIdChecked) {
                    alert("아이디 중복확인을 먼저 완료해주세요.");
                    return;
                }
                if (!pwdRegex.test(self.password)) {
                    alert("비밀번호는 영문, 숫자, 특수문자(@$!%*#?&)를 포함해 8자 이상으로 입력해주세요.");
                    return;
                }
                if (self.password !== self.passwordConfirm) {
                    alert("비밀번호 확인이 일치하지 않습니다.");
                    return;
                }
                if (!self.memberName || self.memberName.trim() === "") {
                    alert("이름을 입력해주세요.");
                    return;
                }
                if (!emailRegex.test(self.email.trim())) {
                    alert("올바른 이메일 형식을 입력해주세요.");
                    return;
                }
                if (self.phone.trim() !== "" && !phoneRegex.test(self.phone.trim())) {
                    alert("휴대폰 번호는 010-0000-0000 형식으로 입력해주세요.");
                    return;
                }
                
                $.ajax({
                    url: "/member/join.dox",
                    dataType: "json",
                    type: "POST",
                    data: {
                        loginId: self.loginId.trim(),
                        password: self.password,
                        memberName: self.memberName.trim(),
                        email: self.email.trim(),
                        phone: self.phone.trim()
                    },
                    success: function (data) {
                        alert(data.message);
                        if (data.result === "success") location.href = "/member/login.do";
                    }
                });
            }
        }
    });
    app.mount('#app');
</script>
