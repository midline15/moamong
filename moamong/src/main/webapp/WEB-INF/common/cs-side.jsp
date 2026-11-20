<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    // 활성 메뉴 (notice / inquiry / faq), 값이 없으면 공지사항
    String csMenu = (String) request.getAttribute("csMenu");
    if (csMenu == null) csMenu = "notice";
%>

<!-- 좌측 고객센터 메뉴 -->
<aside class="cs-side">
    <div class="cs-side-title">
        <strong>고객센터</strong>
        <span>CUSTOMER CENTER</span>
    </div>
    <ul class="cs-menu">
        <li class="<%= "notice".equals(csMenu) ? "active" : "" %>"><a href="/notice/list.do">공지사항</a></li>
        <li class="<%= "inquiry".equals(csMenu) ? "active" : "" %>"><a href="/inquiry/list.do">1:1 상담문의</a></li>
        <li class="<%= "faq".equals(csMenu) ? "active" : "" %>"><a href="/faq/list.do">자주묻는 질문</a></li>
    </ul>
    <div class="cs-tel">
        <p>고객센터 대표전화</p>
        <strong>1577-0000</strong>
    </div>
</aside>