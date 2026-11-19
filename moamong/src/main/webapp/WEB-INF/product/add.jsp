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
                    info: {
                        productName: "샘플",
                        categoryId: "1",
                        productDescription: "샘플입니다",
                        price: "1",
                        stockQuantity: "1",
                        productStatus: "SELLING",
                        productImageList: []
                    }

                };
            },
            methods: {
                fnProductAdd: function () {
                    let self = this;

                    let formData = new FormData();

                    formData.append("productName", self.info.productName);
                    formData.append("categoryId", self.info.categoryId);
                    formData.append("productDescription", self.info.productDescription);
                    formData.append("price", self.info.price);
                    formData.append("stockQuantity", self.info.stockQuantity);
                    formData.append("productStatus", self.info.productStatus);

                    for (let i = 0; i < self.info.productImageList.length; i++) {
                        formData.append("productImageList", self.info.productImageList[i]);
                    }

                    $.ajax({
                        url: "add.dox",
                        dataType: "json",
                        type: "POST",
                        data: formData,
                        processData: false,
                        contentType: false,
                        success: function (data) {
                            if (data.result > 0) {
                                alert("상품이 등록되었습니다.");
                                location.href = "list.do";
                            } else {
                                alert("상품 등록에 실패했습니다.");
                            }
                        }
                    });
                }
            }, // methods
            mounted() {
                let self = this;
                self.fnProductAdd();
            }
        });

        app.mount('#app');
    </script>