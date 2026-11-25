<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 장바구니</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <!-- 공통 레이아웃 & 장바구니 & 찜목록 & 주문서 전용 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/order/shop.css">
    </head>
    <body>
    <%@ include file="/WEB-INF/common/header.jsp"%>

    <main id="app" class="shop-wrap">
        <div class="shop-head">
            <h2>장바구니</h2>
            <div class="shop-steps"><strong>01 장바구니</strong> &gt; 02 주문/결제 &gt; 03 주문완료</div>
        </div>

        <div class="shop-grid">
            <!-- 좌측 영역: 선택 바 + 장바구니 카드 + 배송 유의사항 -->
            <div>
                <div class="shop-toolbar">
                    <label style="cursor:pointer; display:flex; align-items:center; gap:8px; font-weight:600;">
                        <input type="checkbox" v-model="isAllChecked" @change="fnToggleAll">
                        전체 선택 ({{ selectedIds.length }} / {{ availableCount }})
                    </label>
                    <div style="display:flex; gap:6px;">
                        <button class="shop-btn" @click="fnRemoveSelected">선택 삭제</button>
                        <button class="shop-btn shop-btn-danger" @click="fnDeleteAll">전체 비우기</button>
                    </div>
                </div>

                <div v-if="cartList.length === 0" class="shop-card" style="text-align:center; padding:60px 0; color:#85817b;">
                    장바구니에 담긴 상품이 없습니다.
                </div>

                <div v-for="item in cartList" :key="item.cartItemId" class="shop-card" :class="{ soldout: !item.available }">
                    <div style="display:flex; align-items:flex-start; gap:14px;">
                        <input type="checkbox" :value="item.cartItemId" v-model="selectedIds" :disabled="!item.available" style="margin-top:4px;">
                        <img class="shop-thumb" :src="(item.thumbnailUrl && item.thumbnailUrl.trim()) ? item.thumbnailUrl : defaultThumb" @error="fnImgError">

                        <div style="flex:1; min-width:0;">
                            <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:8px;">
                                <div>
                                    <span class="shop-badge">{{ item.itemType === 'PRODUCT' ? '단품' : ('패키지' + (item.packageGrade ? ' · ' + item.packageGrade : '')) }}</span>
                                    <span v-if="!item.available" class="shop-badge soldout">품절/구매불가</span>
                                    <div style="font-size:15px; font-weight:700; margin-top:5px;">{{ item.productName || '판매 종료된 상품입니다' }}</div>
                                </div>
                                <button type="button" style="color:#9a8f80; font-size:15px;" @click="fnRemove(item.cartItemId)" title="삭제">✕</button>
                            </div>

                            <div v-if="!item.available && item.unavailableReason" style="color:#b84a4a; font-size:12px; margin-top:4px;">
                                {{ item.unavailableReason }}
                            </div>

                            <!-- 패키지 상세 구성품 및 추가 옵션 -->
                            <div v-if="item.itemType === 'PACKAGE'" class="shop-option-box">
                                <div>기본가: {{ Number(item.price).toLocaleString() }}원</div>
                                <div v-for="pi in item.packageItems" :key="pi.cartPackageItemId">
                                    • [{{ pi.itemRole }}] {{ pi.selectedProductName }} (x{{ pi.itemQuantity }})
                                    <span v-if="pi.additionalPrice > 0">(+{{ Number(pi.additionalPrice).toLocaleString() }}원)</span>
                                </div>
                                <div v-for="pe in item.packageExtras" :key="pe.cartPackageExtraId">
                                    • [추가옵션] {{ pe.extraName }}: {{ pe.optionName }}
                                    <span v-if="pe.additionalPrice > 0">(+{{ Number(pe.additionalPrice).toLocaleString() }}원)</span>
                                </div>
                            </div>

                            <!-- 하단 수량 조절 & 합계 금액 -->
                            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:14px; padding-top:12px; border-top:1px solid #efe7da;">
                                <div class="qty-control">
                                    <button type="button" :disabled="!item.available || item.quantity <= 1"
                                            @click="fnUpdate(item.cartItemId, item.quantity - 1)">−</button>
                                    <span>{{ item.quantity }}</span>
                                    <button type="button" :disabled="!item.available"
                                            @click="fnUpdate(item.cartItemId, item.quantity + 1)">+</button>
                                </div>
                                <strong style="font-size:16px; color:#29251f;">{{ Number(item.lineTotalPrice).toLocaleString() }}원</strong>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 배송 유의사항 (피그마 시안 반영) -->
                <div class="notice-box">
                    <strong style="display:block; color:#5c5346; margin-bottom:4px;">배송 유의사항</strong>
                    • 가격, 옵션 등 정보가 변경된 경우 주문이 불가할 수 있습니다.<br>
                    • 30,000원 이상 주문 시 기본 배송비(3,000원)가 무료로 적용됩니다.<br>
                    • 커스텀 패키지의 경우 구성품 및 메시지 카드 옵션에 따라 출고 일정이 상이할 수 있습니다.
                </div>
            </div>

            <!-- 우측 영역: 결제 예정 금액 패널 -->
            <aside class="summary-panel">
                <h3>결제 예정 금액</h3>
                <div class="summary-row">
                    <span>선택 상품 수</span>
                    <span>{{ selectedIds.length }}건</span>
                </div>
                <div class="summary-row">
                    <span>총 상품금액</span>
                    <span>{{ selectedTotal.toLocaleString() }}원</span>
                </div>
                <div class="summary-row">
                    <span>총 배송비 (3만원 이상 무료)</span>
                    <span>{{ selectedTotal === 0 ? '0원' : (selectedTotal >= 30000 ? '0원 (무료)' : '+ 3,000원') }}</span>
                </div>
                <div class="summary-total">
                    <span>총 결제 예정 금액</span>
                    <span class="amount">{{ (selectedTotal === 0 ? 0 : (selectedTotal >= 30000 ? selectedTotal : selectedTotal + 3000)).toLocaleString() }}원</span>
                </div>
                <button class="shop-btn shop-btn-gold" style="width:100%; padding:14px; font-size:15px; margin-top:18px;"
                        @click="fnOrderSelected">
                    총 {{ selectedIds.length }}건 주문하기
                </button>
            </aside>
        </div>
    </main>

    <%@ include file="/WEB-INF/common/footer.jsp"%>
    </body>
