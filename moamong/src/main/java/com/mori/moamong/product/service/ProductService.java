package com.mori.moamong.product.service;

import lombok.RequiredArgsConstructor;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.mori.moamong.dto.Product;
import com.mori.moamong.product.mapper.ProductMapper;

@RequiredArgsConstructor
@Service
public class ProductService {
    private final ProductMapper productMapper;

    public List<Product> getProductListByMainCategory(HashMap<String, Object> map) {
        List<Product> list = new ArrayList<>();
        try {
            list = productMapper.selectProductListByMainCategory(map);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        return list;
    }

    public List<Product> getProductListBySubCategory(HashMap<String, Object> map) {
        List<Product> productList = new ArrayList<>();

        try {
            int limit = Integer.parseInt(map.get("limit").toString());
            int offset = Integer.parseInt(map.get("offset").toString());

            map.put("limit", limit);
            map.put("offset", offset);

            productList = productMapper.selectProductListBySubCategory(map);

        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        return productList;
    }

    public int getProductCountBySubCategory(HashMap<String, Object> map) {
        int totalCount = 0;

        try {
            totalCount = productMapper.selectProductCountBySubCategory(map);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        return totalCount;
    }

    public Product getProductInfo(HashMap<String, Object> map) {
        Product info = new Product();

        try {
            info = productMapper.selectProductInfo(map);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        return info;
    }

    @Transactional(rollbackFor = Exception.class)
    public int addProduct(HashMap<String, Object> map, MultipartFile[] productImageList) {
        int result = 0;
        List<HashMap<String, Object>> imageList = new ArrayList<>();

        try {
            // 상품 등록
            result = productMapper.insertProduct(map);

            if (result > 0) {
                int productId = Integer.parseInt(map.get("productId").toString());

                // 이미지가 있을 때만 업로드
                if (productImageList != null) {
                    imageList = uploadProductImage(productImageList);
                }

                // 이미지 경로 DB 등록
                for (HashMap<String, Object> imageMap : imageList) {
                    imageMap.put("productId", productId);

                    productMapper.insertProductImage(imageMap);
                }
            }

        } catch (Exception e) {
            System.out.println(e.getMessage());

            // 저장된 이미지 파일 삭제
            for (HashMap<String, Object> imageMap : imageList) {
                File file = new File(
                        System.getProperty("user.dir")
                                + "/src/main/webapp"
                                + imageMap.get("imageUrl"));

                if (file.exists()) {
                    file.delete();
                }
            }

            throw new RuntimeException(e);
        }

        return result;
    }

    public List<HashMap<String, Object>> uploadProductImage(MultipartFile[] productImageList) {
        List<HashMap<String, Object>> imageList = new ArrayList<>();

        try {
            String uploadPath = System.getProperty("user.dir")
                    + "/src/main/webapp/resources/upload/product/";

            File folder = new File(uploadPath);

            if (!folder.exists()) {
                folder.mkdirs();
            }

            int displayOrder = 1;

            for (MultipartFile file : productImageList) {
                if (!file.isEmpty()) {
                    String originalName = file.getOriginalFilename();
                    String extension = originalName.substring(originalName.lastIndexOf("."));
                    String fileName = UUID.randomUUID().toString() + extension;

                    File saveFile = new File(uploadPath + fileName);
                    file.transferTo(saveFile);

                    HashMap<String, Object> imageMap = new HashMap<String, Object>();

                    imageMap.put("imageUrl", "/resources/upload/product/" + fileName);
                    imageMap.put("imageOriginName", originalName);
                    imageMap.put("imageName", fileName);
                    imageMap.put("imageSize", file.getSize());
                    imageMap.put("imageType", file.getContentType());
                    imageMap.put("displayOrder", displayOrder++);

                    imageList.add(imageMap);
                }
            }

        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        return imageList;
    }
}
