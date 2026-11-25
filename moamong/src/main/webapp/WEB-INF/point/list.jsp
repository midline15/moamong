
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>모아몽 - 포인트 내역</title>

    <!-- jQuery를 사용하기 위한 라이브러리입니다. -->
    <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4="
        crossorigin="anonymous"></script>

    <!-- Vue 3를 사용하기 위한 라이브러리입니다. -->
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

    <!-- 프로젝트에서 사용하는 공통 JS 파일입니다. -->
    <script src="/js/page-change.js"></script>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypage.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypageSub.css">
</head>
<body>
    <%@ include file="/WEB-INF/common/header.jsp"%>

    <div id="app" class="mp-wrap">
        <%@ include file="/WEB-INF/common/mypageSidebar.jsp"%>

        <main class="mp-main">
            <div class="mp-sub-top">
                <h2>포인트 내역</h2>
                <span class="mp-breadcrumb">마이페이지 &gt; 포인트 내역</span>
            </div>

            <!-- 현재 보유 포인트 요약 배너 -->
            <div class="pt-summary-box">
                <div>
                    <div style="font-size:13px; color:#5c5346; margin-bottom:4px;">현재 사용 가능 포인트</div>
                    <div style="font-size:12px; color:#85817b;">총 {{ list.length }}건의 적립·사용 내역</div>
                </div>
                <div style="font-size:26px; font-weight:800; color:#765a36;">
                    {{ currentBalance.toLocaleString() }} P
                </div>
            </div>

            <!-- 포인트 내역 테이블 -->
            <div class="pt-table-wrap">
                <table class="pt-table">
                    <thead>
                        <tr>
                            <th style="width:56px;">번호</th>
                            <th style="width:150px;">발생 일시</th>
                            <th style="width:90px;">유형</th>
                            <th>상세 내용</th>
                            <th style="width:110px;">주문 번호</th>
                            <th style="width:110px;">변동 포인트</th>
                            <th style="width:110px;">변동 후 잔액</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="(item, index) in pagedList" :key="item.pointHistoryId">
                            <td>{{ (page - 1) * pageSize + index + 1 }}</td>
                            <td style="font-size:12px; color:#5c5346;">{{ (item.createdAt || '').replace('T', ' ') }}</td>
                            <td>
                                <span class="pt-type-badge" :class="(item.historyType || '').toLowerCase()">
                                    {{ fnTypeName(item.historyType) }}
                                </span>
                            </td>
                            <td style="text-align:left; padding-left:14px;">{{ item.description || '-' }}</td>
                            <td style="font-size:12px; color:#85817b;">{{ item.orderId || '-' }}</td>
                            <td :class="item.historyType === 'USE' || item.historyType === 'EXPIRE' ? 'pt-amount-minus' : 'pt-amount-plus'">
                                {{ (item.historyType === 'USE' || item.historyType === 'EXPIRE' ? '-' : '+') }}{{ Math.abs(Number(item.pointAmount)).toLocaleString() }} P
                            </td>
                            <td style="font-weight:700;">{{ Number(item.balanceAfter).toLocaleString() }} P</td>
                        </tr>
                        <tr v-if="list.length === 0">
                            <td colspan="7" style="padding:60px 20px; color:#85817b;">포인트 내역이 없습니다.</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div v-if="totalPages > 1" class="mp-paging">
                <button class="mp-page-btn" :disabled="page === 1" @click="page = 1">&laquo;</button>
                <button class="mp-page-btn" :disabled="page === 1" @click="page--">&lsaquo;</button>
                <button v-for="p in totalPages" :key="p" class="mp-page-btn" :class="{ active: p === page }" @click="page = p">{{ p }}</button>
                <button class="mp-page-btn" :disabled="page === totalPages" @click="page++">&rsaquo;</button>
                <button class="mp-page-btn" :disabled="page === totalPages" @click="page = totalPages">&raquo;</button>
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
                list: [],
                page: 1,
                pageSize: 10,
                memberId: "${memberId}"
            };
        },
        computed: {
            currentBalance() {
                if (!this.list || this.list.length === 0) return 0;
                return Number(this.list[0].balanceAfter || 0);
            },
            totalPages() {
                return Math.max(1, Math.ceil(this.list.length / this.pageSize));
            },
            pagedList() {
                return this.list.slice((this.page - 1) * this.pageSize, this.page * this.pageSize);
            }
        },
        methods: {
            fnTypeName: function (type) {
                if (type == "EARN") return "적립";
                if (type == "USE") return "사용";
                if (type == "CANCEL") return "취소";
                if (type == "EXPIRE") return "만료";
                if (type == "ADJUST") return "관리자 조정";
                return type;
            },
            fnList: function () {
                let self = this;
                $.ajax({
                    url: "/point/history.dox",
                    dataType: "json",
                    type: "POST",
                    data: { memberId: self.memberId },
                    success: function (data) {
                        if (data.result == "success") {
                            self.list = data.list || [];
                        } else {
                            alert(data.message || "포인트 내역 조회에 실패했습니다.");
                        }
                    },
                    error: function (xhr, status, error) {
                        alert("서버와 통신하는 중 오류가 발생했습니다.");
                        console.log(error);
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
