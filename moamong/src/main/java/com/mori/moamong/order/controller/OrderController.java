package com.mori.moamong.order.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.order.service.OrderService;

@RequiredArgsConstructor
@Controller
public class OrderController {
    private final OrderService orderService;

}
