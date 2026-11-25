<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

	<!DOCTYPE html>
	<html lang="ko">

	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">

		<title>모아몽 - 내 쿠폰함</title>

		<script src="https://code.jquery.com/jquery-3.7.1.js"></script>
		<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
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
                <h2>내 쿠폰</h2>
                <span class="mp-breadcrumb">마이페이지 &gt; 내 쿠폰</span>
            </div>

            <!-- 쿠폰 요약 4칸 -->
            <div class="cp-summary-grid">
                <div class="cp-summary-card">
                    <div class="cp-summary-num">{{ couponList.length }}</div>
                    <div class="cp-summary-label">전체 쿠폰</div>
                </div>
                <div class="cp-summary-card">
                    <div class="cp-summary-num">{{ availableCount }}</div>
                    <div class="cp-summary-label">보유 쿠폰</div>
                </div>
                <div class="cp-summary-card">
                    <div class="cp-summary-num">{{ usedCount }}</div>
                    <div class="cp-summary-label">사용 완료</div>
                </div>
                <div class="cp-summary-card">
                    <div class="cp-summary-num">{{ expiredCount }}</div>
                    <div class="cp-summary-label">만료 쿠폰</div>
                </div>
            </div>

            <!-- 쿠폰 상태 4탭 -->
            <div class="cp-tabs-4">
                <button v-for="tab in tabs" :key="tab.value" type="button"
                        class="mp-sub-tab" :class="{ active: currentTab === tab.value }"
                        @click="currentTab = tab.value">
                    {{ tab.name }}
                </button>
            </div>

            <!-- 쿠폰 목록 -->
            <div v-if="filteredCoupons.length === 0" class="mp-card" style="text-align:center; padding:60px 20px; color:#85817b;">
                해당 쿠폰 내역이 없습니다.
            </div>

            <div v-for="coupon in filteredCoupons" :key="coupon.memberCouponId"
                 class="cp-ticket" :class="{ used: coupon.displayStatus !== 'AVAILABLE' }"
                 style="flex-direction:row; align-items:center; margin-bottom:12px;">
                <div class="mp-item-body">
                    <span class="cp-status-tag" :class="coupon.displayStatus.toLowerCase()">
                        {{ fnStatusName(coupon.displayStatus) }}
                    </span>

                    <div class="cp-discount">
                        <span v-if="coupon.discountType === 'FIXED'">{{ Number(coupon.discountValue).toLocaleString() }}원</span>
                        <span v-else-if="coupon.discountType === 'RATE'">{{ coupon.discountValue }}%</span>
                    </div>

                    <div class="mp-item-title">{{ coupon.couponName }}</div>
                    <div class="mp-item-text">
                        {{ Number(coupon.minimumOrderAmount).toLocaleString() }}원 이상 구매 시 사용
                        <span v-if="coupon.maximumDiscountAmount"> (최대 {{ Number(coupon.maximumDiscountAmount).toLocaleString() }}원 할인)</span>
                    </div>
                    <div class="mp-item-meta">
    					발급일 : {{ (coupon.issuedAt || '').replace('T', ' ') }} · 유효기간 : {{ (coupon.validFrom || '').replace('T', ' ') }} ~ {{ (coupon.validUntil || '').replace('T', ' ') }}
					</div>
                </div>

                <div class="cp-extra-box">
                    <template v-if="coupon.displayStatus === 'USED'">
                        <div class="mp-item-meta" style="margin-top:0;">사용 주문번호</div>
                        <div style="font-size:13px; font-weight:700; color:#29251f; margin-bottom:6px;">{{ coupon.orderId || '-' }}</div>
                        <div class="mp-item-meta" style="margin-top:0;">실제 할인금액</div>
                        <div style="font-size:13px; font-weight:700; color:#765a36;">{{ Number(coupon.discountAmount || 0).toLocaleString() }}원</div>
                    </template>
                    <template v-else>
                        <span style="font-size:12px; font-weight:700; color:#94764b;">MOAMONG COUPON</span>
                    </template>
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
                couponList: [],
                memberId: "${memberId}",
                currentTab: "ALL",
                tabs: [
                    { name: "전체", value: "ALL" },
                    { name: "보유 쿠폰", value: "AVAILABLE" },
                    { name: "사용 완료", value: "USED" },
                    { name: "만료 쿠폰", value: "EXPIRED" }
                ]
            };
        },
        computed: {
            availableCount() {
                return this.couponList.filter(c => c.displayStatus === "AVAILABLE").length;
            },
            usedCount() {
                return this.couponList.filter(c => c.displayStatus === "USED").length;
            },
            expiredCount() {
                return this.couponList.filter(c => c.displayStatus === "EXPIRED").length;
            },
            filteredCoupons() {
                if (this.currentTab === "ALL") return this.couponList;
                return this.couponList.filter(c => c.displayStatus === this.currentTab);
            }
        },
        methods: {
            fnStatusName(status) {
                if (status === "AVAILABLE") return "보유 중";
                if (status === "USED") return "사용 완료";
                if (status === "EXPIRED") return "기간 만료";
                return status;
            },
            fnGetCouponList() {
                let self = this;
                $.ajax({
                    url: "/coupon/mylist.dox",
                    type: "POST",
                    dataType: "json",
                    data: { memberId: self.memberId },
                    success: function (data) {
                        if (data.result === "success") {
                            self.couponList = data.list || [];
                        } else {
                            alert(data.message || "쿠폰 조회에 실패했습니다.");
                        }
                    },
                    error: function (xhr, status, error) {
                        console.log(xhr.responseText);
                        console.log(error);
                        alert("서버 통신 중 오류가 발생했습니다.");
                    }
                });
            }
        },
        mounted() {
            this.fnGetCouponList();
        }
    });
    app.mount("#app");
</script>
