<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>모아몽 - 회사소개</title>
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
            <a href="/info/about.do" class="info-tab active">회사소개</a>
            <a href="/info/terms.do" class="info-tab">이용약관</a>
            <a href="/info/privacy.do" class="info-tab">개인정보처리방침</a>
            <a href="/info/guide.do" class="info-tab">이용방법</a>
            <a href="/info/shipping.do" class="info-tab">배송·반품 안내</a>
        </nav>

        <div class="info-head">
            <h2>회사소개</h2>
            <p>마음을 모으고, 선물의 가치를 더하는 감성 큐레이션 스토어 모아몽(MOAMONG)</p>
        </div>

        <div class="info-card">
            <h3>브랜드 스토리</h3>
            <p>모아몽(MOAMONG)은 소중한 사람에게 전하는 선물을 고민하는 시간부터 받는 순간의 설렘까지 함께하는 맞춤형 선물 큐레이션 플랫폼입니다.</p>
            <p>단품 상품부터 대상·목적별 맞춤형 커스텀 패키지, 정성을 담은 메시지 카드까지 한 번에 구성하여 가장 따뜻한 마음을 전달할 수 있도록 돕습니다.</p>

            <div class="info-grid">
                <div class="info-step">
                    <span class="num">01 CURATION</span>
                    <h4 style="margin:0 0 6px; font-size:15px;">대상·목적별 큐레이션</h4>
                    <p style="font-size:13px; color:#5c5346;">선물 받는 대상과 기념일 목적에 맞춘 최적의 선물 구성을 제안합니다.</p>
                </div>
                <div class="info-step">
                    <span class="num">02 CUSTOM PACKAGE</span>
                    <h4 style="margin:0 0 6px; font-size:15px;">나만의 커스텀 패키지</h4>
                    <p style="font-size:13px; color:#5c5346;">원하는 구성품과 포장, 메시지 카드를 직접 조합해 세상에 하나뿐인 선물을 만듭니다.</p>
                </div>
                <div class="info-step">
                    <span class="num">03 COMMUNITY</span>
                    <h4 style="margin:0 0 6px; font-size:15px;">STORY 커뮤니티</h4>
                    <p style="font-size:13px; color:#5c5346;">실제 선물 후기와 감성 일상을 나누며 서로에게 영감을 주는 공간을 지향합니다.</p>
                </div>
            </div>
        </div>
    </main>

    <%@ include file="/WEB-INF/common/footer.jsp"%>
</body>
</html>
