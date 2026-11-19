<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>모아몽 메인</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js" integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>
        <style>
            table, tr, td, th{
                border : 1px solid black;
                border-collapse: collapse;
                padding : 5px 10px;
                text-align: center;
            }
            th{
                background-color: beige;
            }
            tr:nth-child(even){
                background-color: azure;
            }
        </style>
    </head>
    <body>
        <h2>실행 테스트</h2>

        <% if (session.getAttribute("sessionId") != null) {
            String createdAtStr = String.valueOf(session.getAttribute("sessionCreatedAt")).replace("T", " ");
        %>
        <p>
            <strong><%= session.getAttribute("sessionName") %></strong>님 환영합니다!<br>
            - 회원번호: <%= session.getAttribute("sessionId") %><br>
            - 권한: <%= session.getAttribute("sessionRole") %><br>
            - 계정 상태: <strong><%= session.getAttribute("sessionStatus") %></strong><br>
            - 가입일시: <%= createdAtStr %>
        </p>
        <button onclick="location.href='/member/mypage.do'">마이페이지</button>
        <button onclick="fnLogout()">로그아웃</button>
        <% } else { %>
        <p>현재 비로그인 상태입니다.</p>
        <button onclick="location.href='/member/login.do'">로그인</button>
        <button onclick="location.href='/member/join.do'">회원가입</button>
        <% } %>

        <script>
            function fnLogout() {
                $.ajax({
                    url: "/member/logout.dox",
                    type: "POST",
                    dataType: "json",
                    success: function (data) {
                        alert(data.message);
                        location.href = "/member/login.do";
                    }
                });
            }
        </script>
    </body>
</html>