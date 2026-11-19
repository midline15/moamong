<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 마이페이지</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <style>
            .container { width: 600px; margin: 40px auto; padding: 24px; border: 1px solid #ddd; border-radius: 8px; }
            .top-nav { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #222; padding-bottom: 12px; }
            .profile-box { background: #f9f9f9; padding: 16px; border-radius: 6px; margin: 16px 0; display: flex; justify-content: space-between; align-items: center; }
            .menu-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 16px; }
            .menu-card { border: 1px solid #ddd; padding: 16px; border-radius: 6px; cursor: pointer; background: #fff; text-align: left; }
            .menu-card:hover { background: #f4f4f4; }
            .menu-card h4 { margin: 0 0 6px 0; font-size: 15px; }
            .menu-card p { margin: 0; font-size: 12px; color: #666; }
            button { padding: 8px 14px; cursor: pointer; border-radius: 4px; border: 1px solid #ccc; background: #fff; font-weight: bold; }
        </style>
    </head>
    <body>
        <div id="app" class="container">
            <div class="top-nav">
                <h2 style="margin:0;">마이페이지</h2>
                <button @click="fnGoMain">메인으로</button>
            </div>

            <!-- 내 프로필 요약 -->
            <div class="profile-box">
                <div>
                    <div style="font-size: 18px; font-weight: bold;">{{ member.memberName }}님 ({{ member.loginId }})</div>
                    <div style="font-size: 13px; color: #555; margin-top: 4px;">
                        이메일: {{ member.email }} | 등급: {{ member.role }}
                    </div>
                </div>
                <button @click="fnGoEdit">회원정보 수정 / 탈퇴</button>
            </div>

            <!-- 쇼핑몰 메뉴 허브 (역할 분담 기반) -->
            <div class="menu-grid">
                <div class="menu-card" @click="fnMove('/order/list.do', '주문 내역')">
                    <h4>📦 주문 내역 조회</h4>
                    <p>주문한 상품의 결제 및 배송 상태를 확인합니다.</p>
                </div>
                <div class="menu-card" @click="fnMove('/cart/list.do', '장바구니')">
                    <h4>🛒 장바구니</h4>
                    <p>장바구니에 담아둔 상품을 확인하고 주문합니다.</p>
                </div>
                <div class="menu-card" @click="fnMove('/address/list.do', '배송지 관리')">
                    <h4>📍 배송지 관리</h4>
                    <p>기본 배송지 및 추가 배송지를 등록·수정합니다.</p>
                </div>
                <div class="menu-card" @click="fnMove('/board/qna.do', '나의 문의 내역')">
                    <h4>💬 상품 문의 / 1:1 문의</h4>
                    <p>내가 작성한 문의글과 답변을 확인합니다.</p>
                </div>
            </div>
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
                    role: ""
                }
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
                        }
                    }
                });
            },
            fnGoEdit: function () {
                location.href = "/member/edit.do";
            },
            fnGoMain: function () {
                location.href = "/";
            },
            fnMove: function (url, menuName) {
                alert(menuName + " 페이지는 해당 파트 팀원 페이지와 연결됩니다. (" + url + ")");
            }
        },
        mounted() {
            this.fnGetMyInfo();
        }
    });
    
    app.mount('#app');
</script>