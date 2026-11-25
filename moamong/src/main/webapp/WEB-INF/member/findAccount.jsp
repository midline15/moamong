<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 - 아이디 / 비밀번호 찾기</title>
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
                <span class="auth-eyebrow">ACCOUNT RECOVERY</span>
                <h2 class="auth-title">계정 찾기</h2>

                <div class="auth-tabs">
                    <div class="auth-tab" :class="{ active: tab === 'ID' }" @click="fnSwitchTab('ID')">아이디 찾기</div>
                    <div class="auth-tab" :class="{ active: tab === 'PW' }" @click="fnSwitchTab('PW')">비밀번호 재설정</div>
                </div>

                <!-- 1. 아이디 찾기 탭 -->
                <div v-if="tab === 'ID'">
                    <div class="auth-group">
                        <label class="auth-label">이름</label>
                        <input type="text" class="auth-input" v-model="idForm.memberName" placeholder="가입 시 등록한 이름">
                    </div>
                    <div class="auth-group">
                        <label class="auth-label">이메일</label>
                        <input type="email" class="auth-input" v-model="idForm.email" placeholder="example@email.com" @keyup.enter="fnFindId">
                    </div>
                    <button class="auth-btn auth-btn-gold" @click="fnFindId">아이디 찾기</button>

                    <div v-if="idResult" class="auth-result-card">
                        <div v-if="idResult.isSocial">
                            <strong>{{ idResult.socialType }}</strong> 소셜 로그인으로 가입된 계정입니다.<br>
                            로그인 화면에서 소셜 간편 로그인을 이용해주세요.
                        </div>
                        <div v-else>
                            회원님의 아이디는<br>
                            <strong style="font-size:18px; color:#765a36;">{{ idResult.loginId }}</strong> 입니다.
                        </div>
                    </div>
                </div>

                <!-- 2. 비밀번호 재설정 탭 -->
                <div v-if="tab === 'PW'">
                    <div class="auth-group">
                        <label class="auth-label">아이디</label>
                        <input type="text" class="auth-input" v-model="pwForm.loginId" :disabled="isVerified" placeholder="아이디 입력">
                    </div>
                    <div class="auth-group">
                        <label class="auth-label">이름</label>
                        <input type="text" class="auth-input" v-model="pwForm.memberName" :disabled="isVerified" placeholder="이름 입력">
                    </div>
                    <div class="auth-group">
                        <label class="auth-label">이메일</label>
                        <input type="email" class="auth-input" v-model="pwForm.email" :disabled="isVerified" placeholder="가입 시 등록한 이메일">
                    </div>

                    <button v-if="!isVerified" class="auth-btn auth-btn-gold" @click="fnVerifyReset">본인 확인</button>

                    <div v-if="isVerified" style="margin-top:18px; padding-top:18px; border-top:1px dashed #dfd1bd;">
                        <div class="auth-group">
                            <label class="auth-label">새 비밀번호 (4자 이상)</label>
                            <input type="password" class="auth-input" v-model="pwForm.newPwd" placeholder="새 비밀번호 입력">
                        </div>
                        <div class="auth-group">
                            <label class="auth-label">새 비밀번호 확인</label>
                            <input type="password" class="auth-input" v-model="pwForm.confirmPwd" placeholder="새 비밀번호 재입력" @keyup.enter="fnResetPassword">
                        </div>
                        <button class="auth-btn auth-btn-gold" @click="fnResetPassword">비밀번호 변경하기</button>
                    </div>
                </div>

                <div class="auth-links">
                    <a href="/member/login.do">로그인으로 돌아가기</a>
                    <span>|</span>
                    <a href="/member/join.do">회원가입</a>
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
                tab: "ID",
                idForm: {
                    memberName: "",
                    email: ""
                },
                idResult: null,
                isVerified: false,
                pwForm: {
                    loginId: "",
                    memberName: "",
                    email: "",
                    newPwd: "",
                    confirmPwd: ""
                }
            };
        },
        methods: {
            fnSwitchTab(target) {
                this.tab = target;
                this.idResult = null;
                this.isVerified = false;
            },
            fnFindId() {
                let self = this;
                if (!this.idForm.memberName.trim()) { alert("이름을 입력해주세요."); return; }
                if (!this.idForm.email.trim()) { alert("이메일을 입력해주세요."); return; }
                
                $.ajax({
                    url: "/member/find-id.dox",
                    type: "POST",
                    data: {
                        memberName: this.idForm.memberName.trim(),
                        email: this.idForm.email.trim()
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            self.idResult = data;
                        } else {
                            self.idResult = null;
                            alert(data.message || "일치하는 회원이 없습니다.");
                        }
                    }
                });
            },
            fnVerifyReset() {
                let self = this;
                if (!this.pwForm.loginId.trim() || !this.pwForm.memberName.trim() || !this.pwForm.email.trim()) {
                    alert("아이디, 이름, 이메일을 모두 입력해주세요.");
                    return;
                }
                
                $.ajax({
                    url: "/member/verify-reset.dox",
                    type: "POST",
                    data: {
                        loginId: this.pwForm.loginId.trim(),
                        memberName: this.pwForm.memberName.trim(),
                        email: this.pwForm.email.trim()
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            alert(data.message);
                            self.isVerified = true;
                        } else {
                            alert(data.message || "본인 확인에 실패했습니다.");
                        }
                    }
                });
            },
            fnResetPassword() {
                if (!this.pwForm.newPwd || this.pwForm.newPwd.trim().length < 4) {
                    alert("새 비밀번호는 4자 이상 입력해주세요.");
                    return;
                }
                if (this.pwForm.newPwd !== this.pwForm.confirmPwd) {
                    alert("새 비밀번호와 확인 비밀번호가 일치하지 않습니다.");
                    return;
                }
                
                $.ajax({
                    url: "/member/reset-password.dox",
                    type: "POST",
                    data: {
                        loginId: this.pwForm.loginId.trim(),
                        memberName: this.pwForm.memberName.trim(),
                        email: this.pwForm.email.trim(),
                        newPwd: this.pwForm.newPwd.trim()
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            alert(data.message);
                            location.href = "/member/login.do";
                        } else {
                            alert(data.message || "비밀번호 변경에 실패했습니다.");
                        }
                    }
                });
            }
        }
    });
    
    app.mount('#app');
</script>
