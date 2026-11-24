
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!-- 헤더 CSS -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">

<!-- 헤더 전체 영역 -->
<div class="header-container">

    <header class="header header-main">

        <!-- 왼쪽 햄버거 메뉴 -->
        <div class="header-left">

            <button type="button"
                    class="menu-btn"
                    aria-label="메뉴 열기"
                    aria-expanded="false"
                    aria-controls="sidebar">

                <span></span>
                <span></span>
                <span></span>

            </button>

        </div>

        <!-- 중앙 로고 -->
        <h1 class="logo">

            <a href="${pageContext.request.contextPath}/">

                <img
                    src="${pageContext.request.contextPath}/assets/logos/moamongLogo.png"
                    alt="모아몽 로고">

            </a>

        </h1>

                <!-- 오른쪽 아이콘 메뉴 -->
        <div class="header-right">

            <!-- 찜 -->
            <a href="/wishlist/list.do" class="icon-menu" aria-label="찜">
                <svg viewBox="0 0 24 24">
                    <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 21l8.8-8.6a5.5 5.5 0 0 0 0-7.8z" />
                </svg>
            </a>

            <!-- 장바구니 -->
            <a href="/cart/list.do" class="icon-menu" aria-label="장바구니">
                <svg viewBox="0 0 24 24">
                    <path d="M3 3h2l2.5 13h11L21 7H6" />
                    <circle cx="9" cy="20" r="1" />
                    <circle cx="18" cy="20" r="1" />
                </svg>
            </a>

            <!-- 알림 -->
            <a href="/notification/list.do" class="icon-menu" aria-label="알림">
                <svg viewBox="0 0 24 24">
                    <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9" />
                    <path d="M10 21h4" />
                </svg>
            </a>

            <!-- 마이페이지 -->
            <a href="/member/mypage.do" class="icon-menu" aria-label="마이페이지">
                <svg viewBox="0 0 24 24">
                    <circle cx="12" cy="8" r="4" />
                    <path d="M4 21v-2a8 8 0 0 1 16 0v2" />
                </svg>
            </a>

            <!-- 로그인 / 회원가입 (세션 유무에 따라 분기) -->
            <div class="user-menu">
                <% if (session.getAttribute("sessionId") == null) { %>
                    <a href="/member/login.do" class="login-link">로그인</a>
                    <span class="user-divider"></span>
                    <a href="/member/join.do" class="signup-link">회원가입</a>
                    <div class="signup-tooltip">
                        <div>
                            <strong>모아몽 신규 회원 혜택</strong>
                            <p>지금 가입하고 특별한 혜택을 만나보세요!</p>
                        </div>
                    </div>
                <% } else { %>
                    <a href="/member/mypage.do" class="login-link">마이페이지</a>
                    <span class="user-divider"></span>
                    <a href="/member/logout.do" class="login-link">로그아웃</a>
                <% } %>
            </div>


        </div>


    </header>

</div>

<!-- 사이드바 연결 -->
<jsp:include page="/WEB-INF/common/sidebar.jsp" />
