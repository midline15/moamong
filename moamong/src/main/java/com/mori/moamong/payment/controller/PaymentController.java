package com.mori.moamong.payment.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.payment.service.PaymentService;

@RequiredArgsConstructor
@Controller
public class PaymentController {
    private final PaymentService paymentService;

}
