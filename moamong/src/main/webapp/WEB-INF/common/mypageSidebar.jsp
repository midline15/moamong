<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String activeMenu = String.valueOf(request.getAttribute("activeMenu"));
    Object sessId = session.getAttribute("sessionId");
%>
<aside class="mp-sidebar">
    <div class="mp-side-title">마이페이지</div>
    <ul class="mp-side-menu">
        <li class="<%= "order".equals(activeMenu) ? "active" : "" %>"><a href="/order/list.do">주문 목록</a></li>
        <li class="<%= "cancel".equals(activeMenu) ? "active" : "" %>"><a href="/order/cancel-list.do">반품 목록</a></li>
        <li class="<%= "address".equals(activeMenu) ? "active" : "" %>"><a href="/address/list.do">배송지 관리</a></li>
        <li class="<%= "review".equals(activeMenu) ? "active" : "" %>">
            <a href="javascript:;" onclick="pageChange('/review/myReview.do', {memberId: '<%= sessId %>'})">리뷰 관리</a>
        </li>
        <li class="<%= "coupon".equals(activeMenu) ? "active" : "" %>">
            <a href="javascript:;" onclick="pageChange('/coupon/mylist.do', {memberId: '<%= sessId %>'})">내 쿠폰</a>
        </li>
        <li class="<%= "point".equals(activeMenu) ? "active" : "" %>">
            <a href="javascript:;" onclick="pageChange('/point/history.do', {memberId: '<%= sessId %>'})">포인트 내역</a>
        </li>
        <li class="<%= "post".equals(activeMenu) ? "active" : "" %>"><a href="/community/mypost.do">작성글 관리</a></li>
        <li class="<%= "comment".equals(activeMenu) ? "active" : "" %>"><a href="/community/mycomment.do">댓글 관리</a></li>
        <li class="<%= "info".equals(activeMenu) ? "active" : "" %>"><a href="/member/edit.do">내 정보 관리</a></li>
    </ul>
</aside>
