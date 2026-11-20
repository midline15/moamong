<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <style>
            body {
                font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;
                background-color: #f8f9fa;
                margin: 0;
                padding: 30px 16px;
                color: #222;
            }
            .cart-container {
                max-width: 960px;
                margin: 0 auto;
                background: #fff;
                border-radius: 12px;
                padding: 28px;
                box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            }
            h2 { margin: 0 0 20px 0; font-size: 24px; }
            .toolbar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 12px 0;
                border-bottom: 2px solid #222;
                margin-bottom: 12px;
            }
            table { width: 100%; border-collapse: collapse; }
            th, td {
                padding: 14px 10px;
                border-bottom: 1px solid #eee;
                text-align: center;
                vertical-align: middle;
            }
            th { background-color: #fafafa; font-weight: 600; font-size: 14px; color: #555; }
            .item-info {
                display: flex;
                align-items: center;
                justify-content: flex-start;
                gap: 14px;
                text-align: left;
                min-width: 240px;
                word-break: keep-all;
            }
            .thumb {
                width: 68px; height: 68px; border-radius: 8px;
                object-fit: cover; background: #f1f3f5; border: 1px solid #e9ecef; flex-shrink: 0;
            }
            .badge {
                display: inline-block; font-size: 11px; font-weight: 700;
                padding: 2px 7px; border-radius: 4px; margin-bottom: 4px;
            }
            .badge-product { background: #e7f5ff; color: #1971c2; }
            .badge-package { background: #fff3bf; color: #e67700; }
            .badge-soldout { background: #ffe3e3; color: #c92a2a; margin-left: 4px; }
            .option-list {
                margin-top: 6px; padding-left: 10px; border-left: 2px solid #dee2e6;
                font-size: 12px; color: #666; line-height: 1.5;
            }
            .qty-box { display: inline-flex; align-items: center; gap: 4px; }
            .qty-box input { width: 52px; padding: 5px; text-align: center; border: 1px solid #ccc; border-radius: 4px; }
            .btn {
                padding: 6px 12px; border: 1px solid #ccc; background: #fff;
                border-radius: 6px; cursor: pointer; font-size: 13px;
            }
            .btn:hover { background: #f1f3f5; }
            .btn-danger { border-color: #ffa8a8; color: #c92a2a; }
            .btn-primary {
                background: #222; color: #fff; border-color: #222;
                font-size: 16px; font-weight: 600; padding: 14px 32px;
            }
            .btn-primary:hover { background: #444; }
            .summary-box {
                margin-top: 24px; padding: 20px 24px; background: #f8f9fa;
                border-radius: 10px; display: flex; justify-content: space-between; align-items: center;
            }
            .total-price { font-size: 24px; font-weight: 700; color: #d9480f; }
            .empty-box { text-align: center; padding: 60px 0; color: #888; }
            .soldout-row { opacity: 0.6; background-color: #fafafa; }
            .test-bar {
                margin-top: 30px; padding: 14px; background: #fff9db;
                border: 1px dashed #fcc419; border-radius: 8px; font-size: 13px;
            }
        </style>
    </head>
    <body>
        <div id="app" class="cart-container">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
                <h2 style="margin:0;">🛒 장바구니</h2>
                <div style="display:flex; gap:8px;">
                    <button class="btn" @click="fnGoMypage">마이페이지</button>
                    <button class="btn" @click="fnGoMain">메인으로</button>
                </div>
            </div>

            <!-- 상단 선택 컨트롤 바 -->
            <div class="toolbar">
                <label style="cursor:pointer;">
                    <input type="checkbox" v-model="isAllChecked" @change="fnToggleAll">
                    전체 선택 ({{ selectedIds.length }} / {{ availableCount }})
                </label>
                <div style="display:flex; gap:8px;">
                    <button class="btn" @click="fnRemoveSelected">선택 삭제</button>
                    <button class="btn btn-danger" @click="fnDeleteAll">전체 비우기</button>
                </div>
            </div>

            <!-- 장바구니 목록 -->
            <div v-if="cartList.length === 0" class="empty-box">
                장바구니에 담긴 상품이 없습니다.
            </div>

            <table v-else>
                <thead>
                    <tr>
                        <th style="width:40px;">선택</th>
                        <th>상품 / 패키지 정보</th>
                        <th style="width:120px;">개당 단가</th>
                        <th style="width:150px;">수량</th>
                        <th style="width:130px;">합계 금액</th>
                        <th style="width:80px;">삭제</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="item in cartList" :key="item.cartItemId" :class="{ 'soldout-row': !item.available }">
                        <td>
                            <input type="checkbox"
                            :value="item.cartItemId"
                            v-model="selectedIds"
                            :disabled="!item.available">
                        </td>
                        <td>
                            <img class="thumb"
                            :src="item.thumbnailUrl || defaultThumb"
                            @error="fnImgError"
                            alt="상품 이미지">
                            <div>
                                <div>
                                    <span v-if="item.itemType === 'PRODUCT'" class="badge badge-product">단품</span>
                                    <span v-else class="badge badge-package">
                                        패키지{{ item.packageGrade ? ' (' + item.packageGrade + ')' : '' }}
                                    </span>
                                    <span v-if="!item.available" class="badge badge-soldout">품절/구매불가</span>
                                </div>
                                <strong style="font-size:15px;">{{ item.productName || '판매 종료된 상품입니다' }}</strong>
                                <div v-if="!item.available && item.unavailableReason" style="color:#c92a2a; font-size:12px; margin-top:2px;">
                                    {{ item.unavailableReason }}
                                </div>

                                <!-- 패키지 상세 구성품 및 추가 옵션 표시 -->
                                <div v-if="item.itemType === 'PACKAGE'" class="option-list">
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
                            </div>
                        </div>
                    </td>
                    <td>{{ Number(item.unitTotalPrice).toLocaleString() }}원</td>
                    <td>
                        <div class="qty-box">
                            <input type="number" v-model.number="item.quantity" min="1" :disabled="!item.available">
                            <button class="btn" @click="fnUpdate(item.cartItemId, item.quantity)" :disabled="!item.available">변경</button>
                        </div>
                    </td>
                    <td><strong>{{ Number(item.lineTotalPrice).toLocaleString() }}원</strong></td>
                    <td>
                        <button class="btn btn-danger" @click="fnRemove(item.cartItemId)">삭제</button>
                    </td>
                </tr>
            </tbody>
        </table>

        <!-- 하단 결제 예정 금액 및 주문 버튼 -->
        <div class="summary-box" v-if="cartList.length > 0">
            <div>
                <div style="font-size:14px; color:#666;">선택 상품 총 {{ selectedIds.length }}건</div>
                <div class="total-price">총 결제 예정 금액: {{ selectedTotal.toLocaleString() }}원</div>
            </div>
            <button class="btn btn-primary" @click="fnOrderSelected">선택 상품 주문하기</button>
        </div>

        <!-- 단독 테스트용 임시 담기 패널 -->
        <div class="test-bar">
            <strong>🔧 개발 테스트용 빠른 담기 (DB PRODUCT 1~3번):</strong>
            <button class="btn" style="margin-left:8px;" @click="fnTestAddProduct(1)">+ 여리여리 스카프(1번)</button>
            <button class="btn" style="margin-left:4px;" @click="fnTestAddProduct(2)">+ 실크 터치 스카프(2번)</button>
            <button class="btn" style="margin-left:4px;" @click="fnTestAddProduct(3)">+ 감성 패턴 양말(3번)</button>
        </div>
    </div>
    <script>
        const app = Vue.createApp({
            data() {
                return {
                    cartList: [],
                    selectedIds: [],
                    defaultThumb: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIj48cmVjdCB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iI2YxZjNmNSIvPjx0ZXh0IHg9IjUwJSIgeT0iNTQlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjODY4ZTk2IiBmb250LWZhbWlseT0ic2Fucy1zZXJpZiIgZm9udC1zaXplPSIxMiI+TU9BTU9ORzwvdGV4dD48L3N2Zz4="
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
                fnImgError(e) {
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
            fnGoMypage() {
                location.href = "/member/mypage.do";
            },
            fnGoMain() {
                location.href = "/";
            },
            mounted() {
                this.fnList();
            }
        });
        
        app.mount('#app');
    </script>