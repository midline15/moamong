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
        <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
        <script src="https://cdn.iamport.kr/v1/iamport.js"></script>
        <!-- 공통 레이아웃 & 장바구니 & 찜목록 & 주문서 전용 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/order/shop.css">
    </head>

    <body>
        <%@ include file="/WEB-INF/common/header.jsp" %>

        <main id="app" class="shop-wrap">
            <div class="shop-head">
                <h2>주문 / 결제</h2>
                <div class="shop-steps">01 장바구니 &gt; <strong>02 주문/결제</strong> &gt; 03 주문완료</div>
            </div>

            <div class="shop-grid">
                <!-- 좌측: 배송지 정보 + 주문 상품 목록 -->
                <div>
                    <div class="shop-card">
                        <div
                        style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
                        <h3 style="font-size:16px; font-weight:700; color:#765a36;">1. 배송지 정보</h3>
                        <div style="display:flex; gap:6px;">
                            <button v-if="addressList.length > 0" type="button" class="shop-btn"
                                @click="showAddrModal = true">배송지 목록 선택</button>
                                <button type="button" class="shop-btn" @click="fnGoAddress">배송지 관리</button>
                            </div>
                        </div>

                        <div
                        style="display:grid; grid-template-columns:110px 1fr; gap:10px 12px; align-items:center; font-size:13px;">
                        <label style="font-weight:600; color:#5c5346;">수령인 이름 *</label>
                        <input type="text" class="shop-input" v-model="delivery.recipientName"
                        placeholder="수령인 이름">

                        <label style="font-weight:600; color:#5c5346;">연락처 *</label>
                        <input type="text" class="shop-input" v-model="delivery.recipientPhone"
                        placeholder="010-0000-0000">

                        <label style="font-weight:600; color:#5c5346;">우편번호 *</label>
                        <div style="display:flex; gap:8px;">
                            <input type="text" class="shop-input" v-model="delivery.postalCode"
                            style="max-width:140px; background:#f0e8da;" readonly>
                            <button type="button" class="shop-btn" @click="fnSearchPostcode">우편번호 검색</button>
                        </div>

                        <label style="font-weight:600; color:#5c5346;">기본 주소 *</label>
                        <input type="text" class="shop-input" v-model="delivery.addressDefault"
                        style="background:#f0e8da;" readonly>

                        <label style="font-weight:600; color:#5c5346;">상세 주소</label>
                        <input type="text" class="shop-input" v-model="delivery.addressDetail"
                        placeholder="동/호수 등 상세 주소">

                        <label style="font-weight:600; color:#5c5346;">배송 요청사항</label>
                        <div>
                            <select class="shop-input" v-model="memoPreset" @change="fnChangeMemoPreset">
                                <option value="">배송 시 요청사항을 선택해주세요 (선택)</option>
                                <option value="부재 시 문 앞에 놓아주세요.">부재 시 문 앞에 놓아주세요.</option>
                                <option value="배송 전 미리 연락 부탁드립니다.">배송 전 미리 연락 부탁드립니다.</option>
                                <option value="부재 시 경비실에 맡겨주세요.">부재 시 경비실에 맡겨주세요.</option>
                                <option value="파손에 주의해서 안전하게 배송해주세요.">파손에 주의해서 안전하게 배송해주세요.</option>
                                <option value="DIRECT">직접 입력</option>
                            </select>
                            <input v-if="memoPreset === 'DIRECT'" type="text" class="shop-input" style="margin-top:8px;"
                            v-model="delivery.deliveryMemo" maxlength="100" placeholder="배송 요청사항을 직접 입력해주세요 (최대 100자)">
                        </div>
                    </div>
                </div>
                <div class="shop-card">
                    <h3 style="font-size:16px; font-weight:700; color:#765a36; margin-bottom:14px;">2. 주문 상품 ({{
                        items.length }}건)</h3>
                        <div v-for="item in items" :key="item.cartItemId"
                        style="padding:12px 0; border-top:1px solid #e3d6c1;">
                        <div style="display:flex; align-items:center; gap:12px;">
                            <img class="shop-thumb" style="width:64px; height:64px;"
                            :src="(item.thumbnailUrl && item.thumbnailUrl.trim()) ? item.thumbnailUrl : defaultThumb"
                            @error="fnImgError">
                            <div style="flex:1;">
                                <span class="shop-badge">{{ item.itemType === 'PRODUCT' ? '단품' : '패키지' }}</span>
                                <strong style="font-size:14px;">{{ item.itemName }}</strong>
                                <div style="font-size:13px; color:#85817b; margin-top:3px;">{{
                                    Number(item.unitPrice).toLocaleString() }}원 × {{ item.quantity }}개</div>
                                </div>
                                <strong style="font-size:15px;">{{ Number(item.lineAmount).toLocaleString()
                                    }}원</strong>
                                    <button type="button" style="color:#9a8f80;"
                                    @click="fnRemoveCheckoutItem(item.cartItemId)" title="제외">✕</button>
                                </div>

                                <div v-if="item.itemType === 'PACKAGE'" class="shop-option-box">
                                    <div v-for="pi in item.packageItems" :key="pi.cartPackageItemId">
                                        • [{{ pi.itemRole }}] {{ pi.selectedProductName }} (x{{ pi.itemQuantity }})
                                        <span v-if="pi.additionalPrice > 0">(+{{
                                            Number(pi.additionalPrice).toLocaleString() }}원)</span>
                                        </div>
                                        <div v-for="pe in item.packageExtras" :key="pe.cartPackageExtraId">
                                            • [추가옵션] {{ pe.extraName }}: {{ pe.optionName }}
                                            <span v-if="pe.additionalPrice > 0">(+{{
                                                Number(pe.additionalPrice).toLocaleString() }}원)</span>
                                                <div v-if="pe.extraType === 'CARD'" style="margin-top:6px;">
                                                    <div style="font-weight:600; color:#765a36; margin-bottom:4px;">✉️ 카드 메시지 입력
                                                        (선택)</div>
                                                        <input type="text" class="shop-input"
                                                        v-model="extraValues[pe.cartPackageExtraId]" maxlength="500"
                                                        placeholder="동봉할 카드 문구를 입력해주세요">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- 우측: 최종 결제 금액 요약 & 결제 버튼 -->
                                <aside class="summary-panel">
                                    <h3>최종 결제 금액</h3>
                                    <div class="summary-row"><span>기본 상품 금액</span><span>{{ totalProductAmount.toLocaleString()
                                        }}원</span></div>
                                        <div class="summary-row"><span>옵션 추가 금액</span><span>+ {{ totalAdditionalAmount.toLocaleString()
                                            }}원</span></div>
                                            <div class="summary-row">
                                                <span>배송비 (3만원 이상 무료)</span>
                                                <span>{{ shippingFee === 0 ? '무료 (0원)' : ('+ ' + shippingFee.toLocaleString() + '원') }}</span>
                                            </div>
                                            <div class="summary-total">
                                                <span>최종 결제 금액</span>
                                                <span class="amount">{{ finalAmount.toLocaleString() }}원</span>
                                            </div>
                                            <label style="display:flex; align-items:flex-start; gap:8px; margin-top:16px; font-size:12px; color:#5c5346; cursor:pointer; line-height:1.5;">
                                                <input type="checkbox" v-model="agreeOrder" style="margin-top:3px;">
                                                <span>주문할 상품의 상품명, 가격, 배송정보를 확인하였으며 구매에 동의합니다. (필수)</span>
                                            </label>

                                            <button class="shop-btn shop-btn-gold" style="width:100%; padding:14px; font-size:15px; margin-top:14px;"
                                            :disabled="isPaying || !agreeOrder" @click="fnSubmitOrder">
                                            {{ isPaying ? '결제 처리 중...' : finalAmount.toLocaleString() + '원 결제하기' }}
                                            </button>
                                    <button class="shop-btn" style="width:100%; margin-top:8px;" @click="fnGoCart">장바구니로
                                        돌아가기</button>
                                    </aside>
                                </div>

                                <!-- 배송지 선택 모달 -->
                                <div v-if="showAddrModal" class="shop-modal-backdrop" @click.self="showAddrModal = false">
                                    <div class="shop-modal-box">
                                        <div
                                        style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px;">
                                        <strong style="font-size:16px; color:#765a36;">배송지 선택</strong>
                                        <button type="button" class="shop-btn" @click="showAddrModal = false">닫기</button>
                                    </div>
                                    <div v-for="addr in addressList" :key="addr.addressId" class="shop-card"
                                    style="cursor:pointer; padding:14px;" @click="fnSelectAddress(addr)">
                                    <div style="font-weight:700; margin-bottom:4px;">
                                        {{ addr.addressName || addr.recipientName }}
                                        <span v-if="addr.isDefault == 1" class="shop-badge">기본</span>
                                    </div>
                                    <div style="font-size:13px; color:#5c5346;">{{ addr.recipientName }} | {{
                                        addr.recipientPhone }}</div>
                                        <div style="font-size:13px; color:#5c5346;">({{ addr.postalCode }}) {{ addr.addressDefault
                                            }} {{ addr.addressDetail }}</div>
                                        </div>
                                    </div>
                                </div>
                            </main>

                            <%@ include file="/WEB-INF/common/footer.jsp" %>
                        </body>

                    </html>
                    <script>
                        const app = Vue.createApp({
                            data() {
                                return {
                                    purchaseType: "${purchaseType}",
                                    cartItemIdsStr: "${cartItemIds}",
                                    items: [],
                                    addressList: [],
                                    showAddrModal: false,
                                    delivery: {
                                        recipientName: "",
                                        recipientPhone: "",
                                        postalCode: "",
                                        addressDefault: "",
                                        addressDetail: "",
                                        deliveryMemo: ""
                                    },
                                    memoPreset: "",
                                    agreeOrder: false,
                                    isPaying: false,
                                    extraValues: {},
                                    totalProductAmount: 0,
                                    totalAdditionalAmount: 0,
                                    shippingFee: 0,
                                    finalAmount: 0,
                                    defaultThumb: "data:image/svg+xml;utf8,<svg xmlns='http://w3.org' width='100' height='100'><rect width='100' height='100' fill='%23f1f3f5'/></svg>"
                                };
                            },
                            methods: {
                                fnGoCart() {
                                    // 장바구니 구매라면 바로 장바구니로 이동
                                    if (this.purchaseType !== "DIRECT") {
                                        location.href = "/cart/list.do";
                                        return;
                                    }
                                    
                                    // 바로 구매라면 세션 정보 삭제 후 장바구니로 이동
                                    $.ajax({
                                        url: "/order/cancel-direct.dox",
                                        type: "POST",
                                        dataType: "json",
                                        success: function (data) {
                                            if (data.result === "success") {
                                                location.href = "/cart/list.do";
                                            } else {
                                                alert(data.message || "구매 취소에 실패했습니다.");
                                            }
                                        },
                                        error: function () {
                                            alert("구매 취소 중 오류가 발생했습니다.");
                                        }
                                    });
                                },
                                
                                fnChangeMemoPreset() {
                                    this.delivery.deliveryMemo = (this.memoPreset === "DIRECT") ? "" : this.memoPreset;
                                },
                                
                                fnGoAddress() { location.href = "/address/list.do"; },
                                fnImgError(e) { e.target.onerror = null; e.target.src = this.defaultThumb; },
                                
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
                                fnRemoveCheckoutItem(cartItemId) {
                                    if (this.items.length <= 1) {
                                        alert("최소 1개 이상의 주문 상품이 필요합니다.");
                                        return;
                                    }
                                    if (!confirm("이 상품을 이번 주문에서 제외하시겠습니까?")) return;
                                    this.items = this.items.filter(item => item.cartItemId !== cartItemId);
                                    delete this.extraValues[cartItemId];
                                    this.fnRecalcSummary();
                                },
                                fnRecalcSummary() {
                                    let prodSum = 0;
                                    let optSum = 0;
                                    for (let item of this.items) {
                                        let qty = Number(item.quantity);
                                        let base = Number(item.basePrice);
                                        let unit = Number(item.unitPrice);
                                        prodSum += base * qty;
                                        optSum += (unit - base) * qty;
                                    }
                                    let subTotal = prodSum + optSum;
                                    this.totalProductAmount = prodSum;
                                    this.totalAdditionalAmount = optSum;
                                    this.shippingFee = subTotal >= 30000 ? 0 : 3000;
                                    this.finalAmount = subTotal + this.shippingFee;
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
                                    if (this.isPaying) return;
                                    if (!this.delivery.recipientName.trim()) { alert("수령인 이름을 입력해주세요."); return; }
                                    if (!this.delivery.recipientPhone.trim()) { alert("수령인 연락처를 입력해주세요."); return; }
                                    
                                    const phoneRegex = /^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$/;
                                    if (!phoneRegex.test(this.delivery.recipientPhone.trim())) {
                                        alert("올바른 휴대폰 번호 형식(예: 010-1234-5678)을 입력해주세요.");
                                        return;
                                    }
                                    
                                    if (!this.delivery.postalCode || !this.delivery.addressDefault) { alert("배송지 주소를 입력해주세요."); return; }
                                    
                                    let self = this;
                                    const IMP = window.IMP;
                                    IMP.init("${impCode}");
                                    
                                    const merchantUid = "MOA_" + new Date().getTime();
                                    const orderName = this.items.length > 1
                                    ? this.items[0].itemName + " 외 " + (this.items.length - 1) + "건"
                                    : this.items[0].itemName;
                                    
                                    this.isPaying = true; // 포트원 호출 직전 중복 클릭 잠금
                                    
                                    IMP.request_pay({
                                        pg: "html5_inicis.INIpayTest",
                                        pay_method: "card",
                                        merchant_uid: merchantUid,
                                        name: orderName,
                                        // [테스트결제용] 무조건 1원 결제 (원복 시: amount: this.finalAmount,)
                                        amount: 1,
                                        buyer_name: this.delivery.recipientName.trim(),
                                        /*amount: this.finalAmount,*/
                                        buyer_name: this.delivery.recipientName.trim(),
                                        buyer_tel: this.delivery.recipientPhone.trim(),
                                        buyer_addr: this.delivery.addressDefault + " " + this.delivery.addressDetail.trim(),
                                        buyer_postcode: this.delivery.postalCode
                                    }, function (rsp) {
                                    if (!rsp.success) {
                                        self.isPaying = false; // 결제 취소/실패 시 잠금 해제
                                        alert("결제가 취소되었거나 실패했습니다.\n(" + (rsp.error_msg || "") + ")");
                                        return;
                                    }
                                    const payload = {
                                        cartItemIds: self.items.map(item => Number(item.cartItemId)),
                                        recipientName: self.delivery.recipientName.trim(),
                                        recipientPhone: self.delivery.recipientPhone.trim(),
                                        postalCode: self.delivery.postalCode,
                                        addressDefault: self.delivery.addressDefault,
                                        addressDetail: self.delivery.addressDetail.trim(),
                                        deliveryMemo: self.delivery.deliveryMemo.trim(),
                                        extraValues: self.extraValues,
                                        impUid: rsp.imp_uid,
                                        payMethod: rsp.pay_method || "KAKAOPAY"
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
                                                self.isPaying = false;
                                                alert(data.message || "주문 처리에 실패했습니다.");
                                            }
                                        },
                                        error: function () {
                                            self.isPaying = false;
                                            alert("주문 처리 중 오류가 발생했습니다.");
                                        }
                                    });
                                });
                            }
                            
                        },
                        mounted() {
                            this.fnLoadCheckout();
                        }
                    });
                    
                    app.mount('#app');
                </script>