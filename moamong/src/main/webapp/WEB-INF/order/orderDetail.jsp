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
        <style>
            body { font-family: 'Pretendard', sans-serif; background: #f8f9fa; margin: 0; padding: 30px 16px; color: #222; }
            .container { max-width: 900px; margin: 0 auto; background: #fff; border-radius: 12px; padding: 28px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); }
            .top-nav { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #222; padding-bottom: 14px; margin-bottom: 20px; }
            .top-nav h2 { margin: 0; font-size: 22px; }
            .btn { padding: 7px 14px; border: 1px solid #ccc; background: #fff; border-radius: 6px; cursor: pointer; font-size: 13px; font-weight: 600; color: #222; }
            .btn:hover { background: #f1f3f5; }
            .btn-danger { border-color: #ffa8a8; color: #c92a2a; }
            .section-card { border: 1px solid #dee2e6; border-radius: 10px; margin-bottom: 18px; overflow: hidden; }
            .section-head { background: #f8f9fa; padding: 12px 18px; border-bottom: 1px solid #e9ecef; font-size: 14px; font-weight: 700; display: flex; justify-content: space-between; align-items: center; }
            .section-body { padding: 16px 18px; }
            .status-badge { display: inline-block; padding: 3px 9px; border-radius: 4px; font-weight: 700; font-size: 12px; }
            .status-paid { background: #e7f5ff; color: #1971c2; }
            .status-pending { background: #fff3bf; color: #e67700; }
            .status-canceled { background: #ffe3e3; color: #c92a2a; }
            .item-row { display: flex; align-items: flex-start; gap: 12px; padding: 12px 0; border-bottom: 1px solid #f1f3f5; }
            .item-row:last-child { border-bottom: none; }
            .thumb { width: 64px; height: 64px; border-radius: 6px; object-fit: cover; background: #f1f3f5; border: 1px solid #e9ecef; }
            .snapshot-box { margin-top: 6px; padding-left: 10px; border-left: 2px solid #dee2e6; font-size: 12px; color: #666; line-height: 1.5; }
            .info-table { width: 100%; border-collapse: collapse; font-size: 13px; }
            .info-table th { width: 130px; text-align: left; padding: 8px 4px; color: #666; font-weight: 600; vertical-align: top; }
            .info-table td { padding: 8px 4px; color: #222; }
            .price-row { display: flex; justify-content: space-between; padding: 6px 0; font-size: 14px; color: #555; }
            .price-total { display: flex; justify-content: space-between; padding-top: 12px; margin-top: 8px; border-top: 1px solid #dee2e6; font-size: 17px; font-weight: 700; color: #222; }
            .modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.45); display: flex; align-items: center; justify-content: center; z-index: 999; }
            .modal-box { background: #fff; width: 92%; max-width: 420px; border-radius: 12px; padding: 22px; box-shadow: 0 8px 24px rgba(0,0,0,0.15); }
            .reason-item { display: flex; align-items: center; gap: 8px; padding: 9px 10px; border: 1px solid #eee; border-radius: 6px; margin-bottom: 8px; cursor: pointer; font-size: 14px; }
        </style>
    </head>
    <body>
        <div id="app" class="container">
            <div class="top-nav">
                <h2>🧾 주문 상세 내역</h2>
                <div style="display:flex; gap:8px;">
                    <button class="btn" @click="fnGoList">주문 목록</button>
                    <button class="btn" @click="fnGoMypage">마이페이지</button>
                    <button class="btn" @click="fnGoMain">메인으로</button>
                </div>
            </div>

            <div v-if="order">
                <!-- 1. 주문 기본 요약 -->
                <div class="section-card">
                    <div class="section-head">
                        <span>주문번호: {{ order.orderNumber }}</span>
                        <span class="status-badge" :class="statusClass(order.orderStatus)">{{ statusText(order.orderStatus) }}</span>
                    </div>
                    <div class="section-body" style="font-size:13px; color:#555;">
                        주문일시: <strong>{{ order.orderedAt }}</strong>
                    </div>
                </div>

                <!-- 2. 주문 상품 및 패키지 구성 스냅샷 -->
                <div class="section-card">
                    <div class="section-head"><span>주문 상품 정보 ({{ items.length }}건)</span></div>
                    <div class="section-body">
                        <div v-for="item in items" :key="item.orderItemId" class="item-row">
                            <img class="thumb" :src="(item.thumbnailUrl && item.thumbnailUrl.trim()) ? item.thumbnailUrl : defaultThumb" @error="fnImgError">
                            <div style="flex:1;">
                                <div>
                                    <span style="font-size:11px; color:#666;">{{ item.itemType === 'PRODUCT' ? '[단품]' : '[패키지]' }}</span>
                                    <strong style="font-size:14px; margin-left:4px;">{{ item.itemNameSnapshot }}</strong>
                                </div>
                                <div style="font-size:13px; color:#555; margin-top:4px;">
                                    {{ Number(item.unitPrice).toLocaleString() }}원 × {{ item.quantity }}개 =
                                    <strong>{{ Number(item.lineAmount).toLocaleString() }}원</strong>
                                </div>
                                <div v-if="item.itemType === 'PACKAGE'" class="snapshot-box">
                                    <div v-for="pi in item.packageItems" :key="pi.orderPackageItemId">
                                        • [{{ pi.itemRole }}] {{ pi.productNameSnapshot }} (x{{ pi.quantity }})
                                        <span v-if="pi.additionalPrice > 0">(+{{ Number(pi.additionalPrice).toLocaleString() }}원)</span>
                                    </div>
                                    <div v-for="pe in item.packageExtras" :key="pe.orderPackageExtraId">
                                        • [추가옵션] {{ pe.optionNameSnapshot }}
                                        <span v-if="pe.additionalPrice > 0">(+{{ Number(pe.additionalPrice).toLocaleString() }}원)</span>
                                        <span v-if="pe.optionValue" style="color:#d9480f;"> | 메시지: "{{ pe.optionValue }}"</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 3. 배송지 정보 -->
                <div class="section-card">
                    <div class="section-head"><span>배송지 정보</span></div>
                    <div class="section-body">
                        <table class="info-table">
                            <tr><th>수령인</th><td>{{ order.recipientName }}</td></tr>
                            <tr><th>연락처</th><td>{{ order.recipientPhone }}</td></tr>
                            <tr><th>배송 주소</th><td>({{ order.postalCode }}) {{ order.addressDefault }} {{ order.addressDetail }}</td></tr>
                        </table>
                    </div>
                </div>

                <!-- 4. 결제 및 환불 정보 -->
                <div class="section-card">
                    <div class="section-head"><span>결제 금액 상세</span></div>
                    <div class="section-body">
                        <div class="price-row"><span>기본 상품 금액</span><span>{{ Number(order.totalProductAmount).toLocaleString() }}원</span></div>
                        <div class="price-row"><span>옵션 추가 금액</span><span>+ {{ Number(order.totalAdditionalAmount).toLocaleString() }}원</span></div>
                        <div class="price-row"><span>배송비</span><span>+ {{ Number(order.shippingFee).toLocaleString() }}원</span></div>
                        <div class="price-total"><span>최종 결제 금액</span><span>{{ Number(order.finalAmount).toLocaleString() }}원</span></div>

                        <div v-if="payment" style="margin-top:12px; padding-top:10px; border-top:1px dashed #eee; font-size:13px; color:#555;">
                            결제수단: <strong>{{ payment.payMethod }}</strong> ·
                            결제상태: <strong>{{ payment.paymentStatus }}</strong> ·
                            결제일시: {{ payment.paidAt }}
                        </div>
                        <div v-if="order.orderStatus === 'CANCELED' && cancelInfo"
                        style="margin-top:10px; padding:10px 12px; background:#fff5f5; border-radius:6px; font-size:13px; color:#c92a2a;">
                        <strong>취소 완료 ({{ cancelInfo.createdAt }}):</strong> {{ cancelInfo.cancelReason }}
                        (환불금액: {{ Number(cancelInfo.cancelAmount).toLocaleString() }}원)
                    </div>
                </div>
            </div>

            <div style="display:flex; justify-content:space-between; margin-top:20px;">
                <button class="btn" @click="fnGoList">← 목록으로 돌아가기</button>
                <button v-if="order.orderStatus === 'PAID' || order.orderStatus === 'PAYMENT_PENDING'"
                class="btn btn-danger" @click="fnOpenCancelModal">주문 취소</button>
            </div>
        </div>

        <!-- 주문 취소 사유 모달 -->
        <div v-if="showCancelModal" class="modal-backdrop" @click.self="showCancelModal = false">
            <div class="modal-box">
                <h3 style="margin:0 0 14px 0; font-size:18px;">주문 취소 사유 선택</h3>
                <label v-for="r in cancelReasons" :key="r" class="reason-item">
                    <input type="radio" :value="r" v-model="selectedReason"><span>{{ r }}</span>
                </label>
                <div v-if="selectedReason === '기타 (직접 입력)'" style="margin-top:8px;">
                    <textarea v-model="customReason" rows="3" maxlength="200"
                    style="width:100%; box-sizing:border-box; padding:8px; border:1px solid #ccc; border-radius:6px; font-size:13px;"
                    placeholder="취소 사유를 직접 입력해주세요 (최대 200자)"></textarea>
                </div>
                <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:16px;">
                    <button class="btn" @click="showCancelModal = false">닫기</button>
                    <button class="btn btn-danger" @click="fnConfirmCancel">취소 확정</button>
                </div>
            </div>
        </div>
    </div>
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
                customReason: ""
            };
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
            fnOpenCancelModal() { this.selectedReason = "단순 변심"; this.customReason = ""; this.showCancelModal = true; },
            fnConfirmCancel() {
                let self = this;
                let reason = this.selectedReason === "기타 (직접 입력)" ? ("기타: " + this.customReason.trim()) : this.selectedReason;
                if (this.selectedReason === "기타 (직접 입력)" && !this.customReason.trim()) { alert("취소 사유를 입력해주세요."); return; }
                $.ajax({
                    url: "/order/cancel.dox",
                    type: "POST",
                    data: { orderId: self.orderId, cancelReason: reason },
                    dataType: "json",
                    success: function (data) {
                        alert(data.message);
                        if (data.result === "success") { self.showCancelModal = false; self.fnDetail(); }
                    }
                });
            }
        },
        mounted() { this.fnDetail(); }
    });
    app.mount('#app');
</script>
