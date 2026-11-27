<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>모아몽 - 알림 센터</title>
    <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
	<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/notification/notification.css">
</head>
<body>
    <%@ include file="/WEB-INF/common/header.jsp"%>

    <div id="app" class="noti-wrap">
        <!-- 좌측 3단 탭 사이드바 (전체 알림 / 중요 알림 / 휴지통) -->
        <aside class="noti-sidebar">
            <div class="noti-side-title">알림</div>
            <ul class="noti-side-menu">
                <li :class="{ active: tab === 'ALL' }"><a @click="fnChangeTab('ALL')">전체 알림</a></li>
                <li :class="{ active: tab === 'IMPORTANT' }"><a @click="fnChangeTab('IMPORTANT')">중요 알림</a></li>
                <li :class="{ active: tab === 'TRASH' }"><a @click="fnChangeTab('TRASH')">휴지통</a></li>
            </ul>
        </aside>

        <main style="flex:1; min-width:0;">
            <div style="padding:26px 0 16px; border-bottom:1px solid #e3d6c1;">
                <h2 style="margin:0; font-size:22px;">{{ tabTitle }}</h2>
            </div>

            <!-- 상단 액션 툴바 -->
            <div class="noti-toolbar">
                <div style="display:flex; align-items:center; gap:8px;">
                    <label style="cursor:pointer; display:flex; align-items:center; gap:5px; font-weight:600;">
                        <input type="checkbox" v-model="isAllChecked" @change="fnToggleAll" :disabled="pagedList.length === 0"> 전체 선택
                    </label>
                    <template v-if="tab !== 'TRASH'">
                        <button class="noti-pill-btn" :disabled="selectedIds.length === 0" @click="fnActionSelected('TRASH')">삭제</button>
                        <button v-if="tab === 'ALL'" class="noti-pill-btn" :disabled="counts.unreadCount == 0" @click="fnActionAll('READ_ALL')">모두읽음</button>
                        <button class="noti-pill-btn" :disabled="!canBulkLike" @click="fnBulkImportant('Y')">전체 찜 하기</button>
                        <button class="noti-pill-btn" :disabled="!canBulkUnlike" @click="fnBulkImportant('N')">전체 찜 해제</button>
                    </template>
                    <template v-else>
                        <button class="noti-pill-btn" :disabled="selectedIds.length === 0" @click="fnActionSelected('RESTORE')">복원</button>
                        <button class="noti-pill-btn" :disabled="selectedIds.length === 0" @click="fnActionSelected('DELETE_PERM')">삭제</button>
                        <button class="noti-pill-btn" :disabled="list.length === 0" @click="fnActionAll('DELETE_PERM')">비우기</button>
                        <button class="noti-pill-btn" :disabled="list.length === 0" @click="fnActionAll('RESTORE')">전체복원</button>
                    </template>
                </div>
                <div style="font-size:12px; color:#5c5346;">
                    <span v-if="tab === 'ALL'">읽지 않은 알림 <strong style="color:#d94848;">{{ counts.unreadCount }}</strong></span>
                    <span v-else>전체 알림 <strong style="color:#d94848;">{{ list.length }}</strong></span>
                </div>
            </div>

            <div v-if="pagedList.length === 0" class="noti-row-card" style="justify-content:center; padding:60px 0; font-weight:700; color:#85817b;">
                현재 남아있는 알림이 없습니다.
            </div>

            <!-- 읽은 알림(isRead === 'Y')은 배경과 텍스트를 옅게 처리 -->
            <div v-for="item in pagedList" :key="item.notificationId" class="noti-row-card"
                 :style="item.isRead === 'Y' && tab !== 'TRASH' ? 'background:#f5f2ec; opacity:0.78;' : ''">
                <input type="checkbox" :value="item.notificationId" v-model="selectedIds">
                <div class="noti-cat-pill">{{ fnTypeLabel(item.notificationType) }}</div>

                <div style="flex:1; min-width:0; cursor:pointer;" @click="fnReadOne(item)">
                    <div :style="item.isRead === 'Y' ? 'font-size:15px; font-weight:500; color:#9a8f80;' : 'font-size:15px; font-weight:700; color:#29251f;'">
                        {{ item.notificationTitle }}
                    </div>
                    <div :style="item.isRead === 'Y' ? 'font-size:13px; color:#b0a89c; margin-top:3px;' : 'font-size:13px; color:#5c5346; margin-top:3px;'">
                        {{ item.notificationContent }}
                    </div>
                    <div style="font-size:11px; color:#b88b68; margin-top:4px;">{{ item.createdAt }}</div>
                </div>

                <div style="display:flex; flex-direction:column; align-items:center; gap:6px;">
                    <span v-if="item.isRead === 'N' && tab !== 'TRASH'" class="noti-new-tag">new</span>
                    <button v-if="tab !== 'TRASH'" type="button" class="noti-heart-btn" @click="fnToggleHeart(item)">
                        {{ item.isImportant === 'Y' ? '♥' : '♡' }}
                    </button>
                    <button type="button" class="noti-pill-btn" @click="fnSingleDelete(item.notificationId)">삭제</button>
                </div>
            </div>


            <!-- 페이징 (5건씩) -->
            <div v-if="totalPages > 1" style="display:flex; justify-content:center; gap:8px; margin-top:22px; font-size:13px;">
                <button class="noti-pill-btn" :disabled="page === 1" @click="page = 1">&laquo;</button>
                <button class="noti-pill-btn" :disabled="page === 1" @click="page--">&lsaquo;</button>
                <button v-for="p in totalPages" :key="p" class="noti-pill-btn"
                        :style="p === page ? 'background:#94764b; color:#fff;' : ''" @click="page = p">{{ p }}</button>
                <button class="noti-pill-btn" :disabled="page === totalPages" @click="page++">&rsaquo;</button>
                <button class="noti-pill-btn" :disabled="page === totalPages" @click="page = totalPages">&raquo;</button>
            </div>
        </main>
    </div>

    <%@ include file="/WEB-INF/common/footer.jsp"%>
