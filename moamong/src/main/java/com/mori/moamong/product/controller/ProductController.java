package com.mori.moamong.product.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.product.service.ProductService;

@RequiredArgsConstructor
@Controller
public class ProductController {
    private final ProductService productService;

}
