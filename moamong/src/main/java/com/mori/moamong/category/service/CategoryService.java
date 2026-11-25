package com.mori.moamong.category.service;

import lombok.RequiredArgsConstructor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mori.moamong.category.mapper.CategoryMapper;
import com.mori.moamong.dto.Category;

@RequiredArgsConstructor
@Service
public class CategoryService {
    private final CategoryMapper categoryMapper;

    public List<Category> getMainCategoryList(HashMap<String, Object> map) {
        List<Category> mainCategoryList = new ArrayList<>();
        try {

            mainCategoryList = categoryMapper.selectMainCategoryList(map);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        return mainCategoryList;
    }

    public List<Category> getSubCategoryList(HashMap<String, Object> map) {
        List<Category> subCategoryList = new ArrayList<>();
        try {
            subCategoryList = categoryMapper.selectSubCategoryList(map);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return subCategoryList;
    }

    // 카테고리 단건 조회
    public Category getCategoryById(HashMap<String, Object> map) {
        Category category = new Category();

        try {
            category = categoryMapper.selectCategoryById(map);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        return category;
    }
}
