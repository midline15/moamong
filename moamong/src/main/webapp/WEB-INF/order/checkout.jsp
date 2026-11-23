<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 - 주문서 작성</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <script src="https://daumcdn.net"></script>
        <style>
            body {
                font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;
                background-color: #f8f9fa;
                margin: 0;
                padding: 30px 16px;
                color: #222;
            }
            .container {
                max-width: 900px;
                margin: 0 auto;
                background: #fff;
                border-radius: 12px;
                padding: 28px;
                box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
            }
            .top-nav {
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-bottom: 2px solid #222;
                padding-bottom: 14px;
                margin-bottom: 24px;
            }
            .top-nav h2 { margin: 0; font-size: 22px; }
            .section-title {
                font-size: 16px;
                font-weight: 700;
                margin: 24px 0 12px 0;
                padding-bottom: 8px;
                border-bottom: 1px solid #dee2e6;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .btn {
                padding: 7px 14px;
                border: 1px solid #ccc;
                background: #fff;
                border-radius: 6px;
                cursor: pointer;
                font-size: 13px;
                font-weight: 600;
                color: #222;
            }
            .btn:hover { background: #f1f3f5; }
            .btn-primary {
                background: #222; color: #fff; border-color: #222;
                font-size: 16px; padding: 14px 36px;
            }
            .btn-primary:hover { background: #444; }
            .form-grid {
                display: grid;
                grid-template-columns: 120px 1fr;
                gap: 10px 14px;
                align-items: center;
                background: #fafafa;
                padding: 18px;
                border-radius: 8px;
                border: 1px solid #eee;
            }
            .form-grid label { font-size: 13px; font-weight: 600; color: #495057; }
            .form-control {
                width: 100%; box-sizing: border-box;
                padding: 8px 11px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px; background: #fff;
            }
            .item-card {
                border: 1px solid #eee;
                border-radius: 8px;
                padding: 14px 16px;
                margin-bottom: 10px;
            }
            .item-row { display: flex; align-items: center; gap: 14px; }
            .thumb { width: 64px; height: 64px; border-radius: 8px; object-fit: cover; background: #f1f3f5; border: 1px solid #e9ecef; }
            .option-list {
                margin-top: 8px; padding-left: 10px; border-left: 2px solid #dee2e6;
                font-size: 12px; color: #666; line-height: 1.6;
            }
            .card-msg-box {
                margin-top: 8px; padding: 10px 12px; background: #fff9db; border-radius: 6px; border: 1px solid #ffe066;
            }
            .price-summary {
                margin-top: 24px;
                padding: 20px 24px;
                background: #f8f9fa;
                border-radius: 10px;
                border: 1px solid #e9ecef;
            }
            .price-line { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 14px; color: #555; }
            .price-final {
                display: flex; justify-content: space-between; align-items: center;
                margin-top: 14px; padding-top: 14px; border-top: 1px solid #dee2e6;
                font-size: 20px; font-weight: 700; color: #d9480f;
            }
            .modal-backdrop {
                position: fixed; inset: 0; background: rgba(0, 0, 0, 0.45);
                display: flex; align-items: center; justify-content: center; z-index: 999;
            }
            .modal-box {
                background: #fff; width: 92%; max-width: 480px; max-height: 80vh; overflow-y: auto;
                border-radius: 12px; padding: 22px;
            }
            .addr-pick {
                border: 1px solid #ddd; border-radius: 8px; padding: 12px 14px; margin-bottom: 10px; cursor: pointer;
            }
            .addr-pick:hover { background: #f8f9fa; border-color: #222; }
        </style>
    </head>
    <body>
        <div id="app" class="container">
            <div class="top-nav">
                <h2>🧾 주문서 작성</h2>
                <button class="btn" @click="fnGoCart">장바구니로 돌아가기</button>
            </div>

            <div class="section-title">
                <span>1. 배송지 정보</span>
                <div style="display:flex; gap:6px;">
                    <button v-if="addressList.length > 0" class="btn" @click="showAddrModal = true">배송지 목록 선택</button>
                    <button class="btn" @click="fnGoAddress">배송지 관리</button>
                </div>
            </div>

            <div class="form-grid">
                <label>수령인 이름 *</label>
                <input type="text" class="form-control" v-model="delivery.recipientName" placeholder="수령인 이름">
                <label>연락처 *</label>
                <input type="text" class="form-control" v-model="delivery.recipientPhone" placeholder="010-0000-0000">
                <label>우편번호 *</label>
                <div style="display:flex; gap:8px;">
                    <input type="text" class="form-control" v-model="delivery.postalCode" readonly style="width:140px; background:#f1f3f5;">
                    <button type="button" class="btn" @click="fnSearchPostcode">우편번호 검색</button>
                </div>
                <label>기본 주소 *</label>
                <input type="text" class="form-control" v-model="delivery.addressDefault" readonly style="background:#f1f3f5;">
                <label>상세 주소</label>
                <input type="text" class="form-control" v-model="delivery.addressDetail" placeholder="동/호수 등 상세 주소">
            </div>

            <div class="section-title"><span>2. 주문 상품 ({{ items.length }}건)</span></div>

            <div v-for="item in items" :key="item.cartItemId" class="item-card">
                <div class="item-row">
                    <img class="thumb" :src="item.thumbnailUrl || defaultThumb" @error="fnImgError">
                    <div style="flex:1;">
                        <div style="font-size:12px; color:#666; margin-bottom:2px;">{{ item.itemType === 'PRODUCT' ? '[단품]' : '[패키지]' }}</div>
                        <strong style="font-size:15px;">{{ item.itemName }}</strong>
                        <div style="font-size:13px; color:#555; margin-top:4px;">{{ Number(item.unitPrice).toLocaleString() }}원 × {{ item.quantity }}개</div>
                    </div>
                    <strong style="font-size:16px;">{{ Number(item.lineAmount).toLocaleString() }}원</strong>
                </div>

                <div v-if="item.itemType === 'PACKAGE'" class="option-list">
                    <div v-for="pi in item.packageItems" :key="pi.cartPackageItemId">
                        • [{{ pi.itemRole }}] {{ pi.selectedProductName }} (x{{ pi.itemQuantity }})
                        <span v-if="pi.additionalPrice > 0">(+{{ Number(pi.additionalPrice).toLocaleString() }}원)</span>
                    </div>
                    <div v-for="pe in item.packageExtras" :key="pe.cartPackageExtraId">
                        • [추가옵션] {{ pe.extraName }}: {{ pe.optionName }}
                        <span v-if="pe.additionalPrice > 0">(+{{ Number(pe.additionalPrice).toLocaleString() }}원)</span>
                        <div v-if="pe.extraType === 'CARD'" class="card-msg-box">
                            <div style="font-weight:600; color:#222; margin-bottom:4px;">✉️ 카드 메시지 입력 (선택)</div>
                            <input type="text" class="form-control" v-model="extraValues[pe.cartPackageExtraId]" maxlength="500" placeholder="동봉할 카드 문구를 입력해주세요 (최대 500자)">
                        </div>
                    </div>
                </div>
            </div>

            <div class="price-summary">
                <div class="price-line"><span>기본 상품 금액</span><span>{{ totalProductAmount.toLocaleString() }}원</span></div>
                <div class="price-line"><span>옵션 추가 금액</span><span>+ {{ totalAdditionalAmount.toLocaleString() }}원</span></div>
                <div class="price-line"><span>배송비 (30,000원 이상 무료)</span><span>{{ shippingFee === 0 ? '무료 (0원)' : '+ ' + shippingFee.toLocaleString() + '원' }}</span></div>
                <div class="price-final"><span>최종 결제 금액</span><span>{{ finalAmount.toLocaleString() }}원</span></div>
            </div>

            <div style="text-align:center; margin-top:24px;">
                <button class="btn btn-primary" @click="fnSubmitOrder">{{ finalAmount.toLocaleString() }}원 결제하기</button>
            </div>

            <div v-if="showAddrModal" class="modal-backdrop" @click.self="showAddrModal = false">
                <div class="modal-box">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px;">
                        <strong>배송지 선택</strong><button class="btn" @click="showAddrModal = false">닫기</button>
                    </div>
                    <div v-for="addr in addressList" :key="addr.addressId" class="addr-pick" @click="fnSelectAddress(addr)">
                        <div style="font-weight:700; margin-bottom:4px;">
                            {{ addr.addressName || addr.recipientName }}
                            <span v-if="addr.isDefault == 1" style="font-size:11px; background:#222; color:#fff; padding:1px 6px; border-radius:4px; margin-left:4px;">기본</span>
                        </div>
                        <div style="font-size:13px; color:#555;">{{ addr.recipientName }} | {{ addr.recipientPhone }}</div>
                        <div style="font-size:13px; color:#555;">({{ addr.postalCode }}) {{ addr.addressDefault }} {{ addr.addressDetail }}</div>
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
                cartItemIdsStr: "${cartItemIds}",
                items: [],
                addressList: [],
                showAddrModal: false,
                delivery: {
                    recipientName: "",
                    recipientPhone: "",
                    postalCode: "",
                    addressDefault: "",
                    addressDetail: ""
                },
                extraValues: {},
                totalProductAmount: 0,
                totalAdditionalAmount: 0,
                shippingFee: 0,
                finalAmount: 0,
                defaultThumb: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIj48cmVjdCB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iI2YxZjNmNSIvPjx0ZXh0IHg9IjUwJSIgeT0iNTQlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjODY4ZTk2IiBmb250LWZhbWlseT0ic2Fucy1zZXJpZiIgZm9udC1zaXplPSIxMiI+TU9BTU9ORzwvdGV4dD48L3N2Zz4="
            };
        },
        methods: {
            fnGoCart() { location.href = "/cart/list.do"; },
            fnGoAddress() { location.href = "/address/list.do"; },
            fnImgError(e) { e.target.src = this.defaultThumb; },
            
            fnLoadCheckout() {
                let self = this;
                $.ajax({
                    url: "/order/checkout.dox",
                    type: "POST",
                    data: { cartItemIds: this.cartItemIdsStr },
                    dataType: "json",
                    success: function (data) {
                        if (data.result !== "success") {
                            alert(data.message || "주문서 정보를 불러올 수 없습니다.");
                            location.href = "/cart/list.do";
                            return;
                        }
                        self.items = data.items || [];
                        self.addressList = data.addressList || [];
                        self.totalProductAmount = data.totalProductAmount || 0;
                        self.totalAdditionalAmount = data.totalAdditionalAmount || 0;
                        self.shippingFee = data.shippingFee || 0;
                        self.finalAmount = data.finalAmount || 0;
                        
                        if (data.defaultAddress) {
                            self.fnSelectAddress(data.defaultAddress);
                        }
                    }
                });
            },
            fnSelectAddress(addr) {
                this.delivery.recipientName = addr.recipientName || "";
                this.delivery.recipientPhone = addr.recipientPhone || "";
                this.delivery.postalCode = addr.postalCode || "";
                this.delivery.addressDefault = addr.addressDefault || "";
                this.delivery.addressDetail = addr.addressDetail || "";
                this.showAddrModal = false;
            },
            fnSearchPostcode() {
                let self = this;
                if (typeof daum !== "undefined" && daum.Postcode) {
                    new daum.Postcode({
                        oncomplete: function (data) {
                            self.delivery.postalCode = data.zonecode;
                            self.delivery.addressDefault = data.roadAddress || data.jibunAddress;
                        }
                    }).open();
                } else {
                    this.delivery.postalCode = "21394";
                    this.delivery.addressDefault = "인천 부평구 경원대로 1366";
                    alert("우편번호 API를 불러올 수 없어 기본 테스트 주소가 입력되었습니다.");
                }
            },
            fnSubmitOrder() {
                if (!this.delivery.recipientName.trim()) { alert("수령인 이름을 입력해주세요."); return; }
                if (!this.delivery.recipientPhone.trim()) { alert("수령인 연락처를 입력해주세요."); return; }
                if (!this.delivery.postalCode || !this.delivery.addressDefault) { alert("배송지 주소를 입력해주세요."); return; }
                
                if (!confirm("총 " + this.finalAmount.toLocaleString() + "원을 결제하시겠습니까?")) return;
                
                const cartItemIds = this.cartItemIdsStr.split(",").map(id => Number(id.trim())).filter(Boolean);
                const payload = {
                    cartItemIds: cartItemIds,
                    recipientName: this.delivery.recipientName.trim(),
                    recipientPhone: this.delivery.recipientPhone.trim(),
                    postalCode: this.delivery.postalCode,
                    addressDefault: this.delivery.addressDefault,
                    addressDetail: this.delivery.addressDetail.trim(),
                    extraValues: this.extraValues
                };
                
                $.ajax({
                    url: "/order/create.dox",
                    type: "POST",
                    contentType: "application/json",
                    data: JSON.stringify(payload),
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            alert(data.message + "\n주문번호: " + data.orderNumber);
                            location.href = "/order/list.do";
                        } else {
                            alert(data.message || "주문 처리에 실패했습니다.");
                        }
                    }
                });
            }
        },
        mounted() {
            this.fnLoadCheckout();
        }
    });
    
    app.mount('#app');
</script>
