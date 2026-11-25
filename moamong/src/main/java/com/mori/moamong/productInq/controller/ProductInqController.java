package com.mori.moamong.productInq.controller;

import org.springframework.stereotype.Controller;

import com.mori.moamong.productInq.service.ProductInqService;

import lombok.RequiredArgsConstructor;

@Controller
@RequiredArgsConstructor
public class ProductInqController {
    private final ProductInqService productInqService;

}
