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

        <style>
            body { font-family: 'Pretendard', sans-serif; background: #f8f9fa; margin: 0; padding: 40px 16px; color: #222; }
            .box { max-width: 440px; margin: 0 auto; background: #fff; border-radius: 12px; padding: 28px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); }
            h2 { margin: 0 0 18px 0; font-size: 22px; text-align: center; }
            .tabs { display: flex; border-bottom: 2px solid #eee; margin-bottom: 22px; }
            .tab { flex: 1; padding: 11px; text-align: center; cursor: pointer; font-weight: 700; font-size: 14px; color: #888; border-bottom: 2px solid transparent; margin-bottom: -2px; }
            .tab.active { color: #222; border-bottom-color: #222; }
            .form-group { margin-bottom: 14px; }
            .form-group label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px; }
            .form-control { width: 100%; box-sizing: border-box; padding: 10px 12px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px; }
            .btn { width: 100%; padding: 12px; border: none; border-radius: 6px; background: #222; color: #fff; font-size: 15px; font-weight: 700; cursor: pointer; margin-top: 6px; }
            .btn:hover { background: #444; }
            .result-card { margin-top: 18px; padding: 16px; background: #f1f3f5; border-radius: 8px; text-align: center; font-size: 14px; line-height: 1.6; }
            .bottom-links { display: flex; justify-content: center; gap: 14px; margin-top: 20px; font-size: 13px; }
            .bottom-links a { color: #555; text-decoration: none; }
            .bottom-links a:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <div id="app" class="box">
            <h2>🔑 계정 찾기</h2>

            <div class="tabs">
                <div class="tab" :class="{ active: tab === 'ID' }" @click="fnSwitchTab('ID')">아이디 찾기</div>
                <div class="tab" :class="{ active: tab === 'PW' }" @click="fnSwitchTab('PW')">비밀번호 재설정</div>
            </div>

            <!-- 1. 아이디 찾기 탭 -->
            <div v-if="tab === 'ID'">
                <div class="form-group">
                    <label>이름</label>
                    <input type="text" class="form-control" v-model="idForm.memberName" placeholder="가입 시 등록한 이름">
                </div>
                <div class="form-group">
                    <label>이메일</label>
                    <input type="email" class="form-control" v-model="idForm.email" placeholder="example@email.com" @keyup.enter="fnFindId">
                </div>
                <button class="btn" @click="fnFindId">아이디 찾기</button>

                <div v-if="idResult" class="result-card">
                    <div v-if="idResult.isSocial">
                        <strong>{{ idResult.socialType }}</strong> 소셜 로그인으로 가입된 계정입니다.<br>
                        로그인 화면에서 소셜 로그인 버튼을 이용해주세요.
                    </div>
                    <div v-else>
                        회원님의 아이디는 <strong style="font-size:17px; color:#1971c2;">{{ idResult.loginId }}</strong> 입니다.
                    </div>
                </div>
            </div>

            <!-- 2. 비밀번호 재설정 탭 -->
            <div v-if="tab === 'PW'">
                <div class="form-group">
                    <label>아이디</label>
                    <input type="text" class="form-control" v-model="pwForm.loginId" :disabled="isVerified" placeholder="아이디 입력">
                </div>
                <div class="form-group">
                    <label>이름</label>
                    <input type="text" class="form-control" v-model="pwForm.memberName" :disabled="isVerified" placeholder="이름 입력">
                </div>
                <div class="form-group">
                    <label>이메일</label>
                    <input type="email" class="form-control" v-model="pwForm.email" :disabled="isVerified" placeholder="가입 시 등록한 이메일">
                </div>

                <button v-if="!isVerified" class="btn" @click="fnVerifyReset">본인 확인</button>

                <div v-if="isVerified" style="margin-top:16px; padding-top:16px; border-top:1px dashed #ccc;">
                    <div class="form-group">
                        <label>새 비밀번호 (4자 이상)</label>
                        <input type="password" class="form-control" v-model="pwForm.newPwd" placeholder="새 비밀번호 입력">
                    </div>
                    <div class="form-group">
                        <label>새 비밀번호 확인</label>
                        <input type="password" class="form-control" v-model="pwForm.confirmPwd" placeholder="새 비밀번호 재입력" @keyup.enter="fnResetPassword">
                    </div>
                    <button class="btn" @click="fnResetPassword">비밀번호 변경하기</button>
                </div>
            </div>

            <div class="bottom-links">
                <a href="/member/login.do">로그인으로 돌아가기</a>
                <span>|</span>
                <a href="/member/join.do">회원가입</a>
            </div>
        </div>
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
