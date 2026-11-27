<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>모아몽 - 배송·반품 안내</title>
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
            <a href="/info/terms.do" class="info-tab">이용약관</a>
            <a href="/info/privacy.do" class="info-tab">개인정보처리방침</a>
            <a href="/info/guide.do" class="info-tab">이용방법</a>
            <a href="/info/shipping.do" class="info-tab active">배송·반품 안내</a>
        </nav>

        <div class="info-head">
            <span class="info-eyebrow">SHIPPING &amp; RETURNS</span>
            <h2>배송 · 반품 안내</h2>
            <p>안전한 배송과 투명한 취소·반품 기준을 안내해 드립니다.</p>
        </div>

        <div class="info-card">
            <h3><span class="info-ico">🚚</span>{{ deliveryTitle }}</h3>
            <div v-if="deliveryContent" class="policy-box">{{ deliveryContent }}</div>
            <table v-else class="info-table">
                <tr><th>배송비 정책</th><td>기본 배송비 3,000원 (<strong>30,000원 이상 구매 시 무료배송</strong>)</td></tr>
                <tr><th>출고 및 배송 기간</th><td>결제 완료 후 영업일 기준 1~3일 이내 출고되며, 커스텀 패키지는 1~2일 추가 소요될 수 있습니다.</td></tr>
                <tr><th>배송 조회</th><td>마이페이지 &gt; 주문내역 상세에서 택배사 및 송장번호를 실시간으로 조회할 수 있습니다.</td></tr>
            </table>
        </div>

        <div class="info-card">
            <h3><span class="info-ico">🤝</span>{{ refundTitle }}</h3>
            <div v-if="refundContent" class="policy-box">{{ refundContent }}</div>
            <table v-else class="info-table">
                <tr><th>주문 즉시 취소</th><td><strong>결제 완료(PAID)</strong> 단계까지는 주문상세에서 즉시 취소 및 전액 환불이 가능합니다.</td></tr>
                <tr><th>반품 신청 기간</th><td>상품 준비중 이후에는 즉시 취소가 불가하며, <strong>배송 완료 후 7일 이내</strong> 반품 신청이 가능합니다.</td></tr>
                <tr><th>반품 불가 사유</th><td>고객 책임 사유로 상품·포장이 훼손된 경우, 맞춤 제작 메시지 카드·각인 상품은 반품이 제한됩니다.</td></tr>
            </table>
        </div>
    </main>

    <%@ include file="/WEB-INF/common/footer.jsp"%>

    <script>
        Vue.createApp({
            data() { return { deliveryTitle: "배송 및 반품 안내", deliveryContent: "", refundTitle: "교환 및 환불 기준", refundContent: "" }; },
            mounted() {
                $.post("/info/policies.dox", (res) => {
                    const list = res.list || [];
                    const d = list.find(p => p.policyType === "DELIVERY");
                    const r = list.find(p => p.policyType === "REFUND");
                    if (d && d.content) { this.deliveryTitle = d.title || this.deliveryTitle; this.deliveryContent = d.content; }
                    if (r && r.content) { this.refundTitle = r.title || this.refundTitle; this.refundContent = r.content; }
                }, "json");
            }
        }).mount("#app");
    </script>
</body>
</html>
