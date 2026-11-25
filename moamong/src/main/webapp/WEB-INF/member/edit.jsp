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
        <!-- 공통 레이아웃 CSS (헤더 · 사이드바 · 푸터 · 마이페이지) -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypage.css">
    </head>
    <body>
        <%@ include file="/WEB-INF/common/header.jsp"%>

        <div id="app" class="mp-wrap">
            <% request.setAttribute("activeMenu", "info"); %>
            <%@ include file="/WEB-INF/common/mypageSidebar.jsp"%>

            <main class="mp-content">
                <div class="mp-head">
                    <h2>내 정보 관리</h2>
                    <span class="mp-breadcrumb">마이페이지 &gt; 내 정보 관리</span>
                </div>

                <!-- 1. 기본 정보 수정 -->
                <div class="mp-card">
                    <h3 style="font-size:15px; margin-bottom:16px; color:#765a36;">기본 정보 수정</h3>
                    <table style="width:100%; border-collapse:collapse; font-size:13px;">
                        <tr>
                            <th style="width:140px; text-align:left; padding:9px 0; color:#5c5346;">아이디 / 로그인</th>
                            <td><input class="mp-input" :value="member.socialType ? (member.socialType + ' 간편 로그인') : member.loginId" readonly></td>
                        </tr>
                        <tr>
                            <th style="text-align:left; padding:9px 0; color:#5c5346;">회원 등급 / 상태</th>
                            <td><input class="mp-input" :value="member.role + ' / ' + member.status" readonly></td>
                        </tr>
                        <tr>
                            <th style="text-align:left; padding:9px 0; color:#5c5346;">이름</th>
                            <td><input class="mp-input" v-model="member.memberName"></td>
                        </tr>
                        <tr>
                            <th style="text-align:left; padding:9px 0; color:#5c5346;">이메일</th>
                            <td><input class="mp-input" v-model="member.email"></td>
                        </tr>
                        <tr>
                            <th style="text-align:left; padding:9px 0; color:#5c5346;">휴대폰 번호</th>
                            <td><input class="mp-input" v-model="member.phone" placeholder="010-0000-0000"></td>
                        </tr>
                    </table>
                    <div style="margin-top:16px;">
                        <button class="mp-btn mp-btn-gold" @click="fnUpdateInfo">정보 수정 저장</button>
                    </div>
                </div>
                <!-- 2. 비밀번호 변경 (일반 회원만) -->
                <div class="mp-card" v-if="!member.socialType">
                    <h3 style="font-size:15px; margin-bottom:16px; color:#765a36;">비밀번호 변경</h3>
                    <table style="width:100%; border-collapse:collapse; font-size:13px;">
                        <tr>
                            <th style="width:140px; text-align:left; padding:9px 0; color:#5c5346;">현재 비밀번호</th>
                            <td><input type="password" class="mp-input" v-model="currentPwd" placeholder="현재 비밀번호 입력"></td>
                        </tr>
                        <tr>
                            <th style="text-align:left; padding:9px 0; color:#5c5346;">새 비밀번호</th>
                            <td><input type="password" class="mp-input" v-model="newPwd" placeholder="영문, 숫자, 특수문자 포함 8자 이상"></td>
                        </tr>
                        <tr>
                            <th style="text-align:left; padding:9px 0; color:#5c5346;">새 비밀번호 확인</th>
                            <td><input type="password" class="mp-input" v-model="newPwdConfirm" placeholder="새 비밀번호 재입력"></td>
                        </tr>
                    </table>
                    <div style="margin-top:16px;">
                        <button class="mp-btn mp-btn-gold" @click="fnChangePwd">비밀번호 변경</button>
                    </div>
                </div>

                <!-- 3. 회원 탈퇴 -->
                <div class="mp-card">
                    <h3 style="font-size:15px; margin-bottom:12px; color:#765a36;">회원 탈퇴</h3>
                    <div v-if="!member.socialType" style="margin-bottom:12px;">
                        <input type="password" class="mp-input" v-model="withdrawPwd" placeholder="본인 확인 비밀번호 입력">
                    </div>
                    <p v-else style="font-size:13px; color:#85817b; margin-bottom:12px;">
                        {{ member.socialType }} 소셜 연동 계정은 별도 비밀번호 입력 없이 즉시 탈퇴할 수 있습니다.
                    </p>
                    <button class="mp-btn mp-btn-danger" @click="fnWithdraw">회원 탈퇴하기</button>
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
                    phone: "",
                    role: "",
                    status: "",
                    socialType: null
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
                if (!self.currentPwd || !self.currentPwd.trim()) {
                    alert("현재 비밀번호를 입력해주세요.");
                    return;
                }
                if (!self.newPwd || !self.newPwd.trim()) {
                    alert("새 비밀번호를 입력해주세요.");
                    return;
                }
                const pwdRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]).{8,}$/;
                if (!pwdRegex.test(self.newPwd)) {
                    alert("새 비밀번호는 영문, 숫자, 특수문자를 포함해 8자 이상이어야 합니다.");
                    return;
                }
                if (self.newPwd !== self.newPwdConfirm) {
                    alert("새 비밀번호 확인이 일치하지 않습니다.");
                    return;
                }
                if (self.currentPwd === self.newPwd) {
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
                // 일반 회원일 때만 비밀번호 필수 입력 체크
                if (!self.member.socialType && !self.withdrawPwd) {
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
                    data: { password: self.withdrawPwd || "" },
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