package com.mori.moamong.product.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Product;

@Mapper
public interface ProductMapper {

    List<Product> selectProductListByMainCategory(HashMap<String, Object> map);

    List<Product> selectProductListBySubCategory(HashMap<String, Object> map);

    int selectProductCountBySubCategory(HashMap<String, Object> map);

    Product selectProductInfo(HashMap<String, Object> map);

    int insertProduct(HashMap<String, Object> map);

    int insertProductImage(HashMap<String, Object> map);
}
