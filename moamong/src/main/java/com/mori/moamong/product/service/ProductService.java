package com.mori.moamong.product.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.product.mapper.ProductMapper;

@RequiredArgsConstructor
@Service
public class ProductService {
    private final ProductMapper productMapper;

}
