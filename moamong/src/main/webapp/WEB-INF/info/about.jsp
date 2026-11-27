<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>모아몽 - 회사소개</title>
    <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
    <script src="/js/page-change.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/info/info.css">
</head>
<body>
    <%@ include file="/WEB-INF/common/header.jsp"%>

    <main class="info-wrap ab-wrap">

        <nav class="info-tabs">
            <a href="/info/about.do" class="info-tab active">회사소개</a>
            <a href="/info/terms.do" class="info-tab">이용약관</a>
            <a href="/info/privacy.do" class="info-tab">개인정보처리방침</a>
            <a href="/info/guide.do" class="info-tab">이용방법</a>
            <a href="/info/shipping.do" class="info-tab">배송·반품 안내</a>
        </nav>

        <!-- ① 히어로 -->
        <section class="ab-hero ab-reveal">
            <div class="ab-hero-text">
                <span class="ab-eyebrow">ABOUT MOAMONG</span>
                <h2 class="ab-hero-title">
                    마음을 모으고,<br>
                    <em>선물의 가치</em>를 더합니다.
                </h2>
                <p class="ab-hero-desc">
                    선물은 물건이 아니라 마음이라고 믿습니다.<br>
                    모아몽은 고민하는 시간부터 건네는 순간의 설렘까지,<br>
                    소중한 사람에게 닿는 가장 따뜻한 길을 함께 만들어 갑니다.
                </p>
                <div class="ab-hero-cta">
                    <a href="/" class="ab-btn ab-btn-gold">선물 구경하기</a>
                    <a href="#ab-story" class="ab-btn ab-btn-line">브랜드 스토리</a>
                </div>
            </div>
            <div class="ab-hero-visual">
                <div class="ab-hero-circle"></div>
                <img src="${pageContext.request.contextPath}/assets/char/char1.png" alt="모아몽 캐릭터"
                     onerror="this.style.display='none'">
                <span class="ab-float ab-float-1">♡</span>
                <span class="ab-float ab-float-2">✦</span>
                <span class="ab-float ab-float-3">♡</span>
            </div>
        </section>

        <!-- ② 브랜드 스토리 -->
        <section class="ab-section ab-reveal" id="ab-story">
            <div class="ab-section-head">
                <span class="ab-label">BRAND STORY</span>
                <h3>모아몽이 시작된 이야기</h3>
            </div>
            <div class="ab-story">
                <div class="ab-story-quote">
                    “무엇을 줄까”보다<br>
                    “어떤 마음을 전할까”를<br>
                    먼저 묻는 가게.
                </div>
                <div class="ab-story-body">
                    <p>
                        누군가의 생일, 기념일, 혹은 아무 날도 아닌 평범한 하루.
                        우리는 소중한 사람에게 무언가를 건네고 싶어 한참을 고민합니다.
                        무엇을 좋아할지, 부담스럽지는 않을지, 내 마음이 제대로 전해질지
                        망설이는 그 시간이야말로 선물의 가장 아름다운 부분이라고 모아몽은 생각했습니다.
                    </p>
                    <p>
                        하지만 현실의 선물 고민은 종종 지치는 일이 되곤 합니다.
                        수많은 상품 사이를 헤매고, 포장과 카드를 따로 챙기고,
                        배송 일정까지 신경 써야 하니까요.
                        모아몽은 그 번거로움을 덜어내고, 고민의 시간을 ‘설렘’으로 바꾸기 위해 시작되었습니다.
                    </p>
                    <p>
                        이름 속에는 두 가지 바람이 담겨 있습니다.
                        <strong>모아(MOA)</strong>는 흩어져 있는 마음과 좋은 물건을 한곳에 모은다는 뜻,
                        <strong>몽(MONG)</strong>은 선물을 주고받는 순간 피어나는 몽글몽글한 감정을 뜻합니다.
                        받는 사람의 취향과 주는 사람의 진심이 한 상자 안에서 만나도록,
                        우리는 오늘도 하나하나 정성껏 고르고 담습니다.
                    </p>
                </div>
            </div>
        </section>

        <!-- ③ MISSION / VISION / VALUE -->
        <section class="ab-section ab-reveal">
            <div class="ab-section-head">
                <span class="ab-label">OUR PHILOSOPHY</span>
                <h3>모아몽이 지향하는 것</h3>
            </div>
            <div class="ab-triple">
                <article class="ab-triple-card">
                    <span class="ab-triple-no">MISSION</span>
                    <h4>마음이 닿는 선물을<br>누구나 쉽게</h4>
                    <p>
                        선물 고르기가 부담이 아닌 즐거움이 되도록,
                        받는 사람과 상황에 꼭 맞는 구성을 쉽고 따뜻하게 제안합니다.
                    </p>
                </article>
                <article class="ab-triple-card">
                    <span class="ab-triple-no">VISION</span>
                    <h4>선물이 곧 대화가 되는<br>세상</h4>
                    <p>
                        상자를 여는 순간 한마디 말보다 깊은 마음이 전해지는 경험.
                        선물을 매개로 사람과 사람이 더 가까워지는 문화를 만들어 갑니다.
                    </p>
                </article>
                <article class="ab-triple-card">
                    <span class="ab-triple-no">VALUE</span>
                    <h4>정성, 다정함,<br>그리고 신뢰</h4>
                    <p>
                        작은 포장 하나, 한 줄의 문구, 약속한 배송 일정까지.
                        눈에 잘 띄지 않는 부분에 더 정성을 쏟는 것이 모아몽의 기준입니다.
                    </p>
                </article>
            </div>
        </section>

        <!-- ④ 서비스 소개 -->
        <section class="ab-section ab-reveal">
            <div class="ab-section-head">
                <span class="ab-label">WHAT WE DO</span>
                <h3>모아몽이 만드는 세 가지 경험</h3>
                <p>고르는 순간부터 전하는 순간까지, 선물의 모든 여정을 설계합니다.</p>
            </div>

            <div class="ab-service">
                <div class="ab-service-no">01<small>CURATION</small></div>
                <div class="ab-service-text">
                    <h4>대상 · 목적별 큐레이션</h4>
                    <p>
                        연인, 부모님, 친구, 동료. 받는 사람이 누구인지, 어떤 날인지에 따라
                        선물의 온도는 달라져야 합니다. 모아몽은 대상과 기념일의 성격에 맞춰
                        고민 끝에 고른 선물 구성을 제안합니다. 예산을 알려 주면 그 안에서
                        가장 만족스러운 조합을 찾아 드립니다.
                    </p>
                </div>
            </div>
            <div class="ab-service ab-service-rev">
                <div class="ab-service-no">02<small>CUSTOM PACKAGE</small></div>
                <div class="ab-service-text">
                    <h4>세상에 하나뿐인 커스텀 패키지</h4>
                    <p>
                        원하는 구성품을 고르고, 어울리는 포장을 선택하고,
                        마음을 적은 메시지 카드까지 한 번에 완성하세요.
                        여러 곳에서 따로 준비하던 번거로움은 줄이고,
                        선물에 담기는 개성과 진심은 더 짙게 만들었습니다.
                    </p>
                </div>
            </div>
            <div class="ab-service">
                <div class="ab-service-no">03<small>COMMUNITY</small></div>
                <div class="ab-service-text">
                    <h4>STORY, 마음을 나누는 커뮤니티</h4>
                    <p>
                        실제로 선물을 주고받은 이야기, 감성 가득한 일상의 기록을 나누는 공간입니다.
                        누군가의 후기가 또 다른 누군가의 선물 아이디어가 되고,
                        댓글 하나가 따뜻한 위로가 되는 곳. 모아몽은 거래를 넘어
                        마음이 오가는 이야기를 지향합니다.
                    </p>
                </div>
            </div>
        </section>

        <!-- ⑤ 걸어갈 길 -->
        <section class="ab-section ab-reveal">
            <div class="ab-section-head">
                <span class="ab-label">OUR JOURNEY</span>
                <h3>모아몽이 걸어가는 길</h3>
            </div>
            <ol class="ab-timeline">
                <li>
                    <span class="ab-dot"></span>
                    <div>
                        <h5>시작 · 하나의 질문에서</h5>
                        <p>“선물 고르는 시간이 조금 더 따뜻할 수는 없을까?” 그 질문에서 모아몽이 출발했습니다.</p>
                    </div>
                </li>
                <li>
                    <span class="ab-dot"></span>
                    <div>
                        <h5>성장 · 마음을 담는 구성으로</h5>
                        <p>단품 판매를 넘어 포장, 메시지 카드, 맞춤 패키지까지 선물의 전 과정을 하나로 잇습니다.</p>
                    </div>
                </li>
                <li>
                    <span class="ab-dot"></span>
                    <div>
                        <h5>지금 · 함께 만드는 이야기</h5>
                        <p>STORY 커뮤니티와 AI 컨시어지 ‘모리’를 통해 고객과 더 가까이에서 대화하고 있습니다.</p>
                    </div>
                </li>
                <li>
                    <span class="ab-dot ab-dot-next"></span>
                    <div>
                        <h5>앞으로 · 더 다정한 선물 문화</h5>
                        <p>더 많은 순간, 더 많은 마음이 모아몽을 통해 전해지도록 계속 배우고 넓혀 가겠습니다.</p>
                    </div>
                </li>
            </ol>
        </section>

        <!-- ⑥ 약속 -->
        <section class="ab-section ab-reveal">
            <div class="ab-section-head">
                <span class="ab-label">OUR PROMISE</span>
                <h3>모아몽이 드리는 네 가지 약속</h3>
            </div>
            <div class="ab-promise">
                <div class="ab-promise-item">
                    <span class="ab-promise-icon">🎁</span>
                    <h4>정성스러운 포장</h4>
                    <p>상자를 여는 순간까지 선물의 일부라는 마음으로 하나하나 정성껏 포장합니다.</p>
                </div>
                <div class="ab-promise-item">
                    <span class="ab-promise-icon">💌</span>
                    <h4>마음을 담는 메시지</h4>
                    <p>전하고 싶은 말을 메시지 카드로 함께 보내 선물에 진심을 더합니다.</p>
                </div>
                <div class="ab-promise-item">
                    <span class="ab-promise-icon">🚚</span>
                    <h4>투명한 배송 안내</h4>
                    <p>30,000원 이상 구매 시 무료배송, 주문부터 도착까지 실시간으로 확인하실 수 있습니다.</p>
                </div>
                <div class="ab-promise-item">
                    <span class="ab-promise-icon">🤝</span>
                    <h4>믿을 수 있는 사후 케어</h4>
                    <p>배송 완료 후 7일 이내 반품 신청이 가능하며, 궁금한 점은 언제든 문의해 주세요.</p>
                </div>
            </div>
        </section>

        <!-- ⑦ 회사 정보 -->
        <section class="ab-section ab-reveal">
            <div class="ab-section-head">
                <span class="ab-label">COMPANY INFO</span>
                <h3>회사 정보</h3>
            </div>
            <!-- ※ 아래 값은 예시입니다. 실제 사업자 정보로 수정해 주세요. -->
            <table class="info-table ab-table">
                <tr><th>상호명</th><td>모아몽 (MOAMONG)</td></tr>
                <tr><th>사업 분야</th><td>선물 큐레이션 및 커스텀 패키지 온라인 스토어 운영</td></tr>
                <tr><th>사업자등록번호</th><td>000-00-00000</td></tr>
                <tr><th>소재지</th><td>서울특별시 OO구 OO동</td></tr>
                <tr><th>고객센터</th><td>1588-0000 · 이용 시간은 고객센터 안내를 확인해 주세요.</td></tr>
                <tr><th>이메일</th><td>help@moamong.com</td></tr>
            </table>
        </section>

        <!-- ⑧ 마무리 CTA -->
        <section class="ab-closing ab-reveal">
            <h3>오늘, 누구에게 마음을 전하고 싶으신가요?</h3>
            <p>모아몽이 가장 어울리는 선물을 함께 고민해 드릴게요.</p>
            <div class="ab-hero-cta ab-center">
                <a href="/" class="ab-btn ab-btn-gold">선물 고르러 가기</a>
                <a href="/community/list.do" class="ab-btn ab-btn-line">STORY 구경하기</a>
            </div>
        </section>

    </main>

    <%@ include file="/WEB-INF/common/footer.jsp"%>

    <script>
        // 스크롤하면 부드럽게 나타나는 효과 (JS가 안 돼도 내용은 그대로 보입니다)
        (function () {
            var items = document.querySelectorAll('.ab-reveal');
            if (!('IntersectionObserver' in window)) return;
            document.documentElement.classList.add('ab-js');
            var io = new IntersectionObserver(function (entries) {
                entries.forEach(function (e) {
                    if (e.isIntersecting) {
                        e.target.classList.add('ab-in');
                        io.unobserve(e.target);
                    }
                });
            }, { threshold: 0.12 });
            items.forEach(function (el) { io.observe(el); });
        })();
    </script>
</body>
</html>
