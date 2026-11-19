<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js"
            integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <style>
            table,
            tr,
            td,
            th {
                border: 1px solid black;
                border-collapse: collapse;
                padding: 5px 10px;
                text-align: center;
            }

            th {
                background-color: beige;
            }

            tr:nth-child(even) {
                background-color: azure;
            }
        </style>
    </head>

    <body>
        <div id="app">
            <div v-for="item in cartList" :key="item.cartItemId">
                <!-- 상품명 -->
                <span>{{ item.productName }}</span>

                <!-- 상품 가격 -->
                <span>{{ item.price }}원</span>

                <!-- 수량 -->
                <input type="number" v-model.number="item.quantity" min="1">

                <!-- 수량 변경 -->
                <button @click="fnUpdate(item.cartItemId, item.quantity)">
                    수량 변경
                </button>

                <!-- 삭제 -->
                <button @click="fnRemove(item.cartItemId)">
                    삭제
                </button>


            </div>


            <div>
                <h3>총 상품 금액</h3>
                <strong>{{ cartTotal.toLocaleString() }}원</strong>
            </div>

            <button @click="fnDeleteAll">
                장바구니 비우기
            </button>

        </div>
    </body>

    </html>

    <script>
        const app = Vue.createApp({
            data() {
                return {
                    cartList: [],
                    memberId: "",
                    cartTotal: 0
                };
            },
            methods: {
                // 장바구니 목록 조회
                fnList: function () {
                    let self = this;

                    let param = {
                        memberId: 1
                    };

                    $.ajax({
                        url: "/cart/list.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {

                            if (data.result == "success") {
                                self.cartList = data.list;
                                self.fnTotal();
                            } else {
                                alert("장바구니 조회에 실패했습니다.");
                            }

                        }
                    });
                },
                fnRemove: function (cartItemId) {
                    let self = this;

                    if (!confirm("장바구니에서 삭제하시겠습니까?")) {
                        return;
                    }

                    let param = {
                        cartItemId: cartItemId
                    };

                    $.ajax({
                        url: "/cart/remove.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            if (data.result == "success") {
                                alert("삭제되었습니다.");
                                self.fnList();
                            } else {
                                alert("삭제에 실패했습니다.");
                            }
                        }
                    });
                },

                // 장바구니 수량 변경
                fnUpdate: function (cartItemId, quantity) {
                    let self = this;

                    let param = {
                        cartItemId: cartItemId,
                        quantity: quantity
                    };

                    $.ajax({
                        url: "/cart/update.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            if (data.result == "success") {
                                alert("수량이 변경되었습니다.");
                                self.fnList();
                            } else {
                                alert("수량 변경에 실패했습니다.");
                            }
                        }
                    });
                },

                // 장바구니 총 금액 계산
                fnTotal: function () {
                    let self = this;

                    self.cartTotal = 0;

                    for (let i = 0; i < self.cartList.length; i++) {
                        self.cartTotal += self.cartList[i].price * self.cartList[i].quantity;
                    }
                },

                fnDeleteAll: function () {
                    let self = this;

                    if (!confirm("장바구니를 모두 비우시겠습니까?")) {
                        return;
                    }

                    let param = {
                        memberId: 1
                    };

                    $.ajax({
                        url: "/cart/deleteAll.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            if (data.result == "success") {
                                alert("장바구니를 비웠습니다.");
                                self.fnList();
                            } else {
                                alert("장바구니 비우기에 실패했습니다.");
                            }
                        }
                    });
                }



            }, // methods

            mounted() {
                let self = this;

                self.fnList();
            }
        });

        app.mount('#app');
    </script>