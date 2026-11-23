package com.mori.moamong.payment.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.mori.moamong.dto.Payment;

@Mapper
public interface PaymentMapper {

    // 1. 결제 정보 저장 (PAID)
    int insertPayment(Payment payment);

    // 2. 주문 번호로 결제 내역 조회
    Payment selectPaymentByOrderId(@Param("orderId") Long orderId);

    // 3. 결제 상태 변경 (CANCELLED 등)
    int updatePaymentStatus(@Param("paymentId") Long paymentId,
                            @Param("paymentStatus") String paymentStatus);
}
