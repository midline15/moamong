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
    <style>
        .container {
            width: 420px; 
            margin: 40px auto; 
            padding: 24px; 
            border: 1px solid #ddd; 
            border-radius: 8px; 
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
        .req { 
            color: #e53935; 
            margin-left: 2px; 
        }
        .opt { 
            color: #888; 
            font-weight: normal; 
            font-size: 12px; 
        }
        .input-row { 
            display: flex; 
            gap: 6px; 
        }
        input { 
            width: 100%; 
            padding: 8px; 
            box-sizing: border-box; 
            border: 1px solid #ccc; 
            border-radius: 4px; 
        }
        button { 
            padding: 8px 14px; 
            cursor: pointer; 
            border-radius: 4px;
            border: 1px solid #ccc; 
            background: #f8f8f8; 
            white-space: nowrap; 
        }
        .btn-primary { 
            width: 100%; 
            background: #222; 
            color: #fff; 
            border: none; 
            font-weight: bold; 
            margin-top: 10px;
            padding: 10px; 
        }
        .btn-sub { 
            width: 100%; 
            margin-top: 6px; 
        }
        .msg-ok { 
            color: #2e7d32; 
            font-size: 12px; 
            margin-top: 4px; 
        }
    </style>
</head>
<body>
    <div id="app" class="container">
        <h2>회원가입</h2>

        <div class="form-group">
            <label>아이디<span class="req">*</span></label>
            <div class="input-row">
                <input v-model="loginId" @input="isIdChecked = false" placeholder="영문, 숫자 4~20자">
                <button @click="fnIdCheck">중복확인</button>
            </div>
            <div v-if="isIdChecked" class="msg-ok">✓ 사용 가능한 아이디입니다.</div>
        </div>

        <div class="form-group">
            <label>비밀번호<span class="req">*</span></label>
            <input type="password" v-model="password" placeholder="영문, 숫자, 특수문자 포함 8자 이상">
        </div>

        <div class="form-group">
            <label>비밀번호 확인<span class="req">*</span></label>
            <input type="password" v-model="passwordConfirm" placeholder="비밀번호 재입력">
        </div>

        <div class="form-group">
            <label>이름<span class="req">*</span></label>
            <input v-model="memberName" placeholder="실명 입력">
        </div>

        <div class="form-group">
            <label>이메일<span class="req">*</span></label>
            <input v-model="email" placeholder="example@domain.com">
        </div>

        <div class="form-group">
            <label>휴대폰 번호 <span class="opt">(선택)</span></label>
            <input v-model="phone" placeholder="010-0000-0000">
        </div>

        <button class="btn-primary" @click="fnJoin">가입하기</button>
        <button class="btn-sub" @click="fnGoLogin">로그인 페이지로 돌아가기</button>
    </div>
</body>
</html>

<script>
    const app = Vue.createApp({
        data() {
            return {
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

                let param = {
                    loginId: self.loginId.trim(),
                    password: self.password,
                    memberName: self.memberName.trim(),
                    email: self.email.trim(),
                    phone: self.phone.trim()
                };

                $.ajax({
                    url: "/member/join.dox",
                    dataType: "json",
                    type: "POST",
                    data: param,
                    success: function (data) {
                        alert(data.message);
                        if (data.result === "success") {
                            location.href = "/member/login.do";
                        }
                    }
                });
            },
            fnGoLogin: function () {
                location.href = "/member/login.do";
            }
        }
    });

    app.mount('#app');
</script>