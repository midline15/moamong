
```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String requestUri = request.getRequestURI();
%>

<aside class="sidebar">

    <div class="sidebar-title">
        관리자 페이지
    </div>

    <ul>
        <li class="<%= requestUri.contains("/admin/member/") ? "active" : "" %>"
            onclick="location.href='/admin/member/list.do'">
            회원 관리
        </li>

        <li onclick="location.href='/admin/product/list.do'">
            상품조회 / 등록
        </li>

        <li class="<%= requestUri.contains("/admin/order/") ? "active" : "" %>"
            onclick="location.href='/admin/order/list.do'">
            주문 관리
        </li>

        <li class="<%= requestUri.contains("/admin/shipment/") ? "active" : "" %>"
            onclick="location.href='/admin/shipment/list.do'">
            배송 관리
        </li>

        <li onclick="location.href='/admin/stock/list.do'">
            재고 관리
        </li>

        <li onclick="location.href='/admin/vendor/list.do'">
            거래처 관리
        </li>

        <li onclick="location.href='/admin/review/list.do'">
            리뷰 및 문의
        </li>

        <li class="<%= requestUri.contains("/admin/coupon/") ? "active" : "" %>"
            onclick="location.href='/admin/coupon/list.do'">
            쿠폰 관리
        </li>

        <li class="<%= requestUri.contains("/admin/event/") ? "active" : "" %>"
            onclick="location.href='/admin/event/list.do'">
            이벤트 관리
        </li>

        <li class="<%= requestUri.contains("/admin/policy/") ? "active" : "" %>"
            onclick="location.href='/admin/policy/list.do'">
            운영정책 관리
        </li>

        <li onclick="location.href='/admin/sales/list.do'">
            매출 통계
        </li>
    </ul>

</aside>
```
