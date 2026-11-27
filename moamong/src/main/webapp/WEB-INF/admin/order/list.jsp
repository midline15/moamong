```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>주문 관리</title>

        <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>

        <link rel="stylesheet" href="/css/admin/default.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/order/list.css">
    </head>

    <body>

        <header class="header">
            <div class="logo">Logo</div>
        </header>

        <div id="app">

            <div class="admin-container">

                <!-- 사이드바 -->
                <%@ include file="/WEB-INF/admin/sidebar.jsp" %>

                    <!-- 메인 콘텐츠 -->
                    <main class="main-content">

                        <div class="page-title">
                            <h3>주문 관리</h3>
                        </div>

                        <div class="breadcrumb">
                            주문 관리 / 주문 목록
                        </div>

                        <div class="content-area">

                            <!-- 주문 통계 -->
                            <div class="order-stats">

                                <div class="stats-card">
                                    <div class="stats-title">전체 주문</div>
                                    <div class="stats-value">
                                        {{ orderStats.totalCount }}건
                                    </div>
                                </div>

                                <div class="stats-card">
                                    <div class="stats-title">결제 완료</div>
                                    <div class="stats-value">
                                        {{ orderStats.paidCount }}건
                                    </div>
                                </div>

                                <div class="stats-card">
                                    <div class="stats-title">배송 준비</div>
                                    <div class="stats-value">
                                        {{ orderStats.readyCount }}건
                                    </div>
                                </div>

                                <div class="stats-card">
                                    <div class="stats-title">배송 중</div>
                                    <div class="stats-value">
                                        {{ orderStats.shippingCount }}건
                                    </div>
                                </div>

                            </div>

                            <!-- 주문 검색 -->
                            <div class="order-search">

                                <h3>주문 검색</h3>

                                <div class="search-row">

                                    <div class="search-item">
                                        <label>검색어</label>
                                        <input type="text" v-model="keyword" placeholder="주문번호 또는 수령인"
                                            @keyup.enter="fnSearch">
                                    </div>

                                    <div class="search-item">
                                        <label>주문 상태</label>

                                        <select v-model="searchStatus">
                                            <option value="">전체 상태</option>
                                            <option value="PAID">결제 완료</option>
                                            <option value="PREPARING">상품 준비 중</option>
                                            <option value="SHIPPING">배송 중</option>
                                            <option value="DELIVERED">배송 완료</option>
                                            <option value="CANCELLED">취소</option>
                                        </select>
                                    </div>

                                </div>

                                <div class="search-buttons">

                                    <button class="btn-reset" @click="fnReset">
                                        초기화
                                    </button>

                                    <button class="btn-search" @click="fnSearch">
                                        검색
                                    </button>

                                </div>

                            </div>

                            <!-- 주문 목록 -->
                            <div class="order-list">

                                <div class="list-header">
                                    <h3>주문 목록</h3>
                                    <span>총 {{ totalCount }}건</span>
                                </div>

                                <table class="order-table">

                                    <thead>
                                        <tr>
                                            <th>주문번호</th>
                                            <th>수령인</th>
                                            <th>연락처</th>
                                            <th>배송지</th>
                                            <th>결제금액</th>
                                            <th>주문상태</th>
                                            <th>배송 관리</th>
                                        </tr>
                                    </thead>

                                    <tbody>

                                        <tr v-for="order in orderList" :key="order.orderId">

                                            <td>{{ order.orderNumber }}</td>

                                            <td>{{ order.recipientName }}</td>

                                            <td>{{ order.recipientPhone }}</td>

                                            <td>
                                                {{ order.addressDefault }}
                                                {{ order.addressDetail }}
                                            </td>

                                            <td>
                                                {{ fnFormatNumber(order.finalAmount) }}원
                                            </td>

                                            <td>
                                                <span class="status-badge" :class="fnStatusClass(order.orderStatus)">
                                                    {{ fnStatusName(order.orderStatus) }}
                                                </span>
                                            </td>

                                            <td>

                                                <button
                                                    v-if="order.orderStatus === 'PAID' || order.orderStatus === 'PREPARING'"
                                                    class="btn-shipment" @click="fnCreateShipment(order)">
                                                    송장 등록
                                                </button>

                                                <button v-if="order.orderStatus === 'SHIPPING'" class="btn-shipping"
                                                    @click="fnShippingStart(order)">
                                                    배송 시작
                                                </button>

                                            </td>

                                        </tr>

                                        <tr v-if="orderList.length === 0">
                                            <td colspan="7">
                                                조회된 주문이 없습니다.
                                            </td>
                                        </tr>

                                    </tbody>

                                </table>

                                <!-- 배송 정보 확인창 -->
                                <div class="shipment-modal" v-if="showShipmentModal">

                                    <div class="shipment-modal-content">

                                        <h3>배송 정보 확인</h3>

                                        <div v-if="selectedOrder">

                                            <div>
                                                <label>주문번호</label>
                                                <p>{{ selectedOrder.orderNumber }}</p>
                                            </div>

                                            <div>
                                                <label>수령인</label>
                                                <p>{{ selectedOrder.recipientName }}</p>
                                            </div>

                                            <div>
                                                <label>연락처</label>
                                                <p>{{ selectedOrder.recipientPhone }}</p>
                                            </div>

                                            <div>
                                                <label>우편번호</label>
                                                <p>{{ selectedOrder.postalCode }}</p>
                                            </div>

                                            <div>
                                                <label>배송 주소</label>
                                                <p>
                                                    {{ selectedOrder.addressDefault }}
                                                    {{ selectedOrder.addressDetail }}
                                                </p>
                                            </div>

                                        </div>

                                        <div class="shipment-modal-buttons">

                                            <button @click="fnConfirmShipment">
                                                배송 생성
                                            </button>

                                            <button @click="showShipmentModal = false">
                                                취소
                                            </button>

                                        </div>

                                    </div>

                                </div>

                                <!-- 페이지 이동 -->
                                <div class="pagination">

                                    <button @click="fnPage(1)" :disabled="currentPage == 1">
                                        처음
                                    </button>

                                    <button @click="fnPage(currentPage - 1)" :disabled="currentPage == 1">
                                        이전
                                    </button>

                                    <button v-for="page in visiblePages" :key="page" @click="fnPage(page)"
                                        :class="{ active: currentPage == page }">
                                        {{ page }}
                                    </button>

                                    <button @click="fnPage(currentPage + 1)" :disabled="currentPage >= totalPages">
                                        다음
                                    </button>

                                    <button @click="fnPage(totalPages)" :disabled="currentPage >= totalPages">
                                        마지막
                                    </button>

                                </div>

                            </div>

                        </div>

                    </main>

            </div>

            <footer class="footer">

                <div>
                    <div class="footer-logo">Logo</div>
                </div>

                <div>
                    <h4>회사 정보</h4>
                    <p>
                        회사소개<br>
                        이용약관<br>
                        개인정보처리방침
                    </p>
                </div>

                <div>
                    <h4>고객센터</h4>
                    <p>
                        공지사항<br>
                        자주 묻는 질문<br>
                        1:1 문의
                    </p>
                </div>

                <div>
                    <p>
                        상호명 : 모아몽<br>
                        Copyright © Moamong. All rights reserved.
                    </p>
                </div>

            </footer>

        </div>

        <script>

            const app = Vue.createApp({

                data() {

                    return {

                        keyword: "",
                        searchStatus: "",

                        currentPage: 1,
                        pageSize: 10,

                        orderList: [],
                        totalCount: 0,

                        orderStats: {
                            totalCount: 0,
                            paidCount: 0,
                            readyCount: 0,
                            shippingCount: 0
                        },

                        // 배송 생성 대상 주문
                        selectedOrder: null,

                        // 배송 정보 확인창
                        showShipmentModal: false

                    };

                },

                computed: {

                    // 전체 페이지 수
                    totalPages() {

                        return Math.max(
                            1,
                            Math.ceil(this.totalCount / this.pageSize)
                        );

                    },

                    // 페이지 번호 5개씩 표시
                    visiblePages() {

                        let pageGroupSize = 5;

                        let startPage =
                            Math.floor((this.currentPage - 1) / pageGroupSize)
                            * pageGroupSize + 1;

                        let endPage = Math.min(
                            startPage + pageGroupSize - 1,
                            this.totalPages
                        );

                        let pages = [];

                        for (let i = startPage; i <= endPage; i++) {
                            pages.push(i);
                        }

                        return pages;

                    }

                },

                methods: {

                    // 주문 목록 조회
                    fnList() {

                        let self = this;

                        let param = {

                            keyword: self.keyword,
                            searchStatus: self.searchStatus,

                            limit: self.pageSize,
                            offset: (self.currentPage - 1) * self.pageSize

                        };

                        $.ajax({

                            url: "/admin/order/list.dox",
                            type: "POST",
                            dataType: "json",
                            data: param,

                            success: function (data) {

                                if (data.result == "success") {

                                    self.orderList = data.list || [];
                                    self.totalCount = Number(data.totalCount) || 0;

                                    self.orderStats =
                                        data.stats || self.orderStats;

                                } else {

                                    alert(data.message || "주문 목록 조회에 실패했습니다.");

                                }

                            },

                            error: function () {

                                alert("서버 통신 오류");

                            }

                        });

                    },

                    // 검색
                    fnSearch() {

                        this.currentPage = 1;
                        this.fnList();

                    },

                    // 검색 초기화
                    fnReset() {

                        this.keyword = "";
                        this.searchStatus = "";
                        this.currentPage = 1;

                        this.fnList();

                    },

                    // 페이지 이동
                    fnPage(page) {

                        page = Number(page);

                        if (page < 1 || page > this.totalPages) {
                            return;
                        }

                        this.currentPage = page;
                        this.fnList();

                    },

                    // 주문 상태 한글 변환
                    fnStatusName(status) {

                        const statusMap = {

                            PAID: "결제 완료",
                            PREPARING: "상품 준비 중",
                            SHIPPING: "배송 중",
                            DELIVERED: "배송 완료",
                            CANCELLED: "취소"

                        };

                        return statusMap[status] || status || "-";

                    },

                    // 주문 상태 CSS
                    fnStatusClass(status) {

                        const statusMap = {

                            PAID: "paid",
                            PREPARING: "preparing",
                            SHIPPING: "shipping",
                            DELIVERED: "delivered",
                            CANCELLED: "cancelled"

                        };

                        return statusMap[status] || "";

                    },

                    // 금액 포맷
                    fnFormatNumber(value) {

                        return Number(value || 0).toLocaleString();

                    },


                    // 배송 정보 확인창 열기
                    fnCreateShipment(order) {

                        this.selectedOrder = order;
                        this.showShipmentModal = true;

                    },

                    // 배송 생성 요청
                    fnConfirmShipment() {

                        let self = this;

                        if (!self.selectedOrder) {
                            alert("배송할 주문을 선택해 주세요.");
                            return;
                        }

                        if (!confirm("선택한 주문의 배송을 등록하시겠습니까?")) {
                            return;
                        }

                        $.ajax({
                            url: "/shipment/create.dox",
                            type: "POST",
                            data: self.selectedOrder,
                            dataType: "json",
                            success: function (res) {

                                if (res.result === "success") {
                                    alert("배송 정보가 등록되었습니다.");

                                    console.log("운송장 번호:", res.trackingNumber);
                                    console.log("배송 조회 결과:", res.trackingInfo);

                                    self.selectedOrder = null;
                                    self.showShipmentModal = false;
                                    self.fnList();

                                } else {
                                    alert(res.message);
                                }
                            },
                            error: function (xhr, status, error) {
                                console.log(error);
                                alert("배송 등록 중 오류가 발생했습니다.");
                            }
                        });

                    },

                    // 배송 시작
                    fnShippingStart(order) {

                        if (!confirm("배송을 시작하시겠습니까?")) {
                            return;
                        }

                        alert("배송 시작 기능은 송장 등록 및 운송장 정보 저장을 연결한 다음 구현할게.");

                    }

                },

                mounted() {

                    this.fnList();

                }

            });

            app.mount("#app");

        </script>

    </body>

    </html>