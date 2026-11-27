<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 - 주문 상세 내역</title>
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
        <% request.setAttribute("activeMenu", "order"); %>
        <%@ include file="/WEB-INF/common/mypageSidebar.jsp"%>

        <main class="mp-content">
            <div class="mp-head">
                <h2>주문 상세</h2>
                <span class="mp-breadcrumb">마이페이지 &gt; 주문 목록 &gt; 주문 상세</span>
            </div>

            <div v-if="order">
                <!-- 1. 주문 상태 및 상품 목록 -->
                <div class="mp-card">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px; font-size:13px;">
                        <strong style="color:#765a36;">{{ statusText(order.orderStatus) }} ({{ order.orderNumber }})</strong>
                        <span style="color:#9a8f80;">주문일시: {{ order.orderedAt }}</span>
                    </div>

                    <div v-for="item in items" :key="item.orderItemId" style="display:flex; align-items:flex-start; gap:14px; padding:10px 0; border-top:1px solid #efe7da;">
                        <img :src="(item.thumbnailUrl && item.thumbnailUrl.trim()) ? item.thumbnailUrl : defaultThumb" @error="fnImgError"
                             style="width:64px; height:64px; border-radius:6px; object-fit:cover; background:#efe7da;">
                        <div style="flex:1; font-size:13px;">
                            <strong>{{ item.itemNameSnapshot }}</strong>
                            <div style="color:#85817b; margin-top:4px;">
                                {{ Number(item.unitPrice).toLocaleString() }}원 × {{ item.quantity }}개 =
                                <strong style="color:#29251f;">{{ Number(item.lineAmount).toLocaleString() }}원</strong>
                            </div>
                            <div v-if="item.itemType === 'PACKAGE'" style="margin-top:6px; padding-left:10px; border-left:2px solid #d5c4aa; font-size:12px; color:#5c5346;">
                                <div v-for="pi in item.packageItems" :key="pi.orderPackageItemId">• [{{ pi.itemRole }}] {{ pi.productNameSnapshot }} (x{{ pi.quantity }})</div>
                                <div v-for="pe in item.packageExtras" :key="pe.orderPackageExtraId">• [추가옵션] {{ pe.optionNameSnapshot }} <span v-if="pe.optionValue">| "{{ pe.optionValue }}"</span></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 2. 배송정보 상세 -->
                <div class="mp-card">
                    <h3 style="font-size:15px; margin-bottom:12px; color:#765a36;">배송정보</h3>
                    <table style="width:100%; border-collapse:collapse; font-size:13px;">
                        <tr><th style="width:120px; text-align:left; padding:7px 0; color:#85817b;">수령인</th><td>{{ order.recipientName }}</td></tr>
                        <tr><th style="text-align:left; padding:7px 0; color:#85817b;">연락처</th><td>{{ order.recipientPhone }}</td></tr>
                        <tr><th style="text-align:left; padding:7px 0; color:#85817b;">배송 주소</th><td>({{ order.postalCode }}) {{ order.addressDefault }} {{ order.addressDetail }}</td></tr>
                    </table>
                </div>

                <!-- 2-1. 카톡/문자용 선물 도착 안내 메시지 자동 생성 & 복사 카드 -->
                <div v-if="order.orderStatus !== 'CANCELED'" class="mp-card" style="background:#faf7f1; border:1px solid #e3d6c1;">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:10px;">
                        <h3 style="font-size:15px; margin:0; color:#765a36;">🎁 선물 받는 분께 보낼 도착 안내 메시지</h3>
                        <button type="button" class="mp-btn mp-btn-gold" @click="fnCopyGiftMessage">
                            {{ copiedGiftMsg ? '복사 완료!' : '카톡/문자 메시지 복사' }}
                        </button>
                    </div>
                    <pre style="margin:0; padding:12px 14px; background:#fffdf9; border:1px solid #e9dfd1; border-radius:8px; font-family:inherit; font-size:13px; color:#5c5346; line-height:1.65; white-space:pre-wrap;">{{ giftNoticeText }}</pre>
                </div>


                <!-- 3. 결제정보 상세 -->
                <div class="mp-card">
                    <h3 style="font-size:15px; margin-bottom:12px; color:#765a36;">결제정보</h3>
                    <table style="width:100%; border-collapse:collapse; font-size:13px;">
                        <tr><th style="width:120px; text-align:left; padding:7px 0; color:#85817b;">상품/옵션 금액</th><td>{{ Number(order.totalProductAmount + order.totalAdditionalAmount).toLocaleString() }}원</td></tr>
                        <tr><th style="text-align:left; padding:7px 0; color:#85817b;">배송비</th><td>{{ Number(order.shippingFee).toLocaleString() }}원</td></tr>
                        <tr><th style="text-align:left; padding:7px 0; color:#85817b;">최종 결제금액</th><td><strong style="font-size:15px;">{{ Number(order.finalAmount).toLocaleString() }}원</strong> ({{ payment ? payment.payMethod : 'CARD' }})</td></tr>
                        <tr v-if="order.orderStatus === 'CANCELED' && cancelInfo">
                            <th style="text-align:left; padding:7px 0; color:#b88b68;">취소/환불 내역</th>
                            <td style="color:#b88b68;">{{ cancelInfo.cancelReason }} ({{ cancelInfo.createdAt }})</td>
                        </tr>
                    </table>
                </div>

                <div style="display:flex; justify-content:space-between; margin-top:20px;">
                    <button class="mp-btn mp-btn-gold" @click="fnGoList">목록으로</button>
                    <button v-if="order.orderStatus === 'PAID' || order.orderStatus === 'PAYMENT_PENDING'"
                            class="mp-btn mp-btn-danger" @click="fnOpenCancelModal">주문 취소</button>
                </div>
            </div>

            <!-- 주문 취소 사유 모달 -->
            <div v-if="showCancelModal" class="mp-modal-backdrop" @click.self="showCancelModal = false">
                <div class="mp-modal-box">
                    <h3 style="margin:0 0 14px 0; font-size:17px; color:#765a36;">주문 취소 사유 선택</h3>
                    <label v-for="r in cancelReasons" :key="r"
                           style="display:flex; align-items:center; gap:8px; padding:9px 10px; border:1px solid #efe7da; border-radius:6px; margin-bottom:8px; cursor:pointer; font-size:13px; background:#fff;">
                        <input type="radio" :value="r" v-model="selectedReason"><span>{{ r }}</span>
                    </label>
                    <div v-if="selectedReason === '기타 (직접 입력)'" style="margin-top:8px;">
                        <textarea v-model="customReason" rows="3" maxlength="200"
                                  style="width:100%; padding:8px; border:1px solid #e3d6c1; border-radius:6px; font-size:13px;"
                                  placeholder="취소 사유를 입력해주세요"></textarea>
                    </div>
                    <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:16px;">
                        <button class="mp-btn" @click="showCancelModal = false">닫기</button>
                        <button class="mp-btn mp-btn-danger" :disabled="isCanceling" @click="fnConfirmCancel">
                            {{ isCanceling ? '처리 중...' : '취소 확정' }}
                        </button>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <%@ include file="/WEB-INF/common/footer.jsp"%>
