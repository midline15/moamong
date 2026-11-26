<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Object fwdUri = request.getAttribute("jakarta.servlet.forward.request_uri");
    String curUri = (fwdUri != null) ? fwdUri.toString() : request.getRequestURI();
    String activeMenu = String.valueOf(request.getAttribute("activeMenu"));

    boolean isOrder   = curUri.contains("/order/list") || curUri.contains("/order/detail") || "order".equals(activeMenu);
    boolean isCancel  = curUri.contains("/order/cancel") || "cancel".equals(activeMenu);
    boolean isAddress = curUri.contains("/address/") || "address".equals(activeMenu);
    boolean isReview  = curUri.contains("/review/") || "review".equals(activeMenu);
    boolean isCoupon  = curUri.contains("/coupon/") || "coupon".equals(activeMenu);
    boolean isPoint   = curUri.contains("/point/") || "point".equals(activeMenu);
    boolean isPost    = curUri.contains("/member/mypost") || "post".equals(activeMenu);
    boolean isComment = curUri.contains("/member/mycomment") || "comment".equals(activeMenu);
    boolean isEdit    = curUri.contains("/member/edit") || curUri.contains("/member/withdraw") || "edit".equals(activeMenu) || "info".equals(activeMenu);
%>
<aside class="mp-sidebar">
    <div class="mp-side-title">마이페이지</div>
    <ul class="mp-side-menu">
        <li class="<%= isOrder   ? "active" : "" %>"><a href="/order/list.do">주문 목록</a></li>
        <li class="<%= isCancel  ? "active" : "" %>"><a href="/order/cancel-list.do">반품 목록</a></li>
        <li class="<%= isAddress ? "active" : "" %>"><a href="/address/list.do">배송지 관리</a></li>
        <li class="<%= isReview  ? "active" : "" %>"><a href="/review/myReview.do">리뷰 관리</a></li>
        <li class="<%= isCoupon  ? "active" : "" %>"><a href="/coupon/mylist.do">내 쿠폰</a></li>
        <li class="<%= isPoint   ? "active" : "" %>"><a href="/point/history.do">포인트 내역</a></li>
        <li class="<%= isPost    ? "active" : "" %>"><a href="/member/mypost.do">작성글 관리</a></li>
        <li class="<%= isComment ? "active" : "" %>"><a href="/member/mycomment.do">댓글 관리</a></li>
        <li class="<%= isEdit    ? "active" : "" %>"><a href="/member/edit.do">내 정보 관리</a></li>
    </ul>
</aside>
