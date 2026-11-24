package com.mori.moamong.category.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Category;

@Mapper
public interface CategoryMapper {

    // 대분류 목록
    List<Category> selectMainCategoryList(HashMap<String, Object> map);

    // 소분류 목록
    List<Category> selectSubCategoryList(HashMap<String, Object> map);

    // 카테고리 단건 조회
    Category selectCategoryById(HashMap<String, Object> map);

}