</body>

</html>
<script>
    const app = Vue.createApp({
        data() {
            return {
                orderId: "${orderId}",
                order: null,
                items: [],
                payment: null,
                cancelInfo: null,
                defaultThumb: "",
                showCancelModal: false,
                cancelReasons: ["단순 변심", "옵션 / 수량 선택 실수", "배송지 입력 오류", "다른 상품으로 재주문 예정", "기타 (직접 입력)"],
                selectedReason: "단순 변심",
                isCanceling: false,
                copiedGiftMsg: false,
                customReason: ""
            };
        },

        computed: {
            giftNoticeText() {
                if (!this.order) return "";
                const receiver = this.order.recipientName || "소중한 분";
                const firstItem = this.items.length > 0 ? this.items[0].itemNameSnapshot : "모아몽 선물 세트";
                const extraCount = this.items.length > 1 ? (" 외 " + (this.items.length - 1) + "건") : "";
                return "[모아몽 선물 안내]\n"
                    + receiver + "님께 마음을 담은 선물(" + firstItem + extraCount + ")을 보내드렸어요 🎁\n\n"
                    + "배송 상태: " + this.statusText(this.order.orderStatus) + " (주문번호: " + this.order.orderNumber + ")\n"
                    + "예쁘게 받아보시고 행복한 하루 보내세요!";
            }
        },

        methods: {
            fnGoMain() { location.href = "/"; },
            fnGoMypage() { location.href = "/member/mypage.do"; },
            fnGoList() { location.href = "/order/list.do"; },
            fnImgError(e) { e.target.style.display = "none"; },
            statusText(s) {
                const m = { PAYMENT_PENDING: "결제대기", PAID: "결제완료", PREPARING: "상품준비중", SHIPPING: "배송중", DELIVERED: "배송완료", CANCELED: "주문취소" };
                return m[s] || s;
            },
            statusClass(s) {
                if (s === "CANCELED") return "status-canceled";
                if (s === "PAYMENT_PENDING") return "status-pending";
                return "status-paid";
            },
            fnDetail() {
                let self = this;
                $.ajax({
                    url: "/order/detail.dox",
                    type: "POST",
                    data: { orderId: self.orderId },
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            self.order = data.order;
                            self.items = data.items || [];
                            self.payment = data.payment || null;
                            self.cancelInfo = data.cancelInfo || null;
                        } else {
                            alert(data.message || "주문 상세 조회에 실패했습니다.");
                            location.href = "/order/list.do";
                        }
                    }
                });
            },
            fnOpenCancelModal() { 
                this.selectedReason = "단순 변심"; 
                this.customReason = ""; 
                this.showCancelModal = true; 
            },
            fnConfirmCancel() {
                if (this.isCanceling) return;
                let self = this;
                let reason = this.selectedReason === "기타 (직접 입력)" ? ("기타: " + this.customReason.trim()) : this.selectedReason;
                if (this.selectedReason === "기타 (직접 입력)" && !this.customReason.trim()) { alert("취소 사유를 입력해주세요."); return; }
                this.isCanceling = true;
                $.ajax({
                    url: "/order/cancel.dox",
                    type: "POST",
                    data: { orderId: self.orderId, cancelReason: reason },
                    dataType: "json",
                    success: function (data) {
                        alert(data.message);
                        if (data.result === "success") { self.showCancelModal = false; self.fnDetail(); }
                    },
                    complete: function () {
                        self.isCanceling = false;
                    }
                });
            },

            fnCopyGiftMessage() {
                let self = this;
                if (!this.giftNoticeText) return;
                navigator.clipboard.writeText(this.giftNoticeText).then(function () {
                    self.copiedGiftMsg = true;
                    setTimeout(function () { self.copiedGiftMsg = false; }, 2000);
                }).catch(function () {
                    alert("메시지 복사에 실패했습니다. 직접 드래그하여 복사해주세요.");
                });
            }

        },
        mounted() { this.fnDetail(); }
    });
    app.mount('#app');
</script>
