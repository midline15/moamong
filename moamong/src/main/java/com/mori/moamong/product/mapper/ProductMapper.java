package com.mori.moamong.product.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Product;
import com.mori.moamong.dto.ProductImage;

@Mapper
public interface ProductMapper {

    // 메인 카테고리에 해당하는 상품목록
    List<Product> selectProductListByMainCategory(HashMap<String, Object> map);

    // 서브 카테고리에 해당하는 상품 목록
    List<Product> selectProductListBySubCategory(HashMap<String, Object> map);

    // 서브 카테고리 상품 총 갯수
    int selectProductCountBySubCategory(HashMap<String, Object> map);

    // 상품 하나 조회
    Product selectProductInfo(HashMap<String, Object> map);

    // 해당 상품의 전체 이미지 조회
    List<ProductImage> selectProductImageList(HashMap<String, Object> map);

    // 상품 조회수 증가
    int updateProductViewCount(HashMap<String, Object> map);

    // 상품 추가
    int insertProduct(HashMap<String, Object> map);

    // 상품 추가시 이미지 추가
    int insertProductImage(HashMap<String, Object> map);

    // 이미지 정보 조회
    // ProductImage selectProductImage(HashMap<String, Object> map);

    // 이미지 DB 삭제
    int deleteProductImage(HashMap<String, Object> map);

    // 상품 수정
    int updateProduct(HashMap<String, Object> map);

    // 상품 이미지 순서 수정
    int updateProductImageDisplayOrder(HashMap<String, Object> map);

    // 상품 상태 수정(판매,매진,숨김,삭제)
    int updateProductStatus(HashMap<String, Object> map);
    
    
    // 관리자 상품 목록
    List<Product> selectAdminProductList(HashMap<String, Object> map);

    // 관리자 상품 전체 개수
    int selectAdminProductCount(HashMap<String, Object> map);
}
