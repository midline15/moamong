<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 메인</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <jsp:include page="/chatbot/chatWidget.jsp" />
        <!-- 공통 레이아웃 & 메인 전용 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main/main.css">
    </head>
<body>
    <%@ include file="/WEB-INF/common/header.jsp"%>

    <main id="app" class="main-wrap">
        <!-- 섹션 1: 선물하고 싶은 대상은? -->
        <section class="gift-section">
            <span class="gift-eyebrow">FOR WHOM</span>
            <h2>선물하고 싶은 대상은?</h2>
            <p>소중한 사람을 떠올리며 맞춤 선물키트를 골라보세요</p>
            <div class="tag-grid">
                <button type="button" class="tag-card" v-for="t in targetList" :key="t"
                        @click="goGiftKit('target', t)">
                    # {{ t }}
                </button>
            </div>
        </section>

        <!-- 섹션 2: 선물하려는 목적은? -->
        <section class="gift-section alt">
            <span class="gift-eyebrow">OCCASION</span>
            <h2>선물하려는 목적은?</h2>
            <p>특별한 순간에 어울리는 마음을 전해드립니다</p>
            <div class="tag-grid">
                <button type="button" class="tag-card" v-for="p in purposeList" :key="p"
                        @click="goGiftKit('purpose', p)">
                    # {{ p }}
                </button>
            </div>
        </section>
    </main>

    <%@ include file="/WEB-INF/common/footer.jsp"%>
</body>
</html>

<script>
    const app = Vue.createApp({
        data() {
            return {
                targetList: ["가족", "연인", "친구", "동료", "나에게"],
                purposeList: ["생일ㆍ기념일", "감사ㆍ답례", "축하ㆍ응원", "위로ㆍ격려"]
            };
        },
        methods: {
            // 추후 선물키트 목록 페이지 URL 확정 시 아래 경로만 연결하면 됩니다.
            goGiftKit(type, value) {
                location.href = "/package/list.do?" + type + "=" + encodeURIComponent(value);
            }
        }
    });
    app.mount('#app');
</script>
