<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 메인</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>

        <style>
            body {
                font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;
                background-color: #f8f9fa;
                margin: 0;
                padding: 30px 16px;
                color: #222;
            }
            .container {
                max-width: 760px; /* 기존 640px -> 760px로 변경 */
                margin: 20px auto;
                padding: 28px;
                background: #fff;
                border: 1px solid #e9ecef;
                border-radius: 12px;
                box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
            }
            
            .top-nav {
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-bottom: 2px solid #222;
                padding-bottom: 14px;
                margin-bottom: 20px;
            }
            .top-nav h2 {
                margin: 0;
                font-size: 22px;
            }
            .info-box {
                background: #f8f9fa;
                padding: 18px 20px;
                border-radius: 8px;
                margin-bottom: 20px;
                line-height: 1.7;
                font-size: 14px;
            }
            .btn-group {
                display: flex;
                gap: 10px;
                flex-wrap: wrap;
            }
            .btn {
                padding: 9px 16px;
                cursor: pointer;
                border-radius: 6px;
                border: 1px solid #ccc;
                background: #fff;
                font-size: 14px;
                font-weight: 600;
                color: #222;
            }
            .btn:hover {
                background: #f1f3f5;
            }
            .btn-primary {
                background: #222;
                color: #fff;
                border-color: #222;
            }
            .btn-primary:hover {
                background: #444;
            }
            .btn-danger {
                border-color: #ffa8a8;
                color: #c92a2a;
            }
        </style>
    </head>
    <body>
        <div id="app" class="container">
            <div class="top-nav">
                <h2>🎁 모아몽 (MOAMONG)</h2>
                <span style="font-size: 13px; color: #666;">메인 테스트 허브</span>
            </div>

            <% if (session.getAttribute("sessionId") != null) {
                String createdAtStr = String.valueOf(session.getAttribute("sessionCreatedAt")).replace("T", " ");
            %>
            <div class="info-box">
                <div style="font-size: 17px; margin-bottom: 6px;">
                    <strong><%= session.getAttribute("sessionName") %></strong>님 환영합니다!
                </div>
                <div>• 회원번호: <%= session.getAttribute("sessionId") %></div>
                <div>• 권한: <%= session.getAttribute("sessionRole") %></div>
                <div>• 계정 상태: <strong><%= session.getAttribute("sessionStatus") %></strong></div>
                <div>• 가입일시: <%= createdAtStr %></div>
            </div>

            <div class="btn-group">
                <button class="btn btn-primary" @click="fnGoMypage">마이페이지</button>
                <button class="btn" @click="fnGoCart">🛒 장바구니 ({{ cartCount }})</button>
                <button class="btn" @click="fnGoWishlist">❤️ 찜 목록</button>
                <button class="btn" @click="fnGoOrderList">📦 주문 내역</button>
                <button class="btn" @click="fnGoAddress">📍 배송지 관리</button>
                <button class="btn btn-danger" @click="fnLogout">로그아웃</button>
            </div>
            <% } else { %>
            <div class="info-box" style="text-align: center; padding: 32px 16px; color: #555;">
                현재 비로그인 상태입니다.<br>
                로그인 후 마이페이지 및 장바구니 기능을 이용하실 수 있습니다.
            </div>

            <div class="btn-group" style="justify-content: center;">
                <button class="btn btn-primary" @click="fnGoLogin">로그인</button>
                <button class="btn" @click="fnGoJoin">회원가입</button>
            </div>
            <% } %>
        </div>
    </body>
</html>

<script>
    const app = Vue.createApp({
        data() {
            return {
                wishCount: 0,
                isLoggedIn: <%= session.getAttribute("sessionId") != null %>,
                cartCount: 0
            };
        },
        methods: {
            fnGetCartCount() {
                if (!this.isLoggedIn) return;
                let self = this;
                $.ajax({
                    url: "/cart/list.dox",
                    type: "POST",
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success" && data.list) {
                            self.cartCount = data.list.length;
                        }
                    }
                });
            },
            fnGoMypage() {
                location.href = "/member/mypage.do";
            },
            fnGoCart() {
                location.href = "/cart/list.do";
            },
            fnGoLogin() {
                location.href = "/member/login.do";
            },
            fnGoJoin() {
                location.href = "/member/join.do";
            },
            fnLogout() {
                $.ajax({
                    url: "/member/logout.dox",
                    type: "POST",
                    dataType: "json",
                    success: function (data) {
                        alert(data.message);
                        location.href = "/member/login.do";
                    }
                });
            },
            fnGoWishlist() {
                location.href = "/wishlist/list.do";
            },
            fnGetWishCount() {
                if (!this.isLoggedIn) return;
                let self = this;
                $.ajax({
                    url: "/wishlist/list.dox",
                    type: "POST",
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success" && data.list) {
                            self.wishCount = data.list.length;
                        }
                    }
                });
            },
            fnGoOrderList() {
                location.href = "/order/list.do";
            },
            fnGoAddress() {
                location.href = "/address/list.do";
            }
        },
        mounted() {
            this.fnGetCartCount();
        }
    });
    
    app.mount('#app');
</script>