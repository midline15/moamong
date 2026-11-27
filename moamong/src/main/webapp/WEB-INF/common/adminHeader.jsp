<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="adm-header">
    <a class="adm-logo" href="/admin/member/list.do">
        <img src="<%= request.getContextPath() %>/assets/logos/moamongEn.png" alt="MOAMONG">
        <span class="adm-logo-tag">ADMIN</span>
    </a>
    <div class="adm-header-right">
        <a class="adm-header-link" href="/">사이트 바로가기</a>
        <a class="adm-header-link adm-header-logout" href="/member/logout.do">로그아웃</a>
    </div>
</header>