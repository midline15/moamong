<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 - 취소/환불 내역</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
        <!-- 공통 레이아웃 CSS (헤더 · 사이드바 · 푸터 · 마이페이지) -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypage.css">

    </head>
<body>
    <%@ include file="/WEB-INF/common/header.jsp"%>

    <div id="app" class="mp-wrap">
        <% request.setAttribute("activeMenu", "cancel"); %>
        <%@ include file="/WEB-INF/common/mypageSidebar.jsp"%>

        <main class="mp-content">
            <div class="mp-head">
                <h2>{{ detail ? '반품 상세' : '반품 목록' }}</h2>
                <span class="mp-breadcrumb">
                    마이페이지 &gt; 반품 목록<span v-if="detail"> &gt; 반품 상세</span>
                </span>
            </div>

            <!-- [화면 A] 반품/취소 목록 -->
            <div v-if="!detail">
                <div style="display:flex; gap:8px; margin-bottom:18px;">
                    <button class="mp-btn" :class="{ 'mp-btn-gold': tab === 'ALL' }" @click="tab = 'ALL'">전체 ({{ list.length }})</button>
                    <button class="mp-btn" :class="{ 'mp-btn-gold': tab === 'CANCEL' }" @click="tab = 'CANCEL'">주문취소 ({{ cancelCount }})</button>
                    <button class="mp-btn" :class="{ 'mp-btn-gold': tab === 'RETURN' }" @click="tab = 'RETURN'">반품/환불 ({{ returnCount }})</button>
                </div>

                <div v-if="filteredList.length === 0" class="mp-card" style="text-align:center; padding:50px 0; color:#85817b;">
                    취소 및 반품 내역이 없습니다.
                </div>

                <div v-for="row in filteredList" :key="row.claimType + '_' + row.claimId" class="mp-card">
                    <div style="display:flex; justify-content:space-between; font-size:12px; color:#85817b; padding-bottom:10px; border-bottom:1px solid #e3d6c1; margin-bottom:12px;">
                        <span>신청일: {{ row.requestedAt }} · 주문번호: {{ row.orderNumber }}</span>
                        <strong style="color:#765a36;">{{ row.status === 'COMPLETED' ? '환불완료' : '환불대기' }}</strong>
                    </div>
                    <div style="display:flex; justify-content:space-between; align-items:center; gap:16px;">
                        <div style="font-size:14px;">
                            <strong>{{ row.repItemName }}</strong>
                            <span v-if="row.itemCount > 1" style="font-size:12px; color:#85817b;"> 외 {{ row.itemCount - 1 }}건</span>
                            <div style="font-size:13px; color:#5c5346; margin-top:4px;">
                                {{ Number(row.refundAmount).toLocaleString() }}원 · 사유: {{ row.reason }}
                            </div>
                        </div>
                        <button class="mp-btn mp-btn-gold" @click="fnOpenDetail(row)">반품상세</button>
                    </div>
                </div>
            </div>

            <!-- [화면 B] 반품/취소 상세 (피그마 반품 상세 화면) -->
            <div v-else>
                <div class="mp-card">
                    <h3 style="font-size:15px; margin-bottom:12px; color:#765a36;">상세정보</h3>
                    <table style="width:100%; border-collapse:collapse; font-size:13px;">
                        <tr><th style="width:130px; text-align:left; padding:7px 0; color:#85817b;">구분 / 상태</th><td>{{ detail.claimType === 'CANCEL' ? '주문 즉시 취소' : '반품/환불' }} · <strong>{{ detail.statusText }}</strong></td></tr>
                        <tr><th style="text-align:left; padding:7px 0; color:#85817b;">주문번호</th>
                            <td>{{ detail.order.orderNumber }}
                            <a :href="'/order/detail.do?orderId=' + detail.order.orderId"
                                style="margin-left:8px; font-size:12px; color:#94764b; font-weight:700; text-decoration:underline;">
                                주문 상세보기 &gt;
                            </a>
                            </td>
                        </tr>
                        <tr><th style="text-align:left; padding:7px 0; color:#85817b;">처리완료일시</th><td>{{ detail.processedAt || '-' }}</td></tr>
                        <tr><th style="text-align:left; padding:7px 0; color:#85817b;">사유</th><td>{{ detail.reasonText }}</td></tr>
                    </table>
                </div>

                <div class="mp-card">
                    <h3 style="font-size:15px; margin-bottom:12px; color:#765a36;">환불안내</h3>
                    <table style="width:100%; border-collapse:collapse; font-size:13px;">
                        <tr><th style="width:130px; text-align:left; padding:7px 0; color:#85817b;">환불 수단</th><td>{{ detail.payment ? detail.payment.payMethod : 'CARD' }}</td></tr>
                        <tr><th style="text-align:left; padding:7px 0; color:#85817b;">최종 환불금액</th><td><strong style="font-size:15px; color:#765a36;">{{ Number(detail.refundAmount).toLocaleString() }}원</strong></td></tr>
                    </table>
                </div>

                <button class="mp-btn mp-btn-gold" @click="detail = null">목록으로</button>
            </div>
        </main>
    </div>

    <%@ include file="/WEB-INF/common/footer.jsp"%>
</body>

</html>
<script>
    const app = Vue.createApp({
        data() {
            return { list: [], tab: "ALL", detail: null };
        },
        computed: {
            cancelCount() { return this.list.filter(r => r.claimType === "CANCEL").length; },
            returnCount() { return this.list.filter(r => r.claimType === "RETURN").length; },
            filteredList() { return this.tab === "ALL" ? this.list : this.list.filter(r => r.claimType === this.tab); }
        },
        methods: {
            fnGoMain() { location.href = "/"; },
            fnGoMypage() { location.href = "/member/mypage.do"; },
            fnGoOrders() { location.href = "/order/list.do"; },
            fnLoad() {
                let self = this;
                $.ajax({
                    url: "/order/cancel-list.dox", type: "POST", dataType: "json",
                    success: function (data) { if (data.result === "success") self.list = data.list || []; }
                });
            },
            fnOpenDetail(row) {
                let self = this;
                $.ajax({
                    url: "/order/cancel-detail.dox", type: "POST",
                    data: { claimType: row.claimType, claimId: row.claimId, orderId: row.orderId },
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            const info = row.claimType === "RETURN" ? data.returnInfo : data.cancelInfo;
                            self.detail = {
                                claimType: row.claimType,
                                order: data.order,
                                items: data.items || [],
                                payment: data.payment,
                                statusText: row.status === "COMPLETED" ? "환불완료 (관리자 승인)" : "환불대기",
                                reasonText: info ? (info.returnReason || info.cancelReason) : row.reason,
                                refundAmount: info ? (info.refundAmount || info.cancelAmount) : row.refundAmount,
                                processedAt: info ? (info.processedAt || info.createdAt) : row.processedAt
                            };
                        }
                    }
                });
            }
        },
        mounted() { this.fnLoad(); }
    });
    app.mount('#app');
</script>
