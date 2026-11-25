package com.mori.moamong.productInq.service;

import org.springframework.stereotype.Service;

import com.mori.moamong.productInq.mapper.ProductInqMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProductInqService {
    private final ProductInqMapper productInqMapper;

}