</body>
</html>
<script>
    const app = Vue.createApp({
        data() {
            return { tab: "ALL", list: [], counts: { totalCount: 0, unreadCount: 0 }, selectedIds: [], page: 1, pageSize: 5 };
        },
        computed: {
            tabTitle() { return this.tab === "IMPORTANT" ? "중요 알림" : (this.tab === "TRASH" ? "휴지통" : "전체 알림"); },
            totalPages() { return Math.max(1, Math.ceil(this.list.length / this.pageSize)); },
            pagedList() { return this.list.slice((this.page - 1) * this.pageSize, this.page * this.pageSize); },
            isAllChecked: {
                get() { return this.pagedList.length > 0 && this.pagedList.every(i => this.selectedIds.includes(i.notificationId)); },
                set() {}
            }
        },
        methods: {
            fnTypeLabel(t) { 
                return { 
                    COUPON: "쿠폰", 
                    ORDER: "주문", 
                    DELIVERY: "배송 정보", 
                    RETURN: "반품", 
                    SECURITY: "보안",
                    INQUIRY: "고객센터" 
                }[t] || t; 
            },
            fnLoad() {
                let self = this;
                $.post("/notification/list.dox", { tab: this.tab }, function(res) {
                    if (res.result === "success") {
                        self.list = res.list || [];
                        self.counts = res.counts || { totalCount: 0, unreadCount: 0 };
                        self.selectedIds = [];
                        if (self.page > self.totalPages) self.page = self.totalPages;
                    }
                });
            },
            fnChangeTab(t) { 
                this.tab = t; 
                this.page = 1; 
                this.fnLoad(); 
            },
            fnToggleAll(e) {
                const pageIds = this.pagedList.map(i => i.notificationId);
                this.selectedIds = e.target.checked ? pageIds : [];
            },
            fnGetTargetUrl(item) {
                const type = item.notificationType;
                const relId = item.relatedId;
                if (type === "COUPON") return "/member/myCoupon.do";
                if (type === "ORDER" || type === "DELIVERY") {
                    return relId ? ("/order/detail.do?orderId=" + relId) : "/order/list.do";
                }
                if (type === "RETURN") return "/order/cancelList.do";
                if (type === "INQUIRY") return "/inquiry/myList.do";
                if (type === "REVIEW") return "/review/myReview.do";
                if (type === "SECURITY") return "/member/edit.do";
                return null;
            },
            fnReadOne(item) {
                if (this.tab === "TRASH") return;
                const destUrl = this.fnGetTargetUrl(item);
                const goNext = () => {
                    if (destUrl) location.href = destUrl;
                    else this.fnLoad();
                };
                if (item.isRead === "Y") {
                    goNext();
                    return;
                }
                $.post("/notification/action.dox", {
                    type: "READ_ONE",
                    notificationId: item.notificationId
                }, goNext);
            },
            fnToggleHeart(item) {
                const next = item.isImportant === "Y" ? "N" : "Y";
                $.post("/notification/action.dox", {
                     type: "IMPORTANT",
                     ids: String(item.notificationId), 
                     isImportant: next 
                },
                this.fnLoad);
            },
            fnBulkImportant(val) {
                const targetIds = this.selectedIds.length > 0 ? this.selectedIds : this.pagedList.map(i => i.notificationId);
                if (targetIds.length === 0) return;
                $.post("/notification/action.dox", { type: "IMPORTANT", ids: targetIds.join(","), isImportant: val }, this.fnLoad);
            },
            fnSingleDelete(id) {
                const msg = this.tab === "TRASH" ? "이 알림을 영구 삭제하시겠습니까? 복구할 수 없습니다." : "이 알림을 휴지통으로 이동하시겠습니까?";
                if (!confirm(msg)) return;
                const act = this.tab === "TRASH" ? "DELETE_PERM" : "TRASH";
                $.post("/notification/action.dox", { type: act, ids: String(id) }, this.fnLoad);
            },
            fnActionSelected(type) {
                if (this.selectedIds.length === 0) { alert("항목을 먼저 선택해주세요."); return; }
                if (type === "TRASH" && !confirm("선택한 " + this.selectedIds.length + "건의 알림을 삭제하시겠습니까?")) return;
                if (type === "DELETE_PERM" && !confirm("선택한 " + this.selectedIds.length + "건의 알림을 영구 삭제하시겠습니까?")) return;
                $.post("/notification/action.dox", { type: type, ids: this.selectedIds.join(",") }, this.fnLoad);
            },
            fnActionAll(type) {
                if (type === "DELETE_PERM" && !confirm("휴지통의 모든 알림을 영구 삭제하시겠습니까?")) return;
                $.post("/notification/action.dox", { type: type }, this.fnLoad);
            }

        },
        computed: {
            tabTitle() { return this.tab === "IMPORTANT" ? "중요 알림" : (this.tab === "TRASH" ? "휴지통" : "전체 알림"); },
            totalPages() { return Math.max(1, Math.ceil(this.list.length / this.pageSize)); },
            pagedList() { return this.list.slice((this.page - 1) * this.pageSize, this.page * this.pageSize); },
            isAllChecked: {
                get() { return this.pagedList.length > 0 && this.pagedList.every(i => this.selectedIds.includes(i.notificationId)); },
                set() {}
            },
            targetItems() {
                return this.selectedIds.length > 0
                    ? this.pagedList.filter(i => this.selectedIds.includes(i.notificationId))
                    : this.pagedList;
            },
            canBulkLike() { return this.targetItems.some(i => i.isImportant !== "Y"); },
            canBulkUnlike() { return this.targetItems.some(i => i.isImportant === "Y"); }
        },
        mounted() { this.fnLoad(); }
    });
    app.mount("#app");
</script>
