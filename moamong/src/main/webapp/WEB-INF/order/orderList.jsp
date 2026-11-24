<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 - 주문 내역</title>
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
        .btn { padding: 6px 13px; border: 1px solid #ccc; background: #fff; border-radius: 6px; cursor: pointer; font-size: 13px; font-weight: 600; color: #222; }
        .btn:hover { background: #f1f3f5; }
        .btn-danger { border-color: #ffa8a8; color: #c92a2a; }
        .order-card { border: 1px solid #dee2e6; border-radius: 10px; margin-bottom: 18px; overflow: hidden; }
        .order-head { background: #f8f9fa; padding: 13px 18px; border-bottom: 1px solid #e9ecef; display: flex; justify-content: space-between; align-items: center; font-size: 13px; }
        .status-badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 12px; }
        .status-paid { background: #e7f5ff; color: #1971c2; }
        .status-pending { background: #fff3bf; color: #e67700; }
        .status-canceled { background: #ffe3e3; color: #c92a2a; }
        .order-body { padding: 16px 18px; }
        .item-row { display: flex; align-items: flex-start; gap: 12px; padding: 10px 0; border-bottom: 1px solid #f1f3f5; }
        .item-row:last-child { border-bottom: none; }
        .thumb { width: 58px; height: 58px; border-radius: 6px; object-fit: cover; background: #f1f3f5; border: 1px solid #e9ecef; }
        .snapshot-box { margin-top: 6px; padding-left: 10px; border-left: 2px solid #dee2e6; font-size: 12px; color: #666; line-height: 1.5; }
        .order-foot { background: #fcfcfc; padding: 12px 18px; border-top: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; font-size: 13px; }
        .empty-box { text-align: center; padding: 60px 0; color: #888; }
        .modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.45); display: flex; align-items: center; justify-content: center; z-index: 999; }
        .modal-box { background: #fff; width: 92%; max-width: 420px; border-radius: 12px; padding: 22px; box-shadow: 0 8px 24px rgba(0,0,0,0.15); }
        .reason-item { display: flex; align-items: center; gap: 8px; padding: 9px 10px; border: 1px solid #eee; border-radius: 6px; margin-bottom: 8px; cursor: pointer; font-size: 14px; }
        .filter-tabs { display: flex; gap: 8px; margin-bottom: 18px; }
        .tab-btn {
            padding: 8px 16px; border: 1px solid #dee2e6; background: #fff;
            border-radius: 20px; cursor: pointer; font-size: 13px; font-weight: 600; color: #555;
        }
        .tab-btn:hover { background: #f1f3f5; }
        .tab-btn.active { background: #222; color: #fff; border-color: #222; }
    </style>
</head>
<body>
    <div id="app" class="container">
                <div class="top-nav">
            <h2>📦 주문 내역 조회</h2>
            <div style="display:flex; gap:8px;">
                <button class="btn" @click="fnGoCancelList">취소/환불 내역</button>
                <button class="btn" @click="fnGoCart">장바구니</button>
                <button class="btn" @click="fnGoMypage">마이페이지</button>
                <button class="btn" @click="fnGoMain">메인으로</button>
            </div>
        </div>

        <div class="filter-tabs">
            <button class="tab-btn" :class="{ active: currentTab === 'ALL' }" @click="currentTab = 'ALL'">
                전체 ({{ orderList.length }})
            </button>
            <button class="tab-btn" :class="{ active: currentTab === 'PAID' }" @click="currentTab = 'PAID'">
                결제완료 ({{ paidCount }})
            </button>
            <button class="tab-btn" :class="{ active: currentTab === 'CANCELED' }" @click="currentTab = 'CANCELED'">
                주문취소 ({{ canceledCount }})
            </button>
        </div>
        <div v-if="filteredOrderList.length === 0" class="empty-box">해당 상태의 주문 내역이 없습니다.</div>

        <div v-for="order in filteredOrderList" :key="order.orderId" class="order-card">

            <div class="order-body">
                <div v-for="item in order.items" :key="item.orderItemId" class="item-row">
                    <img class="thumb"
                    :src="(item.thumbnailUrl && item.thumbnailUrl.trim()) ? item.thumbnailUrl : defaultThumb"
                    @error="fnImgError">
                    <div style="flex:1;">
                        <div>
                            <span style="font-size:11px; color:#666;">{{ item.itemType === 'PRODUCT' ? '[단품]' : '[패키지]' }}</span>
                            <strong style="font-size:14px; margin-left:4px;">{{ item.itemNameSnapshot }}</strong>
                        </div>
                        <div style="font-size:13px; color:#555; margin-top:2px;">
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

                <div style="margin-top:12px; padding-top:10px; border-top:1px dashed #eee; font-size:13px; color:#555;">
                    <strong>배송지:</strong> {{ order.recipientName }} ({{ order.recipientPhone }}) ·
                    ({{ order.postalCode }}) {{ order.addressDefault }} {{ order.addressDetail }}
                </div>

                <div v-if="order.orderStatus === 'CANCELED' && order.cancelInfo"
                     style="margin-top:8px; padding:8px 12px; background:#fff5f5; border-radius:6px; font-size:12px; color:#c92a2a;">
                    <strong>취소 완료 ({{ order.cancelInfo.createdAt }}):</strong> {{ order.cancelInfo.cancelReason }}
                </div>
            </div>

            <div class="order-foot">
                <div>
                    상품 {{ Number(order.totalProductAmount + order.totalAdditionalAmount).toLocaleString() }}원 +
                    배송비 {{ Number(order.shippingFee).toLocaleString() }}원 =
                    <strong style="font-size:16px; color:#222;">총 {{ Number(order.finalAmount).toLocaleString() }}원</strong>
                </div>
                <div style="display:flex; gap:6px;">
                    <button class="btn" @click="fnGoDetail(order.orderId)">주문 상세</button>
                    <button v-if="order.orderStatus === 'PAID' || order.orderStatus === 'PAYMENT_PENDING'"
                            class="btn btn-danger" @click="fnCancelOrder(order.orderId)">주문 취소</button>
                </div>
            </div>
        </div>
        <div v-if="showCancelModal" class="modal-backdrop" @click.self="showCancelModal = false">
            <div class="modal-box">
                <h3 style="margin:0 0 14px 0; font-size:18px;">주문 취소 사유 선택</h3>
                <label v-for="r in cancelReasons" :key="r" class="reason-item">
                    <input type="radio" :value="r" v-model="selectedReason">
                    <span>{{ r }}</span>
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
                orderList: [],
                currentTab: "ALL",   // <--- 추가 (쉼표 확인!)
                defaultThumb: "data:image/svg+xml;utf8,<svg xmlns='http://w3.org' width='100' height='100'><rect width='100' height='100' fill='%23f1f3f5'/></svg>",
                showCancelModal: false,
                cancelTargetOrderId: null,
                cancelReasons: ["단순 변심", "옵션 / 수량 선택 실수", "배송지 입력 오류", "다른 상품으로 재주문 예정", "기타 (직접 입력)"],
                selectedReason: "단순 변심",
                customReason: ""
            };
        },
        methods: {
            fnGoMain() { location.href = "/"; },
            fnGoMypage() { location.href = "/member/mypage.do"; },
            fnGoCart() { location.href = "/cart/list.do"; },
            fnGoDetail(orderId) { location.href = "/order/detail.do?orderId=" + orderId; },
                        fnGoCancelList() { location.href = "/order/cancel-list.do"; },


            fnImgError(e) {
                e.target.onerror = null;
                e.target.src = this.defaultThumb;
            },

            fnStatusLabel(status) {
                const map = {
                    PAYMENT_PENDING: "결제대기",
                    PAID: "결제완료",
                    PREPARING: "상품준비중",
                    SHIPPING: "배송중",
                    DELIVERED: "배송완료",
                    CANCELED: "주문취소"
                };
                return map[status] || status;
            },
            fnStatusClass(status) {
                if (status === "CANCELED") return "status-canceled";
                if (status === "PAYMENT_PENDING") return "status-pending";
                return "status-paid";
            },
            fnList() {
                let self = this;
                $.ajax({
                    url: "/order/list.dox",
                    type: "POST",
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            self.orderList = data.list || [];
                        } else {
                            alert(data.message || "주문 내역 조회에 실패했습니다.");
                        }
                    }
                });
            },
            fnCancelOrder(orderId) {
                this.cancelTargetOrderId = orderId;
                this.selectedReason = "단순 변심";
                this.customReason = "";
                this.showCancelModal = true;
            },
            fnConfirmCancel() {
                let self = this;
                let finalReason = this.selectedReason;
                if (finalReason === "기타 (직접 입력)") {
                    if (!this.customReason.trim()) {
                        alert("기타 취소 사유를 입력해주세요.");
                        return;
                    }
                    finalReason = "기타: " + this.customReason.trim();
                }

                $.ajax({
                    url: "/order/cancel.dox",
                    type: "POST",
                    data: { orderId: this.cancelTargetOrderId, cancelReason: finalReason },
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            alert(data.message);
                            self.showCancelModal = false;
                            self.fnList();
                        } else {
                            alert(data.message || "주문 취소에 실패했습니다.");
                        }
                    }
                });
            },
            
        },
        mounted() {
            this.fnList();
        },

        computed: {
            paidCount() {
                return this.orderList.filter(o => o.orderStatus !== "CANCELED").length;
            },
            canceledCount() {
                return this.orderList.filter(o => o.orderStatus === "CANCELED").length;
            },
            filteredOrderList() {
                if (this.currentTab === "ALL") {
                    return this.orderList;
                }
                if (this.currentTab === "CANCELED") {
                    return this.orderList.filter(o => o.orderStatus === "CANCELED");
                }
                return this.orderList.filter(o => o.orderStatus !== "CANCELED");
            }
        },
    });

    app.mount('#app');
</script>

