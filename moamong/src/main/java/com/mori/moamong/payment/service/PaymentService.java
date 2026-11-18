package com.mori.moamong.payment.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.payment.mapper.PaymentMapper;

@RequiredArgsConstructor
@Service
public class PaymentService {
    private final PaymentMapper paymentMapper;

}
