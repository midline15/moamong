
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/notification/notification.css">

<!-- 헤더 CSS -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">

<!-- 헤더 전체 영역 -->
<div class="header-container">

    <header class="header header-main">

        <!-- 왼쪽 햄버거 메뉴 -->
        <div class="header-left">

            <button type="button"
                    class="menu-btn"
                    aria-label="메뉴 열기"
                    aria-expanded="false"
                    aria-controls="sidebar">

                <span></span>
                <span></span>
                <span></span>

            </button>

        </div>

        <!-- 중앙 로고 -->
        <h1 class="logo">

            <a href="${pageContext.request.contextPath}/">

                <img
                    src="${pageContext.request.contextPath}/assets/logos/moamongLogo.png"
                    alt="모아몽 로고">

            </a>

        </h1>

                <!-- 오른쪽 아이콘 메뉴 -->
        <div class="header-right">

            <!-- 찜 -->
            <a href="/wishlist/list.do" class="icon-menu" aria-label="찜">
                <svg viewBox="0 0 24 24">
                    <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1.1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 21l8.8-8.6a5.5 5.5 0 0 0 0-7.8z" />
                </svg>
            </a>

            <!-- 장바구니 -->
            <a href="/cart/list.do" class="icon-menu" aria-label="장바구니">
                <svg viewBox="0 0 24 24">
                    <path d="M3 3h2l2.5 13h11L21 7H6" />
                    <circle cx="9" cy="20" r="1" />
                    <circle cx="18" cy="20" r="1" />
                </svg>
            </a>

            <!-- 알림 아이콘 + 소형 팝오버 -->
            <div class="noti-bell-wrap" id="moamongNotiWrap">
                <a href="javascript:;" class="icon-menu" id="notiBellBtn" aria-label="알림">
                    <svg viewBox="0 0 24 24">
                        <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9" />
                        <path d="M10 21h4" />
                    </svg>
                    <span class="noti-badge-count" id="notiUnreadBadge" style="display:none;">0</span>
                </a>

                <!-- 소형 알림 창 -->
                <div class="noti-popover" id="notiPopover" style="display:none;">
                    <div class="noti-pop-head">
                        <div>
                            <strong style="font-size:19px;">알림</strong>
                            <span style="font-size:12px; color:#85817b; margin-left:6px;">
                                전체 <span id="notiPopTotal" style="color:#d94848; font-weight:700;">0</span>개
                            </span>
                        </div>
                        <span style="font-size:12px; color:#5c5346;">
                            읽지 않은 알림 <strong id="notiPopUnread" style="color:#d94848;">0</strong>
                        </span>
                    </div>

                    <div id="notiPopList"></div>

                    <div class="noti-pop-foot">
                        <div style="width:82px;"></div>
                        <a href="/notification/list.do" style="font-size:13px; font-weight:700; color:#765a36;">전체 알림 보기 &rarr;</a>
                        <div style="display:flex; flex-direction:column; gap:5px;">
                            <button type="button" class="noti-pill-btn" id="notiPopReadAll">모두 읽음 표시</button>
                            <button type="button" class="noti-pill-btn" id="notiPopTrashAll">전체 삭제</button>
                        </div>
                    </div>
                </div>
            </div>


            <!-- 마이페이지 -->
            <a href="/member/mypage.do" class="icon-menu" aria-label="마이페이지">
                <svg viewBox="0 0 24 24">
                    <circle cx="12" cy="8" r="4" />
                    <path d="M4 21v-2a8 8 0 0 1 16 0v2" />
                </svg>
            </a>

            <!-- 로그인 / 회원가입 (세션 유무에 따라 분기) -->
            <div class="user-menu">
                <% if (session.getAttribute("sessionId") == null) { %>
                    <a href="/member/login.do" class="login-link">로그인</a>
                    <span class="user-divider"></span>
                    <a href="/member/join.do" class="signup-link">회원가입</a>
                    <div class="signup-tooltip">
                        <div>
                            <strong>모아몽 신규 회원 혜택</strong>
                            <p>지금 가입하고 특별한 혜택을 만나보세요!</p>
                        </div>
                    </div>
                <% } else { %>
                    <a href="/member/mypage.do" class="login-link">마이페이지</a>
                    <span class="user-divider"></span>
                    <a href="/member/logout.do" class="login-link">로그아웃</a>
                <% } %>
            </div>


        </div>


    </header>

</div>

