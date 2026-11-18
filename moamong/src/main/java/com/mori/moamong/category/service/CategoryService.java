package com.mori.moamong.category.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.category.mapper.CategoryMapper;

@RequiredArgsConstructor
@Service
public class CategoryService {
    private final CategoryMapper categoryMapper;

}
