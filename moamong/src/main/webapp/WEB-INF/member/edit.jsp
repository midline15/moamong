<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 회원정보 수정</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <style>
            .container { width: 460px; margin: 40px auto; padding: 24px; border: 1px solid #ddd; border-radius: 8px; }
            h2 { margin-top: 0; }
            h3 { margin-top: 24px; padding-top: 16px; border-top: 1px solid #eee; font-size: 16px; }
            .form-group { margin-bottom: 12px; }
            .form-group label { display: block; font-weight: bold; margin-bottom: 4px; font-size: 13px; }
            input { width: 100%; padding: 8px; box-sizing: border-box; border: 1px solid #ccc; border-radius: 4px; }
            input[readonly] { background: #f3f3f3; color: #666; }
            button { width: 100%; padding: 9px; cursor: pointer; border-radius: 4px; font-weight: bold; margin-top: 6px; }
            .btn-primary { background: #222; color: #fff; border: none; }
            .btn-sub { background: #f8f8f8; color: #222; border: 1px solid #ccc; }
            .btn-danger { background: #d32f2f; color: #fff; border: none; }
            .top-nav { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        </style>
    </head>
    <body>
        <div id="app" class="container">
            <div class="top-nav">
                <h2>마이페이지</h2>
                <button class="btn-sub" style="width: auto; margin: 0;" @click="fnGoMain">메인으로</button>
            </div>

            <!-- 1. 기본 회원정보 조회 및 수정 -->
            <div class="form-group">
                <label>아이디 (변경 불가)</label>
                <input v-model="member.loginId" readonly>
            </div>
            <div class="form-group">
                <label>회원 등급 / 상태</label>
                <input :value="member.role + ' / ' + member.status" readonly>
            </div>
            <div class="form-group">
                <label>이름</label>
                <input v-model="member.memberName">
            </div>
            <div class="form-group">
                <label>이메일</label>
                <input v-model="member.email">
            </div>
            <div class="form-group">
                <label>휴대폰 번호</label>
                <input v-model="member.phone" placeholder="010-0000-0000">
            </div>
            <button class="btn-primary" @click="fnUpdateInfo">회원정보 수정</button>

            <!-- 2. 비밀번호 변경 -->
            <h3>비밀번호 변경</h3>
            <div class="form-group">
                <label>현재 비밀번호</label>
                <input type="password" v-model="currentPwd" placeholder="현재 비밀번호 입력">
            </div>
            <div class="form-group">
                <label>새 비밀번호</label>
                <input type="password" v-model="newPwd" placeholder="영문, 숫자, 특수문자 포함 8자 이상">
            </div>
            <div class="form-group">
                <label>새 비밀번호 확인</label>
                <input type="password" v-model="newPwdConfirm" placeholder="새 비밀번호 재입력">
            </div>
            <button class="btn-sub" @click="fnChangePwd">비밀번호 변경하기</button>

            <!-- 3. 회원 탈퇴 -->
            <h3>회원 탈퇴</h3>
            <div class="form-group">
                <label>본인 확인 비밀번호</label>
                <input type="password" v-model="withdrawPwd" placeholder="탈퇴 확인을 위해 비밀번호 입력">
            </div>
            <button class="btn-danger" @click="fnWithdraw">회원 탈퇴하기</button>
        </div>
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
                    phone: "",
                    role: "",
                    status: ""
                },
                currentPwd: "",
                newPwd: "",
                newPwdConfirm: "",
                withdrawPwd: ""
            };
        },
        methods: {
            fnGetMyInfo: function () {
                let self = this;
                $.ajax({
                    url: "/member/myinfo.dox",
                    type: "POST",
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            self.member = data.member;
                            if (!self.member.phone) self.member.phone = "";
                        } else {
                            alert(data.message);
                        }
                    }
                });
            },
            fnUpdateInfo: function () {
                let self = this;
                let param = {
                    memberName: self.member.memberName.trim(),
                    email: self.member.email.trim(),
                    phone: self.member.phone ? self.member.phone.trim() : ""
                };
                $.ajax({
                    url: "/member/update-info.dox",
                    type: "POST",
                    dataType: "json",
                    data: param,
                    success: function (data) {
                        alert(data.message);
                        if (data.result === "success") {
                            self.fnGetMyInfo();
                        }
                    }
                });
            },
            fnChangePwd: function () {
                let self = this;
                let pwdRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;
                
                if (!self.currentPwd) {
                    alert("현재 비밀번호를 입력해주세요.");
                    return;
                }
                /* if (!pwdRegex.test(self.newPwd)) {
                    alert("새 비밀번호는 영문, 숫자, 특수문자를 포함해 8자 이상으로 입력해주세요.");
                    return;
                } */
                if (self.newPwd !== self.newPwdConfirm) {
                    alert("새 비밀번호 확인이 일치하지 않습니다.");
                    return;
                }

                if (self.currentPwd == self.newPwd) {
                    alert("현재 비밀번호와 새 비밀번호가 일치합니다.");
                    return;
                }
                
                $.ajax({
                    url: "/member/change-password.dox",
                    type: "POST",
                    dataType: "json",
                    data: {
                        currentPwd: self.currentPwd,
                        newPwd: self.newPwd
                    },
                    success: function (data) {
                        alert(data.message);
                        if (data.result === "success") {
                            self.currentPwd = "";
                            self.newPwd = "";
                            self.newPwdConfirm = "";
                        }
                    }
                });
            },
            fnWithdraw: function () {
                let self = this;
                if (!self.withdrawPwd) {
                    alert("비밀번호를 입력해주세요.");
                    return;
                }
                if (!confirm("정말 탈퇴하시겠습니까? 탈퇴 후에는 해당 계정으로 로그인할 수 없습니다.")) {
                    return;
                }
                $.ajax({
                    url: "/member/withdraw.dox",
                    type: "POST",
                    dataType: "json",
                    data: { password: self.withdrawPwd },
                    success: function (data) {
                        alert(data.message);
                        if (data.result === "success") {
                            location.href = "/member/login.do";
                        }
                    }
                });
            },
            fnGoMain: function () {
                location.href = "/";
            }
        },
        mounted() {
            this.fnGetMyInfo();
        }
    });
    
    app.mount('#app');
</script>