<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>모아몽 - 이용약관</title>
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

    <main id="app" class="info-wrap" v-cloak>
        <nav class="info-tabs">
            <a href="/info/about.do" class="info-tab">회사소개</a>
            <a href="/info/terms.do" class="info-tab active">이용약관</a>
            <a href="/info/privacy.do" class="info-tab">개인정보처리방침</a>
            <a href="/info/guide.do" class="info-tab">이용방법</a>
            <a href="/info/shipping.do" class="info-tab">배송·반품 안내</a>
        </nav>

        <div class="info-head">
            <span class="info-eyebrow">TERMS OF SERVICE</span>
            <h2>{{ title }}</h2>
            <p>모아몽 서비스 이용과 관련한 기본 약관 및 운영 정책입니다.</p>
        </div>

        <div class="info-card">
            <div class="policy-box">{{ content }}</div>
        </div>
    </main>

    <%@ include file="/WEB-INF/common/footer.jsp"%>

    <script>
        Vue.createApp({
            data() { return { title: "서비스 이용약관", content: "약관 내용을 불러오는 중입니다..." }; },
            mounted() {
                $.post("/info/policies.dox", (res) => {
                    const found = (res.list || []).find(p => p.policyType === "TERMS");
                    if (found) {
                        this.title = found.title || "서비스 이용약관";
                        this.content = found.content || "등록된 이용약관이 없습니다.";
                    } else {
                        this.content = "등록된 이용약관이 없습니다.";
                    }
                }, "json");
            }
        }).mount("#app");
    </script>
</body>
</html>
