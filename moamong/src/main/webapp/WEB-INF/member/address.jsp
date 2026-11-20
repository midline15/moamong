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
        <style>
            body {
                font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;
                background-color: #f8f9fa;
                margin: 0;
                padding: 30px 16px;
                color: #222;
            }
            .container {
                max-width: 820px;
                margin: 0 auto;
                background: #fff;
                border-radius: 12px;
                padding: 28px;
                box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
            }
            .top-nav {
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-bottom: 2px solid #222;
                padding-bottom: 14px;
                margin-bottom: 20px;
            }
            .top-nav h2 { margin: 0; font-size: 22px; }
            .btn-group { display: flex; gap: 8px; }
            .btn {
                padding: 7px 14px;
                border: 1px solid #ccc;
                background: #fff;
                border-radius: 6px;
                cursor: pointer;
                font-size: 13px;
                font-weight: 600;
                color: #222;
            }
            .btn:hover { background: #f1f3f5; }
            .btn-primary { background: #222; color: #fff; border-color: #222; }
            .btn-primary:hover { background: #444; }
            .btn-danger { border-color: #ffa8a8; color: #c92a2a; }
            .addr-card {
                border: 1px solid #e9ecef;
                border-radius: 10px;
                padding: 18px 20px;
                margin-bottom: 12px;
                background: #fff;
            }
            .addr-card.is-default { border: 2px solid #222; background: #fcfcfc; }
            .addr-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
            .badge-default {
                display: inline-block; font-size: 11px; font-weight: 700;
                padding: 2px 8px; border-radius: 4px; background: #222; color: #fff; margin-left: 6px;
            }
            .addr-body { font-size: 14px; color: #495057; line-height: 1.6; }
            .addr-actions { display: flex; gap: 8px; margin-top: 12px; }
            .empty-box { text-align: center; padding: 60px 0; color: #888; }
            .modal-backdrop {
                position: fixed; inset: 0; background: rgba(0, 0, 0, 0.45);
                display: flex; align-items: center; justify-content: center; z-index: 999;
            }
            .modal-box {
                background: #fff; width: 92%; max-width: 460px;
                border-radius: 12px; padding: 24px; box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
            }
            .modal-title { font-size: 18px; font-weight: 700; margin-bottom: 16px; border-bottom: 1px solid #eee; padding-bottom: 10px; }
            .form-group { margin-bottom: 12px; }
            .form-group label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 5px; }
            .form-control { width: 100%; box-sizing: border-box; padding: 9px 11px; border: 1px solid #ccc; border-radius: 6px; font-size: 14px; }
            .postal-row { display: flex; gap: 8px; margin-bottom: 6px; }
            .postal-row input { flex: 1; background: #f8f9fa; }
            .modal-footer { display: flex; justify-content: flex-end; gap: 8px; margin-top: 18px; }
        </style>
    </head>
    <body>
        <div id="app" class="container">
            <div class="top-nav">
                <h2>📍 배송지 관리</h2>
                <div class="btn-group">
                    <button class="btn" @click="fnGoMypage">마이페이지</button>
                    <button class="btn" @click="fnGoMain">메인으로</button>
                    <button class="btn btn-primary" @click="fnOpenAddModal">+ 새 배송지 등록</button>
                </div>
            </div>

            <div v-if="list.length === 0" class="empty-box">
                <p style="margin-bottom: 14px;">등록된 배송지가 없습니다.</p>
                <button class="btn btn-primary" @click="fnOpenAddModal">첫 배송지 등록하기</button>
            </div>

            <div v-for="item in list" :key="item.addressId" class="addr-card" :class="{ 'is-default': item.isDefault == 1 }">
                <div class="addr-header">
                    <div>
                        <strong style="font-size: 16px;">{{ item.addressName || item.recipientName }}</strong>
                        <span v-if="item.isDefault == 1" class="badge-default">기본 배송지</span>
                    </div>
                    <span style="font-size: 13px; color: #666;">{{ item.recipientName }} | {{ item.recipientPhone }}</span>
                </div>
                <div class="addr-body">
                    <div>({{ item.postalCode }}) {{ item.addressDefault }}</div>
                    <div v-if="item.addressDetail">{{ item.addressDetail }}</div>
                </div>
                <div class="addr-actions">
                    <button v-if="item.isDefault != 1" class="btn" @click="fnSetDefault(item.addressId)">기본 배송지 설정</button>
                    <button class="btn" @click="fnOpenEditModal(item)">수정</button>
                    <button class="btn btn-danger" @click="fnRemove(item.addressId)">삭제</button>
                </div>
            </div>

            <div v-if="showModal" class="modal-backdrop" @click.self="showModal = false">
                <div class="modal-box">
                    <div class="modal-title">{{ isEdit ? '배송지 수정' : '새 배송지 등록' }}</div>
                    <div class="form-group">
                        <label>배송지 별칭 (선택)</label>
                        <input type="text" class="form-control" v-model="form.addressName" placeholder="예: 우리집, 회사">
                    </div>
                    <div class="form-group">
                        <label>수령인 이름 *</label>
                        <input type="text" class="form-control" v-model="form.recipientName" placeholder="수령인 성함">
                    </div>
                    <div class="form-group">
                        <label>수령인 연락처 *</label>
                        <input type="text" class="form-control" v-model="form.recipientPhone" placeholder="010-0000-0000">
                    </div>
                    <div class="form-group">
                        <label>주소 *</label>
                        <div class="postal-row">
                            <input type="text" class="form-control" v-model="form.postalCode" placeholder="우편번호" readonly>
                            <button type="button" class="btn" @click="fnSearchPostcode">우편번호 검색</button>
                        </div>
                        <input type="text" class="form-control" v-model="form.addressDefault" placeholder="기본 주소" readonly style="background:#f8f9fa; margin-bottom:6px;">
                        <input type="text" class="form-control" v-model="form.addressDetail" placeholder="상세 주소 입력">
                    </div>
                    <div style="margin-top: 8px; font-size: 13px;">
                        <label style="cursor:pointer;">
                            <input type="checkbox" v-model="form.isDefaultBool"> 기본 배송지로 설정
                        </label>
                    </div>
                    <div class="modal-footer">
                        <button class="btn" @click="showModal = false">취소</button>
                        <button class="btn btn-primary" @click="fnSave">저장</button>
                    </div>
                </div>
            </div>
        </div>
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