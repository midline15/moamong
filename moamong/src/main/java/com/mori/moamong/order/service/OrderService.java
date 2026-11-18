package com.mori.moamong.order.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.order.mapper.OrderMapper;

@RequiredArgsConstructor
@Service
public class OrderService {
    private final OrderMapper orderMapper;

}
