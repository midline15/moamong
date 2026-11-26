<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>모아몽 - 개인정보처리방침</title>
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

    <main id="app" class="info-wrap">
        <nav class="info-tabs">
            <a href="/info/about.do" class="info-tab">회사소개</a>
            <a href="/info/terms.do" class="info-tab">이용약관</a>
            <a href="/info/privacy.do" class="info-tab active">개인정보처리방침</a>
            <a href="/info/guide.do" class="info-tab">이용방법</a>
            <a href="/info/shipping.do" class="info-tab">배송·반품 안내</a>
        </nav>

        <div class="info-head">
            <h2>{{ title }}</h2>
            <p>고객님의 소중한 개인정보 보호를 위한 모아몽의 처리방침입니다.</p>
        </div>

        <div class="info-card">
            <div class="policy-box">{{ content }}</div>
        </div>
    </main>

    <%@ include file="/WEB-INF/common/footer.jsp"%>
</body>
</html>
<script>
    Vue.createApp({
        data() { return { title: "개인정보처리방침", content: "방침 내용을 불러오는 중입니다..." }; },
        mounted() {
            $.post("/info/policies.dox", (res) => {
                const found = (res.list || []).find(p => p.policyType === "PRIVACY");
                if (found) {
                    this.title = found.title || "개인정보처리방침";
                    this.content = found.content || "등록된 개인정보처리방침이 없습니다.";
                } else {
                    this.content = "등록된 개인정보처리방침이 없습니다.";
                }
            }, "json");
        }
    }).mount("#app");
</script>
