
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>1:1문의</title>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4="
        crossorigin="anonymous"></script>

    <!-- Vue -->
    <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>

    <script src="/js/page-change.js"></script>



    <style>
        table, tr, td, th {
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
        <div>

        </div>
    </div>

</body>
</html>

<script>
    const app = Vue.createApp({

        data() {
            return {
                inquiryList: []
            };
        },

        methods: {

            fnList: function () {
                let self = this;
                let param = {};

                $.ajax({
                    url: "http://localhost:8080/inquiry/list.dox",
                    dataType: "json",
                    type: "POST",
                    data: param,

                    success: function (data) {
                        console.log(data);
                        self.inquiryList = data.list;
                    }
                });
            }

        },

        mounted() {
            let self = this;
            self.fnList();
        }

    });

    app.mount('#app');
</script>
