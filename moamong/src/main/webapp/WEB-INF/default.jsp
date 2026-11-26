<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>모아몽 메인</title>

    <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
    <script src="/js/page-change.js"></script>

    <!-- 폰트 (이미 다른 곳에서 불러오고 있으면 이 줄은 지워도 됩니다) -->
    <link rel="stylesheet"
        href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">

    <!-- 공통 레이아웃 & 메인 전용 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/main/main.css">
</head>

<body>
    <%@ include file="/WEB-INF/common/header.jsp" %>

    <div id="app" class="main-page" v-cloak>

        <!-- 이미지 확인하는 동안 자리만 잡아둠 -->
        <section class="hero-skeleton" v-if="!loaded" aria-hidden="true"></section>

        <!-- 메인 슬라이더 (화면 전체 폭) -->
        <section class="hero" v-else-if="slideList.length > 0" aria-label="메인 배너"
            @mouseenter="fnStop" @mouseleave="fnPlay"
            @touchstart.passive="fnTouchStart" @touchend.passive="fnTouchEnd">

            <div class="hero-track" :style="{ transform: 'translateX(-' + current * 100 + '%)' }">
                <!-- link 가 있으면 <a>, 없으면 클릭 안 되는 <div> -->
                <component :is="s.link ? 'a' : 'div'" class="hero-slide"
                    v-for="(s, i) in slideList" :key="i" :href="s.link || null">

                    <!-- 같은 이미지를 흐리게 깔아서 배경으로 사용 -->
                    <div class="hero-bg" :style="fnBg(s.img)"></div>

                    <img class="hero-img" :src="s.img" :alt="s.alt" draggable="false">
                </component>
            </div>

            <!-- 화살표 / 인디케이터 -->
            <div class="hero-ui" v-if="slideList.length > 1">
                <button type="button" class="hero-arrow prev" aria-label="이전" @click.prevent="fnMove(-1)">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.2">
                        <path d="M15 5l-7 7 7 7"></path>
                    </svg>
                </button>
                <button type="button" class="hero-arrow next" aria-label="다음" @click.prevent="fnMove(1)">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.2">
                        <path d="M9 5l7 7-7 7"></path>
                    </svg>
                </button>

                <div class="hero-bar">
                    <div class="hero-dots">
                        <button type="button" v-for="(s, i) in slideList" :key="i"
                            :class="{ on: i == current }" :aria-label="(i + 1) + '번째 배너'"
                            @click="fnGo(i)"></button>
                    </div>
                    <span class="hero-count">{{ current + 1 }} / {{ slideList.length }}</span>
                </div>
            </div>
        </section>

        <main class="main-wrap">

            <!-- 선물 대상 선택 -->
            <section class="gift-banner one">
                <div class="gift-inner">

                    <div class="gift-heading">
                        <span class="gift-eyebrow">WHO DO YOU LOVE?</span>
                        <h2>누구에게 마음을 전할까요?</h2>
                        <p>소중한 사람을 떠올리며 특별한 선물을 골라보세요</p>
                    </div>

                    <div class="gift-target-grid">
                        <button type="button" class="target-card" v-for="(t, i) in targetList" :key="t"
                            @click="goGiftKit('target', t)">

                            <span class="select-icon">
                                {{ ['🏡', '💕', '🌷', '🎁', '🧸'][i] }}
                            </span>

                            <strong>{{ t }}</strong>
                        </button>
                    </div>

                </div>
            </section>

            <!-- 선물 목적 선택 -->
            <section class="gift-banner two">
                <div class="gift-inner">

                    <div class="gift-heading">
                        <span class="gift-eyebrow">WHAT'S YOUR HEART?</span>
                        <h2>어떤 마음을 전하고 싶나요?</h2>
                        <p>전하고 싶은 마음에 어울리는 선물을 찾아보세요</p>
                    </div>

                    <div class="gift-purpose-grid">
                        <button type="button" class="purpose-card" v-for="(p, i) in purposeList" :key="p"
                            @click="goGiftKit('purpose', p)">

                            <span class="select-icon">
                                {{ ['🎂', '💌', '🌟', '☁️', '💝'][i] }}
                            </span>

                            <strong>{{ p }}</strong>

                            <span class="select-description">
                                {{
                                    [
                                        '특별한 날을 기념해요',
                                        '감사의 마음을 전해요',
                                        '새로운 시작을 응원해요',
                                        '따뜻한 위로를 전해요',
                                        '소중한 마음을 전해요'
                                    ][i]
                                }}
                            </span>
                        </button>
                    </div>

                </div>
            </section>

        </main>
    </div>

    <%@ include file="/WEB-INF/common/footer.jsp" %>

    <!-- 챗봇 위젯 -->
    <jsp:include page="/chatbot/chatWidget.jsp" />

    <script>
        const app = Vue.createApp({
            data() {
                return {
                    targetList: ["가족", "연인", "친구", "동료", "나에게"],
                    purposeList: ["생일ㆍ기념일", "감사ㆍ답례", "축하ㆍ응원", "위로ㆍ격려", "마음전달"],

                    // ▼ 슬라이더 맨 앞에 보여줄 이벤트 (이 순서대로 나옵니다)
                    //   8 = 새해맞이 이벤트
                    //   이벤트의 썸네일/제목은 서버(/event/main-list.dox)에서 가져옵니다.
                    eventIds: [8],

                    // ▼ 이벤트 뒤에 이어서 보여줄 배너 이미지 (여기만 고치면 됩니다)
                    //   img  : 이미지 주소. 확장자를 빼면 png/jpg/jpeg/webp/gif 를 자동으로 찾습니다.
                    //          (webapp/assets/banner 폴더 = /assets/banner/...)
                    //   alt  : 이미지 설명
                    //   link : 클릭 시 이동할 주소 (없으면 "" 로 두세요)
                    // ※ 못 찾은 이미지는 슬라이드에서 빠지고, 콘솔(F12)에 경고가 뜹니다.
                    bannerSrc: [
                        { img: "/assets/banner/banner1", alt: "모아몽 배너 1", link: "" },
                        { img: "/assets/banner/banner2", alt: "모아몽 배너 2", link: "" },
                        { img: "/assets/banner/banner3", alt: "모아몽 배너 3", link: "" },
                        { img: "/assets/banner/banner4", alt: "모아몽 배너 4", link: "" },
                        { img: "/assets/banner/banner5", alt: "모아몽 배너 5", link: "" }
                    ],

                    slideList: [],          // 실제로 화면에 나오는 슬라이드 (이미지가 확인된 것만)
                    loaded: false,          // 이미지 확인이 끝났는지
                    current: 0,             // 현재 슬라이드 번호
                    timer: null,            // 자동 넘김 타이머
                    touchX: 0               // 터치 시작 위치
                };
            },
            methods: {

                // 이벤트 목록을 받아서 eventIds 에 있는 것만 맨 앞에, 그 뒤에 배너 이미지를 이어 붙임
                fnEventList: function () {
                    let self = this;

                    $.ajax({
                        url: "/event/main-list.dox",
                        dataType: "json",
                        type: "POST",
                        data: {},

                        success: function (data) {
                            let list = (data.result == "success" && data.list) ? data.list : [];
                            let front = [];

                            self.eventIds.forEach(function (id) {
                                let ev = list.find(function (e) { return e.eventId == id; });
                                if (ev && ev.thumbnailUrl) {
                                    front.push({
                                        img: ev.thumbnailUrl,
                                        alt: ev.eventTitle,
                                        link: "/event/view.do?eventId=" + ev.eventId,
                                        exact: true     // 서버가 준 주소는 확장자를 추측하지 않고 그대로 사용
                                    });
                                } else {
                                    console.warn("[슬라이더] 이벤트를 찾지 못했습니다. eventId:", id);
                                }
                            });

                            self.fnLoadSlides(front.concat(self.bannerSrc));
                        },
                        error: function () {
                            console.warn("[슬라이더] 이벤트 목록을 불러오지 못해 배너 이미지만 보여줍니다.");
                            self.fnLoadSlides(self.bannerSrc);
                        }
                    });
                },

                // 이미지가 실제로 있는지 확인하고, 확장자를 자동으로 찾음
                fnLoadSlides: function (srcList) {
                    let self = this;
                    let exts = ["png", "jpg", "jpeg", "webp", "gif"];
                    let hasExt = /\.(png|jpe?g|webp|gif|svg)$/i;

                    if (srcList.length == 0) {
                        self.slideList = [];
                        self.loaded = true;
                        return;
                    }

                    // 후보 주소를 차례로 시도해서 처음 성공한 주소를 돌려줌
                    function tryLoad(candidates, done) {
                        if (candidates.length == 0) { done(null); return; }
                        let im = new Image();
                        im.onload = function () { done(candidates[0]); };
                        im.onerror = function () { tryLoad(candidates.slice(1), done); };
                        im.src = candidates[0];
                    }

                    let results = new Array(srcList.length);
                    let remain = srcList.length;

                    srcList.forEach(function (s, i) {
                        let candidates = (s.exact || hasExt.test(s.img))
                            ? [s.img]
                            : exts.map(function (x) { return s.img + "." + x; });

                        tryLoad(candidates, function (found) {
                            if (found) {
                                results[i] = { img: found, alt: s.alt, link: s.link };
                            } else {
                                console.warn("[슬라이더] 이미지를 찾지 못했습니다:", s.img);
                            }
                            remain--;
                            if (remain == 0) {
                                self.slideList = results.filter(function (r) { return r; });
                                self.loaded = true;
                                self.fnPlay();
                            }
                        });
                    });
                },

                // 흐린 배경용 스타일
                fnBg: function (url) {
                    return { backgroundImage: 'url("' + url + '")' };
                },

                // 슬라이드 이동 (-1 / +1, 처음과 끝은 이어짐)
                fnMove: function (step) {
                    let self = this;
                    let len = self.slideList.length;
                    self.current = (self.current + step + len) % len;
                    self.fnPlay();      // 직접 넘기면 타이머 다시 시작
                },

                // 특정 슬라이드로 이동
                fnGo: function (i) {
                    this.current = i;
                    this.fnPlay();
                },

                // 자동 넘김 시작
                fnPlay: function () {
                    let self = this;
                    self.fnStop();
                    if (self.slideList.length < 2) return;
                    // 사용자가 '동작 줄이기'를 켜둔 경우 자동 넘김 안 함
                    if (window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
                    self.timer = setInterval(function () {
                        self.current = (self.current + 1) % self.slideList.length;
                    }, 4500);
                },

                // 자동 넘김 멈춤
                fnStop: function () {
                    if (this.timer) {
                        clearInterval(this.timer);
                        this.timer = null;
                    }
                },

                // 터치 스와이프
                fnTouchStart: function (e) {
                    this.touchX = e.changedTouches[0].clientX;
                },
                fnTouchEnd: function (e) {
                    let diff = e.changedTouches[0].clientX - this.touchX;
                    if (Math.abs(diff) > 40) this.fnMove(diff < 0 ? 1 : -1);
                },

                // 추후 선물키트 목록 페이지 URL 확정 시 아래 경로만 연결하면 됩니다.
                goGiftKit(type, value) {
                    location.href = "/package/list.do?" + type + "=" + encodeURIComponent(value);
                }
            },
            mounted() {
                this.fnEventList();
            },
            beforeUnmount() {
                this.fnStop();
            }
        });
        app.mount('#app');
    </script>
</body>

</html>