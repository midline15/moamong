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
        <style>
            .container {
                width: 380px;
                margin: 60px auto;
                padding: 28px;
                border: 1px solid #ddd;
                border-radius: 8px;
            }
            
            h2 {
                text-align: center;
                margin-bottom: 24px;
            }
            
            .form-group {
                margin-bottom: 14px;
            }
            
            .form-group label {
                display: block;
                font-weight: bold;
                margin-bottom: 5px;
                font-size: 14px;
            }
            
            input {
                width: 100%;
                padding: 10px;
                box-sizing: border-box;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            
            button {
                width: 100%;
                padding: 11px;
                cursor: pointer;
                border-radius: 4px;
                font-size: 14px;
                font-weight: bold;
            }
            
            .btn-login {
                background: #222;
                color: #fff;
                border: none;
                margin-top: 6px;
            }
            
            .btn-join {
                background: #fff;
                color: #222;
                border: 1px solid #ccc;
                margin-top: 8px;
            }
            
            .divider {
                text-align: center;
                margin: 20px 0 14px;
                color: #888;
                font-size: 12px;
                border-top: 1px solid #eee;
                padding-top: 14px;
            }
            
            .social-group {
                display: flex;
                flex-direction: column;
                gap: 8px;
            }
            
            .btn-kakao {
                background: #FEE500;
                color: #191919;
                border: none;
            }
            
            .btn-naver {
                background: #03C75A;
                color: #fff;
                border: none;
            }
            
            .btn-google {
                background: #fff;
                color: #333;
                border: 1px solid #ddd;
            }
            
            .modal-overlay {
                position: fixed;
                inset: 0;
                background: rgba(0, 0, 0, 0.5);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 9999;
            }
            
            .modal-box {
                position: relative;
                z-index: 10000;
                width: 340px;
                background: #fff;
                padding: 24px;
                border: 1px solid #ddd;
                border-radius: 8px;
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
            }
            
            .modal-box h3 {
                margin: 0 0 12px;
                font-size: 18px;
                text-align: center;
            }
            
            .modal-desc {
                font-size: 13px;
                color: #555;
                line-height: 1.5;
                margin-bottom: 16px;
                text-align: center;
            }
            
            .modal-actions {
                display: flex;
                gap: 8px;
                margin-top: 12px;
            }
            
            .modal-actions button {
                margin-top: 0;
            }
            
        </style>
    </head>
    <body>
        <div id="app" class="container">
            <h2>모아몽 로그인</h2>

            <div class="form-group">
                <label>아이디</label>
                <input v-model="memberId" @keyup.enter="fnLogin" placeholder="아이디 입력">
            </div>

            <div class="form-group">
                <label>비밀번호</label>
                <input type="password" v-model="password" @keyup.enter="fnLogin" placeholder="비밀번호 입력">
            </div>

            <button class="btn-login" @click="fnLogin">로그인</button>
            <button class="btn-join" @click="fnJoin">회원가입</button>

            <div style="text-align: center; margin-top: 12px;">
                <a href="/member/find-account.do" style="font-size: 13px; color: #666; text-decoration: none;">
                    아이디 / 비밀번호 찾기
                </a>
            </div>

            <div class="divider">간편 소셜 로그인</div>
            <div class="social-group">
                <button class="btn-kakao" @click="fnSocialLogin('KAKAO')">카카오로 시작하기</button>
                <button class="btn-naver" @click="fnSocialLogin('NAVER')">네이버로 시작하기</button>
                <button class="btn-google" @click="fnSocialLogin('GOOGLE')">구글로 시작하기</button>
            </div>

            <!-- 휴면 계정 해제 모달 (반드시 #app 내부에 위치) -->
            <div v-if="showDormantModal" class="modal-overlay">
                <div class="modal-box">
                    <h3>휴면 계정 안내</h3>
                    <p class="modal-desc" v-if="!isSocialDormant">
                        30일 이상 미접속으로 휴면 전환된 계정입니다.<br>
                        비밀번호를 다시 입력해 휴면을 해제해주세요.
                    </p>
                    <p class="modal-desc" v-else>
                        30일 이상 미접속으로 휴면 전환된 소셜 계정입니다.<br>
                        아래 버튼을 누르시면 휴면이 즉시 해제됩니다.
                    </p>
                    <div class="form-group" v-if="!isSocialDormant">
                        <label>비밀번호 확인</label>
                        <input ref="dormantInput" type="password" v-model="dormantPwd" @keyup.enter="fnActivateDormant" placeholder="비밀번호 입력">
                    </div>
                    <div class="modal-actions">
                        <button class="btn-login" @click="fnActivateDormant">휴면 해제</button>
                        <button class="btn-join" @click="showDormantModal = false; dormantPwd = '';">취소</button>
                    </div>
                </div>
            </div>
        </div>
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