<!-- 알림 소형 팝업창 스크립트 (로그인 했을 시에만 기능)-->
<% if (session.getAttribute("sessionId") != null) { %>
<script>
(function() {
    const typeMap = { COUPON: "쿠폰", ORDER: "주문", DELIVERY: "배송현황", RETURN: "반품", INQUIRY: "고객센터" };

    function timeAgo(dateStr) {
        if (!dateStr) return "";
        const diff = Math.floor((new Date() - new Date(dateStr.replace(" ", "T"))) / 1000);
        if (diff < 60) return Math.max(1, diff) + "초 전";
        if (diff < 3600) return Math.floor(diff / 60) + "분 전";
        if (diff < 86400) return Math.floor(diff / 3600) + "시간 전";
        return Math.floor(diff / 86400) + "일 전";
    }

    function postNoti(url, params, cb) {
        const body = new URLSearchParams(params || {});
        fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
            body: body
        }).then(r => r.json()).then(cb).catch(err => console.error(err));
    }

    function loadNotiPopover() {
        postNoti("/notification/popover.dox", {}, function(res) {
            if (!res || res.result !== "success") return;
            const total = Number(res.counts.totalCount || 0);
            const unread = Number(res.counts.unreadCount || 0);

            const totalEl = document.getElementById("notiPopTotal");
            const unreadEl = document.getElementById("notiPopUnread");
            const badgeEl = document.getElementById("notiUnreadBadge");
            const box = document.getElementById("notiPopList");
            if (!totalEl || !box) return;

            totalEl.textContent = total > 999 ? "999+" : total;
            unreadEl.textContent = unread;
            if (unread > 0) {
                badgeEl.textContent = unread > 99 ? "99+" : unread;
                badgeEl.style.display = "flex";
            } else {
                badgeEl.style.display = "none";
            }

            const list = res.recentList || [];
            box.innerHTML = "";
            if (list.length === 0) {
                box.innerHTML = '<div style="text-align:center; padding:36px 0; font-size:14px; font-weight:700; color:#5c5346;">현재 남아있는 알림이 없습니다</div>';
                return;
            }
            list.forEach(function(item) {
                const cat = typeMap[item.notificationType] || item.notificationType;
                const newHtml = item.isRead === "N" ? '<span class="noti-new-tag">new</span>' : '';
                const row = document.createElement("div");
                row.className = "noti-pop-item";
                row.innerHTML =
                    '<div class="noti-cat-pill">' + cat + '</div>' +
                    '<div style="flex:1; min-width:0;">' +
                        '<div style="font-size:13px; font-weight:700; color:#29251f;">' + item.notificationTitle + '</div>' +
                        '<div style="font-size:12px; color:#85817b; margin-top:2px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">' + item.notificationContent + '</div>' +
                        '<div style="font-size:11px; color:#d94848; margin-top:3px;">' + timeAgo(item.createdAt) + '</div>' +
                    '</div>' +
                    '<div style="display:flex; flex-direction:column; align-items:flex-end; gap:6px;">' +
                        newHtml +
                        '<button type="button" class="noti-pill-btn noti-del-one" style="padding:2px 8px;">X</button>' +
                    '</div>';

                row.addEventListener("click", function(e) {
                    if (e.target.classList.contains("noti-del-one")) return;
                    postNoti("/notification/action.dox", { type: "READ_ONE", notificationId: item.notificationId }, function() {
                        location.href = "/notification/list.do";
                    });
                });
                row.querySelector(".noti-del-one").addEventListener("click", function(e) {
                    e.stopPropagation();
                    postNoti("/notification/action.dox", { type: "TRASH", ids: String(item.notificationId) }, loadNotiPopover);
                });
                box.appendChild(row);
            });
        });
    }

    function initHeaderNoti() {
        const bellBtn = document.getElementById("notiBellBtn");
        const popover = document.getElementById("notiPopover");
        const wrap = document.getElementById("moamongNotiWrap");
        const readAllBtn = document.getElementById("notiPopReadAll");
        const trashAllBtn = document.getElementById("notiPopTrashAll");
        if (!bellBtn || !popover) return;

        loadNotiPopover();

        bellBtn.addEventListener("click", function(e) {
            e.stopPropagation();
            const isHidden = popover.style.display === "none" || popover.style.display === "";
            popover.style.display = isHidden ? "block" : "none";
            if (isHidden) loadNotiPopover();
        });

        document.addEventListener("click", function(e) {
            if (wrap && !wrap.contains(e.target)) popover.style.display = "none";
        });

        if (readAllBtn) {
            readAllBtn.addEventListener("click", function() {
                const total = Number(document.getElementById("notiPopTotal").textContent.replace("+", "")) || 0;
                const unread = Number(document.getElementById("notiPopUnread").textContent) || 0;
                if (total === 0) { alert("표시할 알림이 없습니다."); return; }
                if (unread === 0) { alert("이미 모든 알림을 읽었습니다."); return; }
                postNoti("/notification/action.dox", { type: "READ_ALL" }, loadNotiPopover);
            });
        }

        if (trashAllBtn) {
            trashAllBtn.addEventListener("click", function() {
                const total = Number(document.getElementById("notiPopTotal").textContent.replace("+", "")) || 0;
                if (total === 0) { alert("삭제할 알림이 없습니다."); return; }
                if (!confirm("모든 알림을 휴지통으로 이동하시겠습니까?")) return;
                postNoti("/notification/action.dox", { type: "TRASH_ALL" }, loadNotiPopover);
            });
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initHeaderNoti);
    } else {
        initHeaderNoti();
    }
})();
</script>
<% } else { %>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const bellBtn = document.getElementById("notiBellBtn");
        if (bellBtn) bellBtn.addEventListener("click", function() { location.href = "/member/login.do"; });
    });
</script>
<% } %>

<!-- 사이드바 연결 (header.jsp 맨 마지막 줄 필수) -->
<jsp:include page="/WEB-INF/common/sidebar.jsp" />