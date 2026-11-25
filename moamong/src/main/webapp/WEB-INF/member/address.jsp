<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 - 배송지 관리</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <script src="https://daumcdn.net"></script>
        <!-- 공통 레이아웃 CSS (헤더 · 사이드바 · 푸터 · 마이페이지) -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mypage/mypage.css">
    </head>
<body>
    <%@ include file="/WEB-INF/common/header.jsp"%>

    <div id="app" class="mp-wrap">
        <% request.setAttribute("activeMenu", "address"); %>
        <%@ include file="/WEB-INF/common/mypageSidebar.jsp"%>

        <main class="mp-content">
            <div class="mp-head">
                <h2>{{ showModal ? (isEdit ? '배송지 수정' : '배송지 추가') : '배송지 관리' }}</h2>
                <span class="mp-breadcrumb">
                    마이페이지 &gt; 배송지 관리<span v-if="showModal"> &gt; {{ isEdit ? '배송지 수정' : '배송지 추가' }}</span>
                </span>
            </div>

            <!-- [화면 A] 배송지 목록 -->
            <div v-if="!showModal">
                <div style="display:flex; justify-content:flex-end; margin-bottom:16px;">
                    <button class="mp-btn mp-btn-gold" @click="fnOpenAddModal">+ 새 배송지 등록</button>
                </div>

                <div v-if="list.length === 0" class="mp-card" style="text-align:center; padding:50px 0; color:#85817b;">
                    등록된 배송지가 없습니다.
                </div>

                <div v-for="item in list" :key="item.addressId" class="mp-card"
                     :style="item.isDefault == 1 ? 'border:1.5px solid #c49a62;' : ''">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                        <div>
                            <strong style="font-size:15px;">{{ item.addressName || item.recipientName }}</strong>
                            <span v-if="item.isDefault == 1"
                                  style="margin-left:8px; padding:2px 8px; border-radius:4px; font-size:11px; font-weight:700; background:#efe7da; color:#765a36;">
                                기본 배송지
                            </span>
                        </div>
                        <span style="font-size:13px; color:#85817b;">{{ item.recipientName }} | {{ item.recipientPhone }}</span>
                    </div>
                    <div style="font-size:13px; color:#5c5346; line-height:1.6;">
                        ({{ item.postalCode }}) {{ item.addressDefault }} {{ item.addressDetail }}
                    </div>
                    <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:12px;">
                        <button v-if="item.isDefault != 1" class="mp-btn" @click="fnSetDefault(item.addressId)">기본 배송지 설정</button>
                        <button class="mp-btn" @click="fnOpenEditModal(item)">수정</button>
                        <button class="mp-btn mp-btn-danger" @click="fnRemove(item.addressId)">삭제</button>
                    </div>
                </div>
            </div>
            <!-- [화면 B] 배송지 추가 / 수정 폼 -->
            <div v-else class="mp-card">
                <table style="width:100%; border-collapse:collapse; font-size:13px;">
                    <tr>
                        <th style="width:140px; text-align:left; padding:10px 0; color:#5c5346;">배송지 별칭</th>
                        <td><input class="mp-input" v-model="form.addressName" placeholder="예: 우리집, 회사"></td>
                    </tr>
                    <tr>
                        <th style="text-align:left; padding:10px 0; color:#5c5346;">수령인 *</th>
                        <td><input class="mp-input" v-model="form.recipientName" placeholder="수령인 이름"></td>
                    </tr>
                    <tr>
                        <th style="text-align:left; padding:10px 0; color:#5c5346;">연락처 *</th>
                        <td><input class="mp-input" v-model="form.recipientPhone" placeholder="010-0000-0000"></td>
                    </tr>
                    <tr>
                        <th style="text-align:left; padding:10px 0; color:#5c5346; vertical-align:top;">주소 *</th>
                        <td>
                            <div style="display:flex; gap:8px; margin-bottom:8px;">
                                <input class="mp-input" style="max-width:140px;" v-model="form.postalCode" placeholder="우편번호" readonly>
                                <button type="button" class="mp-btn" @click="fnSearchPostcode">우편번호 검색</button>
                            </div>
                            <input class="mp-input" style="margin-bottom:8px;" v-model="form.addressDefault" placeholder="기본 주소" readonly>
                            <input class="mp-input" v-model="form.addressDetail" placeholder="상세 주소 입력">
                        </td>
                    </tr>
                    <tr>
                        <th style="text-align:left; padding:10px 0; color:#5c5346;">기본 설정</th>
                        <td>
                            <label style="cursor:pointer; font-size:13px;">
                                <input type="checkbox" v-model="form.isDefaultBool"> 기본 배송지로 설정
                            </label>
                        </td>
                    </tr>
                </table>
                <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:20px;">
                    <button class="mp-btn" @click="showModal = false">취소</button>
                    <button class="mp-btn mp-btn-gold" @click="fnSave">저장</button>
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
                list: [],
                showModal: false,
                isEdit: false,
                form: {
                    addressId: null,
                    addressName: "",
                    recipientName: "",
                    recipientPhone: "",
                    postalCode: "",
                    addressDefault: "",
                    addressDetail: "",
                    isDefaultBool: false
                }
            };
        },
        methods: {
            fnGoMain() { location.href = "/"; },
            fnGoMypage() { location.href = "/member/mypage.do"; },
            fnList() {
                let self = this;
                $.ajax({
                    url: "/address/list.dox",
                    type: "POST",
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            self.list = data.list || [];
                        } else {
                            alert(data.message || "조회에 실패했습니다.");
                        }
                    }
                });
            },
            fnOpenAddModal() {
                this.isEdit = false;
                this.form = {
                    addressId: null,
                    addressName: "",
                    recipientName: "",
                    recipientPhone: "",
                    postalCode: "",
                    addressDefault: "",
                    addressDetail: "",
                    isDefaultBool: this.list.length === 0
                };
                this.showModal = true;
            },
            fnOpenEditModal(item) {
                this.isEdit = true;
                this.form = {
                    addressId: item.addressId,
                    addressName: item.addressName || "",
                    recipientName: item.recipientName,
                    recipientPhone: item.recipientPhone,
                    postalCode: item.postalCode,
                    addressDefault: item.addressDefault,
                    addressDetail: item.addressDetail || "",
                    isDefaultBool: item.isDefault == 1
                };
                this.showModal = true;
            },
            fnSearchPostcode() {
                let self = this;
                if (typeof daum !== "undefined" && daum.Postcode) {
                    new daum.Postcode({
                        oncomplete: function (data) {
                            self.form.postalCode = data.zonecode;
                            self.form.addressDefault = data.roadAddress || data.jibunAddress;
                        }
                    }).open();
                } else {
                    this.form.postalCode = "21394";
                    this.form.addressDefault = "인천 부평구 경원대로 1366";
                    alert("우편번호 API를 불러올 수 없어 기본 테스트 주소가 입력되었습니다.");
                }
            },
            fnSave() {
                let self = this;
                if (!this.form.recipientName.trim()) { alert("수령인 이름을 입력해주세요."); return; }
                if (!this.form.recipientPhone.trim()) { alert("수령인 연락처를 입력해주세요."); return; }
                if (!this.form.postalCode || !this.form.addressDefault) { alert("주소를 검색해주세요."); return; }
                
                const url = this.isEdit ? "/address/update.dox" : "/address/add.dox";
                const payload = {
                    addressId: this.form.addressId,
                    addressName: this.form.addressName.trim(),
                    recipientName: this.form.recipientName.trim(),
                    recipientPhone: this.form.recipientPhone.trim(),
                    postalCode: this.form.postalCode,
                    addressDefault: this.form.addressDefault,
                    addressDetail: this.form.addressDetail.trim(),
                    isDefault: this.form.isDefaultBool ? 1 : 0
                };
                
                $.ajax({
                    url: url,
                    type: "POST",
                    contentType: "application/json",
                    data: JSON.stringify(payload),
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            alert(data.message);
                            self.showModal = false;
                            self.fnList();
                        } else {
                            alert(data.message || "저장에 실패했습니다.");
                        }
                    }
                });
            },
            fnSetDefault(addressId) {
                let self = this;
                $.ajax({
                    url: "/address/setDefault.dox",
                    type: "POST",
                    data: { addressId: addressId },
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            self.fnList();
                        } else {
                            alert(data.message);
                        }
                    }
                });
            },
            fnRemove(addressId) {
                let self = this;
                if (!confirm("선택한 배송지를 삭제하시겠습니까?")) return;
                $.ajax({
                    url: "/address/remove.dox",
                    type: "POST",
                    data: { addressId: addressId },
                    dataType: "json",
                    success: function (data) {
                        if (data.result === "success") {
                            alert(data.message);
                            self.fnList();
                        } else {
                            alert(data.message);
                        }
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