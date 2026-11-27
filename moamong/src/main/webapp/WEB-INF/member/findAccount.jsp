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
                        <input type="text" class="auth-input" v-model="idForm.memberName" :disabled="idAuthSent" placeholder="가입 시 등록한 이름">
                    </div>
                    <div class="auth-group">
                        <label class="auth-label">이메일</label>
                        <div style="display:flex; gap:8px;">
                            <input type="email" class="auth-input" v-model="idForm.email" :disabled="idAuthSent" placeholder="example@email.com" style="flex:1;">
                            <button type="button" class="auth-btn auth-btn-gold" :disabled="isSending" @click="fnSendAuthCode('ID')" style="width:auto; padding:0 14px; white-space:nowrap;">
                                {{ isSending ? '발송중...' : (idAuthSent ? '재발송' : '인증번호 발송') }}
                            </button>
                        </div>
                    </div>
                    <div class="auth-group" v-if="idAuthSent && !idResult">
                        <label class="auth-label">인증번호 6자리</label>
                        <div style="display:flex; gap:8px;">
                            <input type="text" class="auth-input" v-model="idAuthCode" maxlength="6" placeholder="메일로 받은 6자리 숫자" style="flex:1;" @keyup.enter="fnVerifyIdCode">
                            <button type="button" class="auth-btn auth-btn-gold" @click="fnVerifyIdCode" style="width:auto; padding:0 16px; white-space:nowrap;">인증확인</button>
                        </div>
                    </div>

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
                        <input type="text" class="auth-input" v-model="pwForm.loginId" :disabled="pwAuthSent || isVerified" placeholder="아이디 입력">
                    </div>
                    <div class="auth-group">
                        <label class="auth-label">이름</label>
                        <input type="text" class="auth-input" v-model="pwForm.memberName" :disabled="pwAuthSent || isVerified" placeholder="이름 입력">
                    </div>
                    <div class="auth-group">
                        <label class="auth-label">이메일</label>
                        <div style="display:flex; gap:8px;">
                            <input type="email" class="auth-input" v-model="pwForm.email" :disabled="pwAuthSent || isVerified" placeholder="가입 시 등록한 이메일" style="flex:1;">
                            <button v-if="!isVerified" type="button" class="auth-btn auth-btn-gold" :disabled="isSending" @click="fnSendAuthCode('PW')" style="width:auto; padding:0 14px; white-space:nowrap;">
                                {{ isSending ? '발송중...' : (pwAuthSent ? '재발송' : '인증번호 발송') }}
                            </button>
                        </div>
                    </div>
                    <div class="auth-group" v-if="pwAuthSent && !isVerified">
                        <label class="auth-label">인증번호 6자리</label>
                        <div style="display:flex; gap:8px;">
                            <input type="text" class="auth-input" v-model="pwAuthCode" maxlength="6" placeholder="메일로 받은 6자리 숫자" style="flex:1;" @keyup.enter="fnVerifyPwCode">
                            <button type="button" class="auth-btn auth-btn-gold" @click="fnVerifyPwCode" style="width:auto; padding:0 16px; white-space:nowrap;">인증확인</button>
                        </div>
                    </div>

                    <div v-if="isVerified" style="margin-top:18px; padding-top:18px; border-top:1px dashed #dfd1bd;">
                        <div class="auth-group">
                            <label class="auth-label">새 비밀번호 (영문, 숫자, 특수문자 포함 8자 이상)</label>
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
                isSending: false,
                idForm: {
                    memberName: "",
                    email: ""
                },
                idAuthSent: false,
                idAuthCode: "",
                idResult: null,
                isVerified: false,
                pwAuthSent: false,
                pwAuthCode: "",
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
                this.isSending = false;
                this.idAuthSent = false;
                this.idAuthCode = "";
                this.idResult = null;
                this.isVerified = false;
                this.pwAuthSent = false;
                this.pwAuthCode = "";
            },
            fnSendAuthCode(type) {
                if (this.isSending) return;
                let self = this;
                let param = { type: type };
                
                if (type === "ID") {
                    if (!this.idForm.memberName.trim() || !this.idForm.email.trim()) {
                        alert("이름과 이메일을 모두 입력해주세요.");
                        return;
                    }
                    param.memberName = this.idForm.memberName.trim();
                    param.email = this.idForm.email.trim();
                } else {
                    if (!this.pwForm.loginId.trim() || !this.pwForm.memberName.trim() || !this.pwForm.email.trim()) {
                        alert("아이디, 이름, 이메일을 모두 입력해주세요.");
                        return;
                    }
                    param.loginId = this.pwForm.loginId.trim();
                    param.memberName = this.pwForm.memberName.trim();
                    param.email = this.pwForm.email.trim();
                }
                
                this.isSending = true;
                $.ajax({
                    url: "/member/send-auth-code.dox",
                    type: "POST",
                    data: param,
                    dataType: "json",
                    success: function (data) {
                        alert(data.message);
                        if (data.result === "success") {
                            if (type === "ID") {
                                self.idAuthSent = true;
                                self.idAuthCode = "";
                            } else {
                                self.pwAuthSent = true;
                                self.pwAuthCode = "";
                            }
                        }
                    },
                    complete: function () {
                        self.isSending = false;
                    }
                });
            },
            fnVerifyIdCode() {
                let self = this;
                if (!this.idAuthCode || this.idAuthCode.trim().length < 6) {
                    alert("이메일로 발송된 6자리 인증번호를 입력해주세요.");
                    return;
                }
                $.ajax({
                    url: "/member/verify-auth-code.dox",
                    type: "POST",
                    data: {
                        email: this.idForm.email.trim(),
                        code: this.idAuthCode.trim()
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            $.ajax({
                                url: "/member/find-id.dox",
                                type: "POST",
                                data: {
                                    memberName: self.idForm.memberName.trim(),
                                    email: self.idForm.email.trim()
                                },
                                dataType: "json",
                                success: function (res) {
                                    if (res.result === "success") {
                                        self.idResult = res;
                                    } else {
                                        alert(res.message || "일치하는 회원이 없습니다.");
                                    }
                                }
                            });
                        } else {
                            alert(data.message || "인증번호가 일치하지 않습니다.");
                        }
                    }
                });
            },
            fnVerifyPwCode() {
                let self = this;
                if (!this.pwAuthCode || this.pwAuthCode.trim().length < 6) {
                    alert("이메일로 발송된 6자리 인증번호를 입력해주세요.");
                    return;
                }
                $.ajax({
                    url: "/member/verify-auth-code.dox",
                    type: "POST",
                    data: {
                        email: this.pwForm.email.trim(),
                        code: this.pwAuthCode.trim()
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            alert("이메일 인증이 완료되었습니다. 새 비밀번호를 설정해주세요.");
                            self.isVerified = true;
                        } else {
                            alert(data.message || "인증번호가 일치하지 않습니다.");
                        }
                    }
                });
            },
            fnResetPassword() {
                const pwdRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]).{8,}$/;
                if (!this.pwForm.newPwd || !pwdRegex.test(this.pwForm.newPwd.trim())) {
                    alert("새 비밀번호는 영문, 숫자, 특수문자를 포함해 8자 이상이어야 합니다.");
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
