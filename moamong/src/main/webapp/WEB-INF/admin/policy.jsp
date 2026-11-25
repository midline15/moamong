
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>운영정책 관리</title>

    <link rel="stylesheet" href="/css/admin/default.css">
    <link rel="stylesheet" href="/css/admin/list.css">

    <style>
        .policy-container {
            padding: 30px;
        }

        .policy-container h2 {
            margin-bottom: 25px;
        }

        .policy-tabs {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 25px;
        }

        .policy-tab {
            padding: 12px 18px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }

        .policy-tab.active {
            background: #333;
            color: white;
            border-color: #333;
        }

        .policy-box {
            background: white;
            border: 1px solid #ddd;
            border-radius: 5px;
            padding: 25px;
        }

        .policy-box h3 {
            margin-bottom: 10px;
        }

        .policy-description {
            color: #777;
            margin-bottom: 25px;
            font-size: 14px;
        }

        .policy-form {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .policy-form label {
            font-weight: bold;
            margin-top: 10px;
        }

        .policy-form input,
        .policy-form textarea,
        .policy-form select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 14px;
        }

        .policy-form input:disabled {
            background: #f2f2f2;
            color: #999;
            cursor: not-allowed;
        }

        .policy-form textarea {
            min-height: 300px;
            resize: vertical;
        }

        .policy-actions {
            display: flex;
            justify-content: flex-end;
            margin-top: 20px;
        }

        .policy-save,
        .hours-save {
            padding: 12px 25px;
            background: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .hours-save {
            margin-top: 20px;
        }

        .policy-save:hover,
        .hours-save:hover {
            background: #555;
        }

        .policy-message {
            margin-top: 15px;
            color: #555;
            font-size: 14px;
        }

        .hours-guide {
            margin-top: 20px;
            color: #777;
            font-size: 13px;
        }
    </style>
</head>

<body>

    <div class="admin-container">

        <!-- 왼쪽 관리자 메뉴 -->
        <aside class="sidebar">
            <h2>관리자 메뉴</h2>

            <ul>
                <li onclick="location.href='/admin/list.do'">회원 관리</li>
                <li>상품조회 / 등록</li>
                <li>주문 관리</li>
                <li>배송 관리</li>
                <li>재고 관리</li>
                <li>거래처 관리</li>
                <li>리뷰 및 문의</li>
                <li>쿠폰 관리</li>
                <li>이벤트 관리</li>
                <li class="active" onclick="location.href='/admin/policy.do'">
                    운영정책 관리
                </li>
                <li>매출 통계</li>
            </ul>
        </aside>

        <!-- 오른쪽 콘텐츠 -->
        <main class="main-content">

            <div class="policy-container">

                <h2>운영정책 관리</h2>

                <!-- 정책 메뉴 -->
                <div class="policy-tabs">

                    <button type="button" class="policy-tab active"
                        onclick="changePolicyTab(this, 'TERMS')">
                        이용약관 관리
                    </button>

                    <button type="button" class="policy-tab"
                        onclick="changePolicyTab(this, 'PRIVACY')">
                        개인정보 처리방침 관리
                    </button>

                    <button type="button" class="policy-tab"
                        onclick="changePolicyTab(this, 'MARKETING')">
                        마케팅 수신 동의 관리
                    </button>

                    <button type="button" class="policy-tab"
                        onclick="changePolicyTab(this, 'JOIN')">
                        회원가입 약관 동의 관리
                    </button>

                    <button type="button" class="policy-tab"
                        onclick="changePolicyTab(this, 'DELIVERY')">
                        배송 및 반품 정책 관리
                    </button>

                    <button type="button" class="policy-tab"
                        onclick="changePolicyTab(this, 'REFUND')">
                        교환 및 환불 정책 관리
                    </button>

                    <button type="button" class="policy-tab"
                        onclick="changePolicyTab(this, 'HOURS')">
                        고객센터 운영 시간 관리
                    </button>

                </div>

                <!-- 정책 내용 -->
                <div class="policy-box">

                    <h3 id="policyTitle">이용약관 관리</h3>

                    <p class="policy-description" id="policyDescription">
                        쇼핑몰 이용약관 내용을 관리합니다.
                    </p>

                    <!-- 일반 정책 입력 영역 -->
                    <div id="normalPolicy">

                        <div class="policy-form">

                            <label for="policyName">정책 제목</label>
                            <input type="text" id="policyName"
                                placeholder="정책 제목을 입력하세요.">

                            <label for="policyContent">정책 내용</label>
                            <textarea id="policyContent"
                                placeholder="정책 내용을 입력하세요."></textarea>

                            <div id="policyOptions">

                                <label for="isRequired">필수 동의 여부</label>
                                <select id="isRequired">
                                    <option value="Y">필수</option>
                                    <option value="N">선택</option>
                                </select>

                                <label for="isActive">사용 여부</label>
                                <select id="isActive">
                                    <option value="Y">사용</option>
                                    <option value="N">미사용</option>
                                </select>

                            </div>

                        </div>

                        <div class="policy-actions">
                            <button type="button" class="policy-save"
                                onclick="savePolicy()">
                                저장
                            </button>
                        </div>

                        <p id="policyMessage" class="policy-message"></p>

                    </div>

                    <!-- 고객센터 운영 시간 영역 -->
                    <div id="hoursPolicy" style="display:none;">

                        <h4 class="hours-edit-title">운영 시간 수정</h4>

                        <div class="policy-form">

                            <label for="serviceDay">운영 요일</label>
                            <select id="serviceDay" onchange="loadSelectedHours()">
                                <option value="MON">월요일</option>
                                <option value="TUE">화요일</option>
                                <option value="WED">수요일</option>
                                <option value="THU">목요일</option>
                                <option value="FRI">금요일</option>
                                <option value="SAT">토요일</option>
                                <option value="SUN">일요일</option>
                            </select>

                            <label for="startTime">시작 시간</label>
                            <input type="time" id="startTime">

                            <label for="endTime">종료 시간</label>
                            <input type="time" id="endTime">

                            <label for="isClosed">휴무 여부</label>
                            <select id="isClosed" onchange="toggleHoursInput()">
                                <option value="N">운영</option>
                                <option value="Y">휴무</option>
                            </select>

                            <button type="button" class="hours-save"
                                onclick="saveHours()">
                                운영 시간 저장
                            </button>

                        </div>

                        <p class="hours-guide">
                            요일을 선택한 후 운영 시간과 휴무 여부를 수정할 수 있습니다.
                        </p>

                    </div>

                </div>

            </div>

        </main>

    </div>

    <script>

        // =====================================
        // 정책 종류별 설명
        // =====================================

        const policyInfo = {
            TERMS: [
                '이용약관 관리',
                '쇼핑몰 이용약관 내용을 관리합니다.'
            ],
            PRIVACY: [
                '개인정보 처리방침 관리',
                '회원 개인정보 수집 및 이용에 관한 내용을 관리합니다.'
            ],
            MARKETING: [
                '마케팅 수신 동의 관리',
                '마케팅 정보 수신 동의 내용을 관리합니다.'
            ],
            JOIN: [
                '회원가입 약관 동의 관리',
                '회원가입 시 동의받는 약관 내용을 관리합니다.'
            ],
            DELIVERY: [
                '배송 및 반품 정책 관리',
                '배송 및 반품 관련 정책 내용을 관리합니다.'
            ],
            REFUND: [
                '교환 및 환불 정책 관리',
                '교환 및 환불 관련 정책 내용을 관리합니다.'
            ],
            HOURS: [
                '고객센터 운영 시간 관리',
                '고객센터 운영 요일과 시간을 관리합니다.'
            ]
        };

        // DB에서 불러온 정책 목록
        let policyList = [];

        // 현재 선택된 정책
        let currentPolicy = null;

        // 고객센터 운영 시간 목록
        let serviceHoursList = [];

        // 요일 이름
        const dayNames = {
            MON: '월요일',
            TUE: '화요일',
            WED: '수요일',
            THU: '목요일',
            FRI: '금요일',
            SAT: '토요일',
            SUN: '일요일'
        };


        // =====================================
        // 페이지 초기 실행
        // =====================================

        window.onload = function () {
            loadPolicyList();
        };


        // =====================================
        // 정책 목록 조회
        // =====================================

        function loadPolicyList() {

            fetch('/admin/policyList.dox', {
                method: 'POST'
            })
                .then(response => response.json())
                .then(data => {

                    if (data.result === 'success') {

                        policyList = data.list || [];

                        selectPolicy('TERMS');

                    } else {

                        alert('정책 목록 조회 실패: ' + data.message);

                    }

                })
                .catch(error => {

                    console.error(error);
                    alert('정책 목록을 불러오는 중 오류가 발생했습니다.');

                });
        }


        // =====================================
        // 정책 메뉴 클릭
        // =====================================

        function changePolicyTab(button, type) {

            document.querySelectorAll('.policy-tab').forEach(function (tab) {
                tab.classList.remove('active');
            });

            button.classList.add('active');

            document.getElementById('policyTitle').textContent =
                policyInfo[type][0];

            document.getElementById('policyDescription').textContent =
                policyInfo[type][1];

            document.getElementById('policyMessage').textContent = '';

            if (type === 'HOURS') {

                document.getElementById('normalPolicy').style.display = 'none';
                document.getElementById('hoursPolicy').style.display = 'block';

                currentPolicy = null;

                loadCustomerServiceHours();

            } else {

                document.getElementById('normalPolicy').style.display = 'block';
                document.getElementById('hoursPolicy').style.display = 'none';

                // 배송 및 반품, 교환 및 환불에서는 두 설정 항목 숨김
                document.getElementById('policyOptions').style.display =
                    (type === 'DELIVERY' || type === 'REFUND') ? 'none' : 'block';

                selectPolicy(type);

            }
        }


        // =====================================
        // 정책 상세 조회
        // =====================================

        function selectPolicy(type) {

            const policy = policyList.find(function (item) {
                return item.policyType === type;
            });

            if (!policy) {

                currentPolicy = null;

                document.getElementById('policyName').value = '';
                document.getElementById('policyContent').value = '';

                document.getElementById('policyMessage').textContent =
                    '해당 정책 데이터가 없습니다.';

                return;
            }

            fetch('/admin/policyDetail.dox', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: new URLSearchParams({
                    policyId: policy.policyId
                })
            })
                .then(response => response.json())
                .then(data => {

                    if (data.result === 'success') {

                        currentPolicy = data.policyInfo;

                        document.getElementById('policyName').value =
                            currentPolicy.title || '';

                        document.getElementById('policyContent').value =
                            currentPolicy.content || '';

                        document.getElementById('isRequired').value =
                            currentPolicy.isRequired || 'Y';

                        document.getElementById('isActive').value =
                            currentPolicy.isActive || 'Y';

                        document.getElementById('policyMessage').textContent = '';

                    } else {

                        alert(data.message || '정책 상세 조회에 실패했습니다.');

                    }

                })
                .catch(error => {

                    console.error(error);
                    alert('정책 상세 조회 중 오류가 발생했습니다.');

                });
        }


        // =====================================
        // 정책 수정 및 저장
        // =====================================

        function savePolicy() {

            if (!currentPolicy) {
                alert('저장할 정책이 없습니다.');
                return;
            }

            const title = document.getElementById('policyName').value.trim();
            const content = document.getElementById('policyContent').value;

            if (title === '') {
                alert('정책 제목을 입력해 주세요.');
                return;
            }

            const params = new URLSearchParams({
                policyId: currentPolicy.policyId,
                title: title,
                content: content,
                isRequired: document.getElementById('isRequired').value,
                isActive: document.getElementById('isActive').value
            });

            fetch('/admin/policyUpdate.dox', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params
            })
                .then(response => response.json())
                .then(data => {

                    if (data.result === 'success') {

                        alert('정책이 저장되었습니다.');

                        currentPolicy.title = title;
                        currentPolicy.content = content;

                    } else {

                        alert(data.message || '정책 저장에 실패했습니다.');

                    }

                })
                .catch(error => {

                    console.error(error);
                    alert('정책 저장 중 오류가 발생했습니다.');

                });
        }


        // =====================================
        // 고객센터 운영 시간 조회
        // =====================================

        function loadCustomerServiceHours() {

            fetch('/admin/customerServiceHoursList.dox', {
                method: 'POST'
            })
                .then(response => response.json())
                .then(data => {

                    if (data.result === 'success') {

                        serviceHoursList = data.list || [];

                        console.log('운영 시간 조회 데이터:', serviceHoursList);

                        // 선택한 요일의 운영 시간 표시
                        loadSelectedHours();

                    } else {

                        alert('운영 시간 조회 실패: ' + data.message);

                    }

                })
                .catch(error => {

                    console.error(error);
                    alert('운영 시간을 불러오지 못했습니다.');

                });
        }


        // =====================================
        // 선택한 요일의 운영 시간 표시
        // =====================================

        function loadSelectedHours() {

            const day = document.getElementById('serviceDay').value;

            const info = serviceHoursList.find(function (item) {
                return item.dayOfWeek === day;
            });

            document.getElementById('startTime').value =
                info && info.startTime
                    ? String(info.startTime).substring(0, 5)
                    : '';

            document.getElementById('endTime').value =
                info && info.endTime
                    ? String(info.endTime).substring(0, 5)
                    : '';

            document.getElementById('isClosed').value =
                info ? info.isClosed : 'N';

            // 휴무 여부에 따라 시간 입력 상태 변경
            toggleHoursInput();
        }


        // =====================================
        // 휴무 여부에 따른 시간 입력 제어
        // =====================================

        function toggleHoursInput() {

            const isClosed = document.getElementById('isClosed').value;

            const startTime = document.getElementById('startTime');
            const endTime = document.getElementById('endTime');

            startTime.disabled = isClosed === 'Y';
            endTime.disabled = isClosed === 'Y';

            if (isClosed === 'Y') {
                startTime.value = '';
                endTime.value = '';
            }
        }


        // =====================================
        // 고객센터 운영 시간 저장
        // =====================================

        function saveHours() {

            const day = document.getElementById('serviceDay').value;
            const startTime = document.getElementById('startTime').value;
            const endTime = document.getElementById('endTime').value;
            const isClosed = document.getElementById('isClosed').value;

            // 운영일 시간 입력 검사
            if (isClosed === 'N' && (!startTime || !endTime)) {
                alert('운영 시작 시간과 종료 시간을 입력해 주세요.');
                return;
            }

            // 종료 시간이 시작 시간보다 늦은지 검사
            if (isClosed === 'N' && startTime >= endTime) {
                alert('종료 시간은 시작 시간보다 늦어야 합니다.');
                return;
            }

            const params = new URLSearchParams({
                dayOfWeek: day,
                startTime: isClosed === 'Y' ? '' : startTime,
                endTime: isClosed === 'Y' ? '' : endTime,
                isClosed: isClosed
            });

            fetch('/admin/customerServiceHoursSave.dox', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params
            })
                .then(response => response.json())
                .then(data => {

                    if (data.result === 'success') {

                        alert(dayNames[day] + ' 운영 시간이 저장되었습니다.');

                        // DB에 저장된 최신 목록 다시 조회
                        loadCustomerServiceHours();

                    } else {

                        alert(data.message || '운영 시간 저장에 실패했습니다.');

                    }

                })
                .catch(error => {

                    console.error(error);
                    alert('운영 시간 저장 중 오류가 발생했습니다.');

                });
        }

    </script>

</body>

</html>
