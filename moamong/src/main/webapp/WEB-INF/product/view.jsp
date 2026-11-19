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

        </div>
    </body>

    </html>

    <script>
        const app = Vue.createApp({
            data() {
                return {
                    productId: "${productId}",
                    info: {}
                };
            },
            methods: {
                fnProductView: function () {
                    let self = this;

                    let param = {
                        productId: self.productId
                    };

                    $.ajax({
                        url: "view.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            self.info = data.info;
                        }
                    });
                },
                fnSubCategoryList: function (categoryId) {
                    location.href = "subList.do?categoryId=" + categoryId;
                },
                fnAddCart: function () {
                    let self = this;


                    let param = {
                        memberId: 1,
                        productId: 1,
                        quantity: 1
                    };


                    $.ajax({
                        url: "/cart/add.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            if (data.result == "success") {
                                alert("장바구니에 상품이 담겼습니다.");
                            } else {
                                alert("장바구니 추가에 실패했습니다.");
                            }
                        }
                    });
                }
            }, // methods
            mounted() {
                let self = this;
                self.fnProductView();
            }
        });

        app.mount('#app');
    </script>