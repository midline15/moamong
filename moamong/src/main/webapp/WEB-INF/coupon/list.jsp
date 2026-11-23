
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>내 쿠폰함</title>

    <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
    <script src="/js/page-change.js"></script>
	<link rel="stylesheet" href="/css/coupon/list.css">
 
</head>

<body>

<div id="app" class="container">

    <h2>🎫 내 쿠폰 목록</h2>
    <p>회원님이 발급받은 쿠폰 내역을 확인할 수 있습니다.</p>

    <!-- 쿠폰 요약 -->
    <div class="summary">

        <div class="summary-item">
            <h2>{{ couponList.length }}</h2>
            전체 쿠폰
        </div>

        <div class="summary-item">
            <h2>{{ availableCount }}</h2>
            보유 쿠폰
        </div>

        <div class="summary-item">
            <h2>{{ usedCount }}</h2>
            사용 완료
        </div>

        <div class="summary-item">
            <h2>{{ expiredCount }}</h2>
            만료 쿠폰
        </div>

    </div>

    <!-- 쿠폰 상태 탭 -->
    <div class="tabs">

        <button
            v-for="tab in tabs"
            :key="tab.value"
            :class="{ active: currentTab === tab.value }"
            @click="currentTab = tab.value">

            {{ tab.name }}

        </button>

    </div>

    <!-- 쿠폰 목록 -->
    <div
        v-for="coupon in filteredCoupons"
        :key="coupon.memberCouponId"
        class="coupon-card"
        :class="{
            used: coupon.displayStatus === 'USED',
            expired: coupon.displayStatus === 'EXPIRED'
        }">

        <div class="coupon-info">

            <!-- 상태 -->
            <span
                class="status"
                :class="coupon.displayStatus.toLowerCase()">

                {{ fnStatusName(coupon.displayStatus) }}

            </span>

            <!-- 할인 정보 -->
            <div class="discount">

                <span v-if="coupon.discountType === 'FIXED'">
                    {{ Number(coupon.discountValue).toLocaleString() }}원
                </span>

                <span v-else-if="coupon.discountType === 'RATE'">
                    {{ coupon.discountValue }}%
                </span>

            </div>

            <!-- 쿠폰 이름 -->
            <strong>{{ coupon.couponName }}</strong>

            <p>
                {{ Number(coupon.minimumOrderAmount).toLocaleString() }}원 이상 구매 시 사용
            </p>

            <p>
                발급일 : {{ coupon.issuedAt }}
            </p>

            <p>
                유효기간 : {{ coupon.validFrom }} ~ {{ coupon.validUntil }}
            </p>

            <p v-if="coupon.maximumDiscountAmount">
                최대 할인 금액 :
                {{ Number(coupon.maximumDiscountAmount).toLocaleString() }}원
            </p>

        </div>

        <!-- 사용한 쿠폰의 주문 정보 -->
        <div class="coupon-extra">

            <div v-if="coupon.displayStatus === 'USED'">

                <p>사용 주문 번호</p>

                <strong>
                    {{ coupon.orderId || '-' }}
                </strong>

                <p>실제 할인 금액</p>

                <strong>
                    {{ Number(coupon.discountAmount || 0).toLocaleString() }}원
                </strong>

            </div>

            <div v-else>
                <span>🎫</span>
            </div>

        </div>

    </div>

    <!-- 내역이 없는 경우 -->
    <div v-if="filteredCoupons.length === 0" class="empty">
        해당 쿠폰 내역이 없습니다.
    </div>

</div>

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
            return this.couponList.filter(
                c => c.displayStatus === "AVAILABLE"
            ).length;
        },

        usedCount() {
            return this.couponList.filter(
                c => c.displayStatus === "USED"
            ).length;
        },

        expiredCount() {
            return this.couponList.filter(
                c => c.displayStatus === "EXPIRED"
            ).length;
        },

        filteredCoupons() {

            if (this.currentTab === "ALL") {
                return this.couponList;
            }

            return this.couponList.filter(
                c => c.displayStatus === this.currentTab
            );

        }

    },

    methods: {

        fnStatusName(status) {

            if (status === "AVAILABLE") {
                return "보유 중";
            }

            if (status === "USED") {
                return "사용 완료";
            }

            if (status === "EXPIRED") {
                return "기간 만료";
            }

            return status;

        },

        fnGetCouponList() {

            let self = this;

            $.ajax({

                url: "/coupon/mylist.dox",

                type: "POST",

                dataType: "json",

                data: {
                    memberId: self.memberId
                },

                success: function(data) {

                    if (data.result === "success") {

                        self.couponList = data.list || [];

                    } else {

                        alert(data.message || "쿠폰 조회에 실패했습니다.");

                    }

                },

                error: function(xhr, status, error) {

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

</body>
</html>
