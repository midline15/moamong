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

            <!-- DB POLICY 테이블 연동 약관 동의 영역 -->
            <div class="terms-box">
                <label class="terms-item terms-all">
                    <input type="checkbox" v-model="agreeAll" @change="fnToggleAll">
                    <span>약관 전체 동의 (선택항목 포함)</span>
                </label>

                <div v-for="p in policies" :key="p.policyId"
                     style="display:flex; justify-content:space-between; align-items:center; padding:6px 0;">
                    <label class="terms-item" style="padding:0; flex:1;">
                        <input type="checkbox" :value="p.policyType" v-model="agreedTypes" @change="fnSyncAll">
                        <span>
                            <strong>[{{ p.isRequired === 'Y' ? '필수' : '선택' }}]</strong> {{ p.title }}
                        </span>
                    </label>
                    <button type="button"
                            style="font-size:12px; color:#94764b; text-decoration:underline; background:none; border:none; cursor:pointer;"
                            @click="activePolicy = p">
                        상세보기
                    </button>
                </div>
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

        <!-- 약관 상세 내용 팝업 모달 -->
        <div v-if="activePolicy" class="auth-modal-overlay" @click.self="activePolicy = null">
            <div class="auth-modal-box" style="max-width:480px;">
                <div style="display:flex; justify-content:space-between; align-items:center; padding-bottom:12px; border-bottom:1px solid #e3d6c1; margin-bottom:14px;">
                    <strong style="font-size:16px; color:#765a36;">
                        [{{ activePolicy.isRequired === 'Y' ? '필수' : '선택' }}] {{ activePolicy.title }}
                    </strong>
                    <button type="button" style="font-size:16px; color:#85817b;" @click="activePolicy = null">✕</button>
                </div>
                <div style="max-height:320px; overflow-y:auto; font-size:13px; color:#5c5346; line-height:1.65; white-space:pre-wrap; padding-right:4px;">{{ activePolicy.content }}</div>
                <div style="display:flex; gap:8px; margin-top:18px;">
                    <button type="button" class="auth-btn auth-btn-gold" @click="fnAgreeFromModal(activePolicy.policyType)">동의하고 닫기</button>
                    <button type="button" class="auth-btn" @click="activePolicy = null">닫기</button>
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
                policies: [],
                agreedTypes: [],
                agreeAll: false,
                activePolicy: null,
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
            fnLoadPolicies() {
                let self = this;
                $.ajax({
                    url: "/member/policies.dox",
                    type: "POST",
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            self.policies = data.list || [];
                        }
                    }
                });
            },
            fnToggleAll() {
                this.agreedTypes = this.agreeAll ? this.policies.map(p => p.policyType) : [];
            },
            fnSyncAll() {
                this.agreeAll = this.policies.length > 0 && this.agreedTypes.length === this.policies.length;
            },
            fnAgreeFromModal(policyType) {
                if (!this.agreedTypes.includes(policyType)) {
                    this.agreedTypes.push(policyType);
                    this.fnSyncAll();
                }
                this.activePolicy = null;
            },
            fnIdCheck() {
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
            fnJoin() {
                let self = this;
                const missingRequired = self.policies.filter(p => p.isRequired === "Y" && !self.agreedTypes.includes(p.policyType));
                if (missingRequired.length > 0) {
                    alert("[" + missingRequired[0].title + "] 필수 약관에 동의해주세요.");
                    return;
                }

                let pwdRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;
                let emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
                let phoneRegex = /^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$/;

                if (!self.isIdChecked) { alert("아이디 중복확인을 먼저 완료해주세요."); return; }
                if (!pwdRegex.test(self.password)) { alert("비밀번호는 영문, 숫자, 특수문자(@$!%*#?&)를 포함해 8자 이상으로 입력해주세요."); return; }
                if (self.password !== self.passwordConfirm) { alert("비밀번호 확인이 일치하지 않습니다."); return; }
                if (!self.memberName || self.memberName.trim() === "") { alert("이름을 입력해주세요."); return; }
                if (!emailRegex.test(self.email.trim())) { alert("올바른 이메일 형식을 입력해주세요."); return; }
                if (self.phone.trim() !== "" && !phoneRegex.test(self.phone.trim())) { alert("휴대폰 번호는 010-0000-0000 형식으로 입력해주세요."); return; }

                $.ajax({
                    url: "/member/join.dox",
                    dataType: "json",
                    type: "POST",
                    data: {
                        loginId: self.loginId.trim(),
                        password: self.password,
                        memberName: self.memberName.trim(),
                        email: self.email.trim(),
                        phone: self.phone.trim(),
                        marketingAgreed: self.agreedTypes.includes("MARKETING") ? "Y" : "N"
                    },
                    success: function (data) {
                        alert(data.message);
                        if (data.result === "success") location.href = "/member/login.do";
                    }
                });
            }
        },
        mounted() {
            this.fnLoadPolicies();
        }
    });
    app.mount('#app');
</script>