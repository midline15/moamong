package com.mori.moamong.category.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.category.service.CategoryService;

@RequiredArgsConstructor
@Controller
public class CategoryController {
    private final CategoryService categoryService;

}