</html>
<script>
        const app = Vue.createApp({
            data() {
                return {
                    cartList: [],
                    selectedIds: [],
                    defaultThumb: "data:image/svg+xml;utf8,<svg xmlns='http://w3.org' width='100' height='100'><rect width='100' height='100' fill='%23f1f3f5'/></svg>"
                };
            },
            computed: {
                availableCount() {
                    return this.cartList.filter(item => item.available).length;
                },
                isAllChecked: {
                    get() {
                        return this.availableCount > 0 && this.selectedIds.length === this.availableCount;
                    },
                    set(val) {}
                },
                selectedTotal() {
                    let sum = 0;
                    for (let item of this.cartList) {
                        if (this.selectedIds.includes(item.cartItemId) && item.available) {
                            sum += Number(item.lineTotalPrice);
                        }
                    }
                    return sum;
                }
            },
            methods: {
                fnGoMypage() {
                    location.href = "/member/mypage.do";
                },
                fnGoMain() {
                    location.href = "/";
                },
                fnImgError(e) {
                    e.target.onerror = null;
                    e.target.src = this.defaultThumb;
                },
                fnList() {
                    let self = this;
                    $.ajax({
                        url: "/cart/list.dox",
                        dataType: "json",
                        type: "POST",
                        success: function (data) {
                            if (data.result === "success") {
                                self.cartList = data.list;
                                self.selectedIds = self.cartList
                                .filter(item => item.available)
                                .map(item => item.cartItemId);
                            } else {
                                alert(data.message || "장바구니 조회에 실패했습니다.");
                            }
                        }
                    });
                },
                fnToggleAll(e) {
                    if (e.target.checked) {
                        this.selectedIds = this.cartList
                        .filter(item => item.available)
                        .map(item => item.cartItemId);
                    } else {
                        this.selectedIds = [];
                    }
                },
                fnUpdate(cartItemId, quantity) {
                    let self = this;
                    if (!quantity || quantity < 1) {
                        alert("수량은 1개 이상이어야 합니다.");
                        self.fnList();
                        return;
                    }
                    $.ajax({
                        url: "/cart/update.dox",
                        dataType: "json",
                        type: "POST",
                        data: { cartItemId: cartItemId, quantity: quantity },
                        success: function (data) {
                            if (data.result === "success") {
                                self.fnList();
                            } else {
                                alert(data.message || "수량 변경에 실패했습니다.");
                                self.fnList();
                            }
                        }
                    });
                },
                fnRemove(cartItemId) {
                    let self = this;
                    if (!confirm("선택한 항목을 장바구니에서 삭제하시겠습니까?")) return;
                    $.ajax({
                        url: "/cart/remove.dox",
                        dataType: "json",
                        type: "POST",
                        data: { cartItemId: cartItemId },
                        success: function (data) {
                            if (data.result === "success") {
                                self.fnList();
                            } else {
                                alert("삭제에 실패했습니다.");
                            }
                        }
                    });
                },
                fnRemoveSelected() {
                    let self = this;
                    if (this.selectedIds.length === 0) {
                        alert("삭제할 상품을 선택해주세요.");
                        return;
                    }
                    if (!confirm("선택한 " + this.selectedIds.length + "개 항목을 삭제하시겠습니까?")) return;
                    $.ajax({
                        url: "/cart/removeSelected.dox",
                        dataType: "json",
                        type: "POST",
                        data: { cartItemIds: this.selectedIds.join(",") },
                        success: function (data) {
                            if (data.result === "success") {
                                self.fnList();
                            } else {
                                alert("선택 삭제에 실패했습니다.");
                            }
                        }
                    });
                },
                fnDeleteAll() {
                    let self = this;
                    if (!confirm("장바구니를 모두 비우시겠습니까?")) return;
                    $.ajax({
                        url: "/cart/deleteAll.dox",
                        dataType: "json",
                        type: "POST",
                        success: function (data) {
                            if (data.result === "success") {
                                self.fnList();
                            } else {
                                alert("장바구니 비우기에 실패했습니다.");
                            }
                        }
                    });
                },
                fnOrderSelected() {
                    if (this.selectedIds.length === 0) {
                        alert("주문할 상품을 1개 이상 선택해주세요.");
                        return;
                    }
                    location.href = "/order/checkout.do?cartItemIds=" + this.selectedIds.join(",");
                },
                fnTestAddProduct(productId) {
                    let self = this;
                    $.ajax({
                        url: "/cart/add.dox",
                        dataType: "json",
                        type: "POST",
                        data: { productId: productId, quantity: 1 },
                        success: function (data) {
                            if (data.result === "success") {
                                self.fnList();
                            } else {
                                alert(data.message || "담기 실패");
                            }
                        }
                    });
                }
            },
            mounted() {
                this.fnList();
            }
        });
        
        app.mount('#app');
</script>