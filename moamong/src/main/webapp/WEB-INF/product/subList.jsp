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
                    categoryId: "${categoryId}",
                    page: 1,
                    limit: 9,
                    offset: 0,
                    maxPage: 0,
                    productList: []
                };
            },
            methods: {
                fnSubProductList: function () {
                    let self = this;

                    let param = {
                        categoryId: self.categoryId,
                        limit: self.limit,
                        offset: self.offset
                    };

                    $.ajax({
                        url: "subList.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            self.productList = data.productList;
                            self.maxPage = Math.ceil(data.totalCount / self.limit);
                        }
                    });
                },
                fnChangePage: function (page) {
                    if (page < 1 || page > this.maxPage) {
                        return;
                    }

                    this.page = page;
                    this.offset = (page - 1) * this.limit;
                    this.fnSubProductList();
                },
                fnProductView: function (productId) {
                    location.href = "view.do?productId=" + productId;
                }
            }, // methods
            mounted() {
                let self = this;
                self.fnSubProductList();
            }
        });

        app.mount('#app');
    </script>