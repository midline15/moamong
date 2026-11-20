<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>모아몽 - 찜 목록</title>
    <script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
    <script src="/js/page-change.js"></script>
   <style>
        body {
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 30px 16px;
            color: #222;
        }
        .wish-container {
            max-width: 960px;
            margin: 0 auto;
            background: #fff;
            border-radius: 12px;
            padding: 28px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
        }
        .header-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .header-bar h2 { margin: 0; font-size: 24px; }
        .toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 2px solid #222;
            margin-bottom: 12px;
        }
        table { width: 100%; border-collapse: collapse; }
        th, td {
            padding: 14px 10px;
            border-bottom: 1px solid #eee;
            text-align: center;
            vertical-align: middle;
        }
        th { background-color: #fafafa; font-weight: 600; font-size: 14px; color: #555; }
        .item-info {
            display: flex;
            align-items: center;
            justify-content: flex-start;
            gap: 14px;
            text-align: left;
            min-width: 240px;
            word-break: keep-all;
        }
        .thumb {
            width: 68px; height: 68px; border-radius: 8px;
            object-fit: cover; background: #f1f3f5; border: 1px solid #e9ecef; flex-shrink: 0;
        }
        .badge {
            display: inline-block; font-size: 11px; font-weight: 700;
            padding: 2px 7px; border-radius: 4px; margin-bottom: 4px;
        }
        .badge-product { background: #e7f5ff; color: #1971c2; }
        .badge-package { background: #fff3bf; color: #e67700; }
        .badge-soldout { background: #ffe3e3; color: #c92a2a; margin-left: 4px; }
        .btn {
            padding: 6px 12px; border: 1px solid #ccc; background: #fff;
            border-radius: 6px; cursor: pointer; font-size: 13px;
        }
        .btn:hover { background: #f1f3f5; }
        .btn-dark { background: #222; color: #fff; border-color: #222; }
        .btn-dark:hover { background: #444; }
        .btn-danger { border-color: #ffa8a8; color: #c92a2a; }
        .empty-box { text-align: center; padding: 60px 0; color: #888; }
        .soldout-row { opacity: 0.6; background-color: #fafafa; }
        .test-bar {
            margin-top: 30px; padding: 14px; background: #fff9db;
            border: 1px dashed #fcc419; border-radius: 8px; font-size: 13px;
        }
    </style>
</head>

<body>
    <div id="app" class="wish-container">
        <div class="header-bar">
            <h2>❤️ 찜 목록</h2>
            <div style="display:flex; gap:8px;">
                <button class="btn" @click="fnGoCart">장바구니</button>
                <button class="btn" @click="fnGoMypage">마이페이지</button>
                <button class="btn" @click="fnGoMain">메인으로</button>
            </div>
        </div>

        <div class="toolbar">
            <label style="cursor:pointer;">
                <input type="checkbox" v-model="isAllChecked" @change="fnToggleAll">
                전체 선택 ({{ selectedIds.length }} / {{ wishList.length }})
            </label>
            <div style="display:flex; gap:8px;">
                <button class="btn" @click="fnRemoveSelected">선택 삭제</button>
                <button class="btn btn-danger" @click="fnDeleteAll">전체 비우기</button>
            </div>
        </div>

        <div v-if="wishList.length === 0" class="empty-box">
            찜한 상품이 없습니다.
        </div>

        <table v-else>
            <thead>
                <tr>
                    <th style="width:40px;">선택</th>
                    <th>상품 / 패키지 정보</th>
                    <th style="width:120px;">가격</th>
                    <th style="width:140px;">찜한 날짜</th>
                    <th style="width:170px;">관리</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="item in wishList" :key="item.wishlistId" :class="{ 'soldout-row': !item.available }">
                    <td>
                        <input type="checkbox" :value="item.wishlistId" v-model="selectedIds">
                    </td>
                    <td>
                        <div class="item-info">
                            <img class="thumb" :src="item.thumbnailUrl || defaultThumb" @error="fnImgError" alt="상품 이미지">
                            <div>
                                <div>
                                    <span v-if="item.itemType === 'PRODUCT'" class="badge badge-product">단품</span>
                                    <span v-else class="badge badge-package">
                                        패키지{{ item.packageGrade ? ' (' + item.packageGrade + ')' : '' }}
                                    </span>
                                    <span v-if="!item.available" class="badge badge-soldout">품절/구매불가</span>
                                </div>
                                <strong style="font-size:15px;">{{ item.itemName || '판매 종료된 상품입니다' }}</strong>
                            </div>
                        </div>
                    </td>
                    <td><strong>{{ Number(item.price || 0).toLocaleString() }}원</strong></td>
                    <td style="font-size:12px; color:#666;">{{ item.createdAt }}</td>
                    <td>
                        <div style="display:flex; gap:6px; justify-content:center;">
                            <button class="btn btn-dark"
                                    @click="fnMoveToCart(item)"
                                    :disabled="!item.available">
                                장바구니
                            </button>
                            <button class="btn btn-danger" @click="fnRemove(item.wishlistId)">삭제</button>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>

        <!-- 개발 테스트용 찜 토글 바 -->
        <div class="test-bar">
            <strong>🔧 개발 테스트용 찜 토글 (누르면 등록 / 다시 누르면 해제):</strong>
            <button class="btn" style="margin-left:8px;" @click="fnTestToggle(1)">❤️ 스카프(1번)</button>
            <button class="btn" style="margin-left:4px;" @click="fnTestToggle(2)">❤️ 실크스카프(2번)</button>
            <button class="btn" style="margin-left:4px;" @click="fnTestToggle(3)">❤️ 패턴양말(3번)</button>
        </div>
    </div>
</body>

</html>

    <script>
        const app = Vue.createApp({
            data() {
                return {
                    wishList: [],
                    selectedIds: [],
                    defaultThumb: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMDAiIGhlaWdodD0iMTAwIj48cmVjdCB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgZmlsbD0iI2YxZjNmNSIvPjx0ZXh0IHg9IjUwJSIgeT0iNTQlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmaWxsPSIjODY4ZTk2IiBmb250LWZhbWlseT0ic2Fucy1zZXJpZiIgZm9udC1zaXplPSIxMiI+TU9BTU9ORzwvdGV4dD48L3N2Zz4="
                };
            },
            computed: {
                isAllChecked: {
                    get() {
                        return this.wishList.length > 0 && this.selectedIds.length === this.wishList.length;
                    },
                    set(val) {}
                }
            },
            methods: {
                fnGoCart() { location.href = "/cart/list.do"; },
                fnGoMypage() { location.href = "/member/mypage.do"; },
                fnGoMain() { location.href = "/"; },
                fnImgError(e) { e.target.src = this.defaultThumb; },
                fnList() {
                    let self = this;
                    $.ajax({
                        url: "/wishlist/list.dox",
                        type: "POST",
                        dataType: "json",
                        success: function (data) {
                            if (data.result === "success") {
                                self.wishList = data.list;
                                self.selectedIds = [];
                            } else {
                                alert(data.message || "찜 목록 조회에 실패했습니다.");
                            }
                        }
                    });
                },
                fnToggleAll(e) {
                    if (e.target.checked) {
                        this.selectedIds = this.wishList.map(item => item.wishlistId);
                    } else {
                        this.selectedIds = [];
                    }
                },
                fnMoveToCart(item) {
                    if (item.itemType === "PACKAGE") {
                        alert("패키지 상품은 구성품 및 옵션 선택 후 장바구니에 담을 수 있습니다.");
                        location.href = "/package/detail.do?packageId=" + item.packageId;
                        return;
                    }
                    $.ajax({
                        url: "/cart/add.dox",
                        type: "POST",
                        dataType: "json",
                        data: { productId: item.productId, quantity: 1 },
                        success: function (data) {
                            if (data.result === "success") {
                                if (confirm("장바구니에 담겼습니다. 장바구니로 이동하시겠습니까?")) {
                                    location.href = "/cart/list.do";
                                }
                            } else {
                                alert(data.message || "장바구니 담기에 실패했습니다.");
                            }
                        }
                    });
                },
                fnRemove(wishlistId) {
                    let self = this;
                    if (!confirm("찜 목록에서 삭제하시겠습니까?")) return;
                    $.ajax({
                        url: "/wishlist/remove.dox",
                        type: "POST",
                        dataType: "json",
                        data: { wishlistId: wishlistId },
                        success: function (data) {
                            if (data.result === "success") {
                                self.fnList();
                            } else {
                                alert("삭제에 실패했습니다.");
                            }
                        }
                    });
                },
                fnRemoveSelected() {
                    let self = this;
                    if (this.selectedIds.length === 0) {
                        alert("삭제할 상품을 선택해주세요.");
                        return;
                    }
                    if (!confirm("선택한 " + this.selectedIds.length + "개 항목을 삭제하시겠습니까?")) return;
                    $.ajax({
                        url: "/wishlist/removeSelected.dox",
                        type: "POST",
                        dataType: "json",
                        data: { wishlistIds: this.selectedIds.join(",") },
                        success: function (data) {
                            if (data.result === "success") {
                                self.fnList();
                            } else {
                                alert("선택 삭제에 실패했습니다.");
                            }
                        }
                    });
                },
                fnDeleteAll() {
                    let self = this;
                    if (!confirm("찜 목록을 모두 비우시겠습니까?")) return;
                    $.ajax({
                        url: "/wishlist/deleteAll.dox",
                        type: "POST",
                        dataType: "json",
                        success: function (data) {
                            if (data.result === "success") {
                                self.fnList();
                            } else {
                                alert("전체 비우기에 실패했습니다.");
                            }
                        }
                    });
                },
                fnTestToggle(productId) {
                    let self = this;
                    $.ajax({
                        url: "/wishlist/toggle.dox",
                        type: "POST",
                        dataType: "json",
                        data: { productId: productId },
                        success: function (data) {
                            if (data.result === "success") {
                                self.fnList();
                            } else {
                                alert(data.message || "찜 토글 실패");
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