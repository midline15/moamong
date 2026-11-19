
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- 사이드바 CSS 연결 -->
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">

<!-- =================================
     사이드바 전체 영역
================================== -->
<div class="menu-container">

    <!-- 1차 메뉴 -->
    <ul class="main-menu">

        <!-- 이벤트 -->
        <li>
            <a href="#">이벤트</a>
        </li>

        <!-- 선물키트 -->
        <li class="has-submenu">
            <a href="#">
                선물키트
                <span class="arrow"></span>
            </a>

            <!-- 2차 메뉴 -->
            <ul class="sub-menu">

                <!-- 대상으로 -->
                <li class="has-submenu">
                    <a href="#">
                        마음을 전할 사람
                        <span class="arrow"></span>
                    </a>

                    <!-- 3차 메뉴 -->
                    <ul class="third-menu">
                        <li><a href="#">가족</a></li>
                        <li><a href="#">연인</a></li>
                        <li><a href="#">친구</a></li>
                        <li><a href="#">동료</a></li>
                        <li><a href="#">나에게</a></li>
                    </ul>
                </li>

                <!-- 목적으로 -->
                <li class="has-submenu">
                    <a href="#">
                        특별한 순간
                        <span class="arrow"></span>
                    </a>

                    <!-- 3차 메뉴 -->
                    <ul class="third-menu">
                        <li><a href="#">생일ㆍ기념일</a></li>
                        <li><a href="#">감사ㆍ답례</a></li>
                        <li><a href="#">축하ㆍ응원</a></li>
                        <li><a href="#">위로ㆍ격려</a></li>
                        <li><a href="#">마음전달</a></li>
                    </ul>
                </li>

            </ul>
        </li>

        <!-- 단품 -->
        <li>
            <a href="#">단품</a>
        </li>

        <!-- 소셜 -->
        <li>
            <a href="#">소셜</a>
        </li>

        <!-- 고객센터 -->
        <li>
            <a href="#">고객센터</a>
        </li>

        <!-- 하단 로고 -->
        <li class="logo-area">
            <a href="#" class="logo">Logo</a>
        </li>

    </ul>

</div>
