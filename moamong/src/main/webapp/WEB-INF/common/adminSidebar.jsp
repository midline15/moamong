
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Object admFwd = request.getAttribute("jakarta.servlet.forward.request_uri");
    String admUri = (admFwd != null) ? admFwd.toString() : request.getRequestURI();

    boolean admMember = admUri.contains("/admin/member");
    boolean admCoupon = admUri.contains("/admin/coupon") || admUri.contains("/coupon/");
    boolean admEvent  = admUri.contains("/admin/event");
    boolean admPolicy = admUri.contains("/admin/policy");
    boolean admReview = admUri.contains("/admin/review");
%>
<aside class="adm-sidebar">
    <div class="adm-side-title">관리자 페이지<span>ADMIN</span></div>
    <ul class="adm-side-menu">
        <li class="<%= admMember ? "active" : "" %>"><a href="/admin/member/list.do">회원 관리</a></li>
        <li class="pending"><a href="javascript:void(0)">상품조회 / 등록</a></li>
        <li class="pending"><a href="javascript:void(0)">주문 관리</a></li>
        <li class="pending"><a href="javascript:void(0)">배송 관리</a></li>
        <li class="pending"><a href="javascript:void(0)">재고 관리</a></li>
        <li class="pending"><a href="javascript:void(0)">거래처 관리</a></li>
        <li class="<%= admReview ? "active" : "" %>"><a href="/admin/review/list.do">리뷰 및 문의</a></li>
        <li class="<%= admCoupon ? "active" : "" %>"><a href="/admin/coupon/list.do">쿠폰 관리</a></li>
        <li class="<%= admEvent ? "active" : "" %>"><a href="/admin/event/list.do">이벤트 관리</a></li>
        <li class="<%= admPolicy ? "active" : "" %>"><a href="/admin/policy/list.do">운영정책 관리</a></li>
        <li class="pending"><a href="javascript:void(0)">매출 통계</a></li>
    </ul>
</aside>
