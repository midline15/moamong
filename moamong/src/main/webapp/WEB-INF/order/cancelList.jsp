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
        <style>
            body { font-family: 'Pretendard', sans-serif; background: #f8f9fa; margin: 0; padding: 30px 16px; color: #222; }
            .container { max-width: 900px; margin: 0 auto; background: #fff; border-radius: 12px; padding: 28px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); }
            .top-nav { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #222; padding-bottom: 14px; margin-bottom: 20px; }
            .top-nav h2 { margin: 0; font-size: 22px; }
            .btn { padding: 6px 13px; border: 1px solid #ccc; background: #fff; border-radius: 6px; cursor: pointer; font-size: 13px; font-weight: 600; color: #222; }
            .btn:hover { background: #f1f3f5; }
            .filter-tabs { display: flex; gap: 8px; margin-bottom: 18px; }
            .tab-btn { padding: 8px 16px; border: 1px solid #dee2e6; background: #fff; border-radius: 20px; cursor: pointer; font-size: 13px; font-weight: 600; color: #555; }
            .tab-btn.active { background: #222; color: #fff; border-color: #222; }
            .claim-card { border: 1px solid #dee2e6; border-radius: 10px; margin-bottom: 14px; overflow: hidden; }
            .claim-head { background: #f8f9fa; padding: 12px 18px; border-bottom: 1px solid #e9ecef; display: flex; justify-content: space-between; align-items: center; font-size: 13px; }
            .claim-body { padding: 16px 18px; display: flex; justify-content: space-between; align-items: center; gap: 12px; }
            .badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-weight: 700; font-size: 12px; }
            .badge-done { background: #ffe3e3; color: #c92a2a; }
            .badge-wait { background: #fff3bf; color: #e67700; }
            .empty-box { text-align: center; padding: 60px 0; color: #888; }
            .modal-backdrop { position: fixed; inset: 0; background: rgba(0,0,0,0.45); display: flex; align-items: center; justify-content: center; z-index: 999; }
            .modal-box { background: #fff; width: 92%; max-width: 540px; max-height: 85vh; overflow-y: auto; border-radius: 12px; padding: 24px; box-shadow: 0 8px 24px rgba(0,0,0,0.15); }
            .detail-row { display: flex; justify-content: space-between; padding: 7px 0; border-bottom: 1px solid #f1f3f5; font-size: 13px; }
            .snapshot-box { margin-top: 6px; padding-left: 10px; border-left: 2px solid #dee2e6; font-size: 12px; color: #666; }
        </style>
    </head>
    <body>
        <div id="app" class="container">
            <div class="top-nav">
                <h2>💸 취소 / 반품 / 환불 내역</h2>
                <div style="display:flex; gap:8px;">
                    <button class="btn" @click="fnGoOrders">주문 내역</button>
                    <button class="btn" @click="fnGoMypage">마이페이지</button>
                    <button class="btn" @click="fnGoMain">메인으로</button>
                </div>
            </div>

            <div class="filter-tabs">
                <button class="tab-btn" :class="{ active: tab === 'ALL' }" @click="tab = 'ALL'">전체 ({{ list.length }})</button>
                <button class="tab-btn" :class="{ active: tab === 'CANCEL' }" @click="tab = 'CANCEL'">주문취소 ({{ cancelCount }})</button>
                <button class="tab-btn" :class="{ active: tab === 'RETURN' }" @click="tab = 'RETURN'">반품/환불 ({{ returnCount }})</button>
            </div>

            <div v-if="filteredList.length === 0" class="empty-box">취소 및 환불 내역이 없습니다.</div>

            <div v-for="row in filteredList" :key="row.claimType + '_' + row.claimId" class="claim-card">
                <div class="claim-head">
                    <span><strong>{{ row.claimType === 'CANCEL' ? '[주문취소]' : '[반품/환불]' }}</strong> 주문번호: {{ row.orderNumber }}</span>
                    <span class="badge" :class="row.status === 'COMPLETED' ? 'badge-done' : 'badge-wait'">
                        {{ row.status === 'COMPLETED' ? '환불완료' : '환불대기' }}
                    </span>
                </div>
                <div class="claim-body">
                    <div>
                        <div style="font-size:15px; font-weight:700;">
                            {{ row.repItemName }} <span v-if="row.itemCount > 1" style="font-size:13px; color:#666;">외 {{ row.itemCount - 1 }}건</span>
                        </div>
                        <div style="font-size:13px; color:#555; margin-top:4px;">사유: {{ row.reason }} · 신청일: {{ row.requestedAt }}</div>
                        <div style="font-size:14px; font-weight:700; color:#c92a2a; margin-top:6px;">
                            환불금액: {{ Number(row.refundAmount).toLocaleString() }}원 ({{ row.refundMethod }})
                        </div>
                    </div>
                    <button class="btn" @click="fnOpenDetail(row)">상세 내역</button>
                </div>
            </div>

            <!-- 취소/환불 상세 내역 모달 -->
            <div v-if="detail" class="modal-backdrop" @click.self="detail = null">
                <div class="modal-box">
                    <h3 style="margin:0 0 14px 0; font-size:18px;">취소 · 환불 상세 내역</h3>
                    <div class="detail-row"><span>구분</span><strong>{{ detail.claimType === 'CANCEL' ? '주문 즉시 취소' : '반품 및 환불' }}</strong></div>
                    <div class="detail-row"><span>주문번호</span><span>{{ detail.order.orderNumber }}</span></div>
                    <div class="detail-row"><span>처리상태</span><strong style="color:#c92a2a;">{{ detail.statusText }}</strong></div>
                    <div class="detail-row"><span>사유</span><span>{{ detail.reasonText }}</span></div>
                    <div class="detail-row"><span>환불수단</span><span>{{ detail.payment ? detail.payment.payMethod : 'CARD' }}</span></div>
                    <div class="detail-row"><span>최종 환불금액</span><strong>{{ Number(detail.refundAmount).toLocaleString() }}원</strong></div>
                    <div class="detail-row"><span>처리완료일시</span><span>{{ detail.processedAt || '-' }}</span></div>

                    <div style="margin-top:14px; font-weight:700; font-size:13px;">대상 상품 내역</div>
                    <div v-for="it in detail.items" :key="it.orderItemId" style="padding:8px 0; border-bottom:1px solid #eee; font-size:13px;">
                        <div><strong>{{ it.itemNameSnapshot }}</strong> ({{ it.quantity }}개 / {{ Number(it.lineAmount).toLocaleString() }}원)</div>
                        <div v-if="it.itemType === 'PACKAGE'" class="snapshot-box">
                            <div v-for="pi in it.packageItems" :key="pi.orderPackageItemId">• {{ pi.productNameSnapshot }} (x{{ pi.quantity }})</div>
                            <div v-for="pe in it.packageExtras" :key="pe.orderPackageExtraId">• {{ pe.optionNameSnapshot }} <span v-if="pe.optionValue">| "{{ pe.optionValue }}"</span></div>
                        </div>
                    </div>
                    <div style="display:flex; justify-content:flex-end; margin-top:16px;">
                        <button class="btn" @click="detail = null">닫기</button>
                    </div>
                </div>
            </div>
        </div>
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
    </body>
</html>
