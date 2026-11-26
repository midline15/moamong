<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>모아몽 - 이용방법</title>
    <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
    <script src="/js/page-change.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/info/info.css">
</head>
<body>
    <%@ include file="/WEB-INF/common/header.jsp"%>

    <main class="info-wrap">
        <nav class="info-tabs">
            <a href="/info/about.do" class="info-tab">회사소개</a>
            <a href="/info/terms.do" class="info-tab">이용약관</a>
            <a href="/info/privacy.do" class="info-tab">개인정보처리방침</a>
            <a href="/info/guide.do" class="info-tab active">이용방법</a>
            <a href="/info/shipping.do" class="info-tab">배송·반품 안내</a>
        </nav>

        <div class="info-head">
            <h2>이용방법 안내</h2>
            <p>회원가입부터 나만의 커스텀 선물 패키지 주문까지 간편하게 이용하세요.</p>
        </div>

        <div class="info-card">
            <h3>주문 · 결제 4단계 가이드</h3>
            <div class="info-grid">
                <div class="info-step">
                    <span class="num">STEP 01</span>
                    <h4 style="margin:0 0 6px; font-size:15px;">회원가입 및 본인인증</h4>
                    <p style="font-size:13px; color:#5c5346;">일반 가입 또는 소셜 로그인(카카오·네이버·구글) 후 휴대폰 본인인증을 완료합니다.</p>
                </div>
                <div class="info-step">
                    <span class="num">STEP 02</span>
                    <h4 style="margin:0 0 6px; font-size:15px;">상품 · 패키지 구성</h4>
                    <p style="font-size:13px; color:#5c5346;">대상·목적별 패키지에서 원하는 구성품과 포장, 메시지 카드를 선택해 장바구니에 담습니다.</p>
                </div>
                <div class="info-step">
                    <span class="num">STEP 03</span>
                    <h4 style="margin:0 0 6px; font-size:15px;">배송지 입력 및 결제</h4>
                    <p style="font-size:13px; color:#5c5346;">기본 배송지 불러오기 또는 새 배송지 입력 후 간편결제/신용카드로 안전하게 결제합니다.</p>
                </div>
                <div class="info-step">
                    <span class="num">STEP 04</span>
                    <h4 style="margin:0 0 6px; font-size:15px;">실시간 알림 및 배송조회</h4>
                    <p style="font-size:13px; color:#5c5346;">주문 접수부터 출고, 배송 완료까지 상단 알림 센터와 마이페이지에서 실시간 확인이 가능합니다.</p>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="/WEB-INF/common/footer.jsp"%>
</body>
</html>
