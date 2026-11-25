<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">

<!-- 배경 오버레이 (클릭하면 닫힘) -->
<div class="sidebar-overlay" id="sidebarOverlay"></div>

<!-- 사이드바 전체 영역 -->
<aside class="menu-container"
       id="sidebar"
       aria-label="사이드 메뉴">

    <!-- 상단: 로고 + 닫기 버튼 -->
    <div class="menu-head">

        <a href="${pageContext.request.contextPath}/" class="menu-logo">
            <img src="${pageContext.request.contextPath}/assets/logos/moamongEn.png"
                 alt="Moamong">
        </a>

        <button type="button"
                class="menu-close"
                id="menuClose"
                aria-label="메뉴 닫기"></button>

    </div>

    <!-- 메뉴 -->
    <nav class="menu-nav" aria-label="주 메뉴">

        <ul class="main-menu">

            <li>
                <a href="/event/list.do" class="menu-link">이벤트</a>
            </li>

            <!-- 선물키트 (펼침 메뉴) -->
            <li class="has-submenu">

                <button type="button"
                        class="menu-toggle"
                        aria-expanded="false"
                        aria-controls="submenu-giftkit">
                    선물키트
                    <span class="menu-arrow"></span>
                </button>

                <div class="submenu-wrap" id="submenu-giftkit">
                    <div class="submenu-inner">

                        <!-- 대상별 -->
                        <div class="sub-group">
                            <p class="sub-title">마음을 전할 사람</p>
                            <ul class="chip-list">
                                <li><a href="/package/list.do?target=가족">가족</a></li>
                                <li><a href="/package/list.do?target=연인">연인</a></li>
                                <li><a href="/package/list.do?target=친구">친구</a></li>
                                <li><a href="/package/list.do?target=동료">동료</a></li>
                                <li><a href="/package/list.do?target=나에게">나에게</a></li>
                            </ul>
                        </div>

                        <!-- 목적별 -->
                        <div class="sub-group">
                            <p class="sub-title">특별한 순간</p>
                            <ul class="chip-list">
                                <li><a href="/package/list.do?purpose=생일ㆍ기념일">생일ㆍ기념일</a></li>
                                <li><a href="/package/list.do?purpose=감사ㆍ답례">감사ㆍ답례</a></li>
                                <li><a href="/package/list.do?purpose=축하ㆍ응원">축하ㆍ응원</a></li>
                                <li><a href="/package/list.do?purpose=위로ㆍ격려">위로ㆍ격려</a></li>
                            </ul>
                        </div>

                    </div>
                </div>

            </li>

            <li>
                <a href="#" class="menu-link">단품</a>
            </li>

            <li>
                <a href="/community/list.do" class="menu-link">STORY</a>
            </li>

            <li>
                <a href="/notice/list.do" class="menu-link">고객센터</a>
            </li>

        </ul>

    </nav>

    <!-- 하단: 로그인 + 고객센터 정보 -->
    <div class="menu-foot">

        <div class="menu-auth">
            <% if (session.getAttribute("sessionId") == null) { %>
                <a href="/member/login.do" class="auth-login">로그인</a>
                <a href="/member/join.do" class="auth-signup">회원가입</a>
            <% } else { %>
                <a href="/member/mypage.do" class="auth-login">마이페이지</a>
                <a href="/member/logout.do" class="auth-signup" onclick="return confirm('로그아웃 하시겠습니까?');">로그아웃</a>
            <% } %>
        </div>


        <div class="menu-cs">
            <strong>1588-0000</strong>
            평일 09:00 ~ 18:00
        </div>

    </div>

</aside>


<!-- 사이드바 JavaScript -->
<script>

(function() {

    // 중복 이벤트 등록 방지
    if (window.sidebarMenuInitialized) {
        return;
    }

    window.sidebarMenuInitialized = true;

    function initSidebar() {

        const sidebar = document.getElementById("sidebar");
        const overlay = document.getElementById("sidebarOverlay");
        const openBtn = document.querySelector(".menu-btn");
        const closeBtn = document.getElementById("menuClose");

        if (!sidebar || !overlay || !openBtn || !closeBtn) {
            console.error("사이드바 요소를 찾을 수 없습니다.");
            return;
        }

        /* ---------- 펼침 메뉴 (아코디언) ---------- */

        function setSection(item, open) {

            const toggle = item.querySelector(".menu-toggle");

            item.classList.toggle("open", open);
            toggle.setAttribute("aria-expanded", String(open));
        }

        function collapseAll() {

            sidebar.querySelectorAll(".has-submenu.open").forEach(function(item) {
                setSection(item, false);
            });
        }

        sidebar.querySelectorAll(".menu-toggle").forEach(function(toggle) {

            toggle.addEventListener("click", function() {

                const item = toggle.closest(".has-submenu");
                const willOpen = !item.classList.contains("open");

                // 하나만 열리도록 나머지는 접기
                collapseAll();
                setSection(item, willOpen);
            });
        });


        /* ---------- 사이드바 열기 / 닫기 ---------- */

        function openSidebar() {

            sidebar.classList.add("active");
            overlay.classList.add("active");
            document.body.classList.add("sidebar-open");

            openBtn.setAttribute("aria-expanded", "true");
            openBtn.setAttribute("aria-label", "메뉴 닫기");

            closeBtn.focus();
        }

        function closeSidebar() {

            sidebar.classList.remove("active");
            overlay.classList.remove("active");
            document.body.classList.remove("sidebar-open");

            openBtn.setAttribute("aria-expanded", "false");
            openBtn.setAttribute("aria-label", "메뉴 열기");

            // 닫을 때 펼쳐둔 메뉴도 초기화
            collapseAll();

            openBtn.focus();
        }

        // 햄버거 버튼
        openBtn.addEventListener("click", function() {

            if (sidebar.classList.contains("active")) {
                closeSidebar();
            } else {
                openSidebar();
            }
        });

        // X 버튼 / 배경 클릭
        closeBtn.addEventListener("click", closeSidebar);
        overlay.addEventListener("click", closeSidebar);

        // ESC 키 + Tab 포커스가 사이드바 밖으로 나가지 않게
        document.addEventListener("keydown", function(event) {

            if (!sidebar.classList.contains("active")) {
                return;
            }

            if (event.key === "Escape") {
                closeSidebar();
                return;
            }

            if (event.key === "Tab") {

                const focusable = Array.from(
                    sidebar.querySelectorAll("a[href], button")
                ).filter(function(el) {
                    return getComputedStyle(el).visibility !== "hidden";
                });

                if (focusable.length === 0) {
                    return;
                }

                const first = focusable[0];
                const last = focusable[focusable.length - 1];

                if (event.shiftKey && document.activeElement === first) {
                    event.preventDefault();
                    last.focus();
                } else if (!event.shiftKey && document.activeElement === last) {
                    event.preventDefault();
                    first.focus();
                }
            }
        });

    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initSidebar);
    } else {
        initSidebar();
    }

})();

</script>
