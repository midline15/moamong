package com.mori.moamong.product.service;

import lombok.RequiredArgsConstructor;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.web.multipart.MultipartFile;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mori.moamong.dto.Product;
import com.mori.moamong.dto.ProductImage;
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

            if (info != null) {
                info.setProductImageList(productMapper.selectProductImageList(map));
            }

        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        return info;
    }

    public void updateProductViewCount(HashMap<String, Object> map) {
        try {
            productMapper.updateProductViewCount(map);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    // 상품 등록, 이미지 정보 DB 등록 및 DB 처리 실패 시 파일 정리
    @Transactional(rollbackFor = Exception.class)
    public int addProduct(
            HashMap<String, Object> map,
            MultipartFile thumbnailImage,
            MultipartFile[] productImageList) {

        int result = 0;
        List<HashMap<String, Object>> imageList = new ArrayList<>();

        try {
            // 상품 등록
            result = productMapper.insertProduct(map);

            if (result > 0) {
                long productId = Long.parseLong(map.get("productId").toString());

                // 이미지 업로드
                if (thumbnailImage != null || productImageList != null) {
                    imageList = uploadProductImage(
                            thumbnailImage,
                            productImageList != null ? productImageList : new MultipartFile[0]);
                }

                // 이미지 정보 DB 등록
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

                if (file.exists() && !file.delete()) {
                    System.out.println("이미지 파일 삭제 실패: " + file.getAbsolutePath());
                }
            }

            throw new RuntimeException(e);
        }

        return result;
    }

    // 이미지 파일 저장 및 업로드 실패 시 파일 정리
    private List<HashMap<String, Object>> uploadProductImage(
            MultipartFile thumbnailImage,
            MultipartFile[] productImageList) {

        List<HashMap<String, Object>> imageList = new ArrayList<>();

        try {
            String uploadPath = System.getProperty("user.dir")
                    + "/src/main/webapp/resources/upload/product/";

            File folder = new File(uploadPath);

            // 업로드 폴더 확인
            if (!folder.exists() && !folder.mkdirs()) {
                throw new RuntimeException("이미지 업로드 폴더 생성 실패");
            }

            if (!folder.isDirectory() || !folder.canWrite()) {
                throw new RuntimeException("이미지 업로드 폴더에 접근할 수 없습니다.");
            }

            // 썸네일 이미지 저장
            if (thumbnailImage != null && !thumbnailImage.isEmpty()) {
                saveProductImage(
                        thumbnailImage,
                        "THUMBNAIL",
                        0,
                        imageList,
                        uploadPath);
            }

            // 상세 이미지 저장
            int displayOrder = 1;

            if (productImageList != null) {
                for (MultipartFile file : productImageList) {
                    if (file != null && !file.isEmpty()) {
                        saveProductImage(
                                file,
                                "DETAIL",
                                displayOrder++,
                                imageList,
                                uploadPath);
                    }
                }
            }

        } catch (Exception e) {
            System.out.println(e.getMessage());

            // 업로드 실패 시 저장된 파일 삭제
            for (HashMap<String, Object> imageMap : imageList) {
                File file = new File(
                        System.getProperty("user.dir")
                                + "/src/main/webapp"
                                + imageMap.get("imageUrl"));

                if (file.exists() && !file.delete()) {
                    System.out.println("이미지 파일 삭제 실패: " + file.getAbsolutePath());
                }
            }

            throw new RuntimeException(e);
        }

        return imageList;
    }

    // 이미지 파일 검증 및 저장, 이미지 정보 목록 추가
    private void saveProductImage(
            MultipartFile file,
            String imageType,
            int displayOrder,
            List<HashMap<String, Object>> imageList,
            String uploadPath) throws Exception {

        String originalName = file.getOriginalFilename();

        // 파일명 확인
        if (originalName == null || !originalName.contains(".")) {
            throw new RuntimeException("올바르지 않은 이미지 파일명입니다.");
        }

        String extension = originalName.substring(originalName.lastIndexOf(".")).toLowerCase();

        // 허용 확장자 확인
        if (!extension.matches("\\.(jpg|jpeg|png|gif|bmp)")) {
            throw new RuntimeException("지원하지 않는 이미지 형식입니다.");
        }

        // 실제 이미지 형식 확인
        try (ImageInputStream inputStream = ImageIO.createImageInputStream(file.getInputStream())) {

            if (inputStream == null) {
                throw new RuntimeException("이미지 파일을 읽을 수 없습니다.");
            }

            Iterator<ImageReader> readers = ImageIO.getImageReaders(inputStream);

            if (!readers.hasNext()) {
                throw new RuntimeException("올바르지 않은 이미지 파일입니다.");
            }

            ImageReader reader = readers.next();

            try {
                reader.setInput(inputStream);

                String imageFormat = reader.getFormatName().toLowerCase();

                boolean isJpeg = extension.equals(".jpg") || extension.equals(".jpeg");

                if (isJpeg ? !imageFormat.equals("jpeg") : !extension.equals("." + imageFormat)) {
                    throw new RuntimeException("파일 확장자와 이미지 형식이 일치하지 않습니다.");
                }

                // 이미지 데이터 확인
                reader.read(0);

            } finally {
                reader.dispose();
            }
        }

        String fileName = UUID.randomUUID().toString() + extension;

        HashMap<String, Object> imageMap = new HashMap<String, Object>();

        imageMap.put("imageUrl", "/resources/upload/product/" + fileName);
        imageMap.put("imageOriginName", originalName);
        imageMap.put("imageName", fileName);
        imageMap.put("imageSize", file.getSize());
        imageMap.put("imageType", imageType);
        imageMap.put("displayOrder", displayOrder);

        // 이미지 목록에 추가
        imageList.add(imageMap);

        // 이미지 저장
        File saveFile = new File(uploadPath + fileName);
        file.transferTo(saveFile);
    }

    @Transactional(rollbackFor = Exception.class)
    public int editProduct(
            HashMap<String, Object> map,
            MultipartFile thumbnailImage,
            MultipartFile[] productImageList) {

        List<File> deleteFileList = new ArrayList<>();

        try {
            // 기존 상품 이미지 조회
            List<ProductImage> oldImageList = productMapper.selectProductImageList(map);

            HashMap<Long, ProductImage> oldImageMap = new HashMap<>();

            for (ProductImage image : oldImageList) {
                oldImageMap.put(image.getImageId(), image);
            }

            // 최종 상세 이미지 목록 파싱
            String imageListJson = (String) map.get("imageList");

            List<HashMap<String, Object>> imageList = new Gson().fromJson(
                    imageListJson,
                    new TypeToken<List<HashMap<String, Object>>>() {
                    }.getType());

            if (imageList == null) {
                throw new RuntimeException("상품 이미지 목록이 없습니다.");
            }

            // 새 이미지 파일 목록 정리
            List<MultipartFile> newFileList = new ArrayList<>();

            if (productImageList != null) {
                for (MultipartFile file : productImageList) {
                    if (file != null && !file.isEmpty()) {
                        newFileList.add(file);
                    }
                }
            }

            // 새 이미지 개수 확인
            int newImageCount = 0;

            for (HashMap<String, Object> image : imageList) {
                if (Boolean.TRUE.equals(image.get("isNew"))) {
                    newImageCount++;
                }
            }

            if (newImageCount != newFileList.size()) {
                throw new RuntimeException("이미지 파일 목록이 일치하지 않습니다.");
            }

            // 썸네일 및 새 상세 이미지 업로드
            List<HashMap<String, Object>> uploadedList = uploadProductImage(
                    thumbnailImage,
                    newFileList.toArray(new MultipartFile[0]));

            // 업로드 성공 후 트랜잭션 결과에 따른 파일 정리 등록
            TransactionSynchronizationManager
                    .registerSynchronization(
                            new TransactionSynchronization() {

                                @Override
                                public void afterCommit() {
                                    // DB 커밋 후 기존 파일 삭제
                                    for (File file : deleteFileList) {
                                        if (file.exists() && !file.delete()) {
                                            System.out.println("이미지 파일 삭제 실패: " + file.getAbsolutePath());
                                        }
                                    }
                                }

                                @Override
                                public void afterCompletion(int status) {
                                    // DB 롤백 시 새로 업로드한 파일 삭제
                                    if (status != STATUS_COMMITTED) {
                                        for (HashMap<String, Object> image : uploadedList) {
                                            File file = new File(
                                                    System.getProperty("user.dir")
                                                            + "/src/main/webapp"
                                                            + image.get("imageUrl"));

                                            if (file.exists() && !file.delete()) {
                                                System.out.println("이미지 파일 삭제 실패: " + file.getAbsolutePath());
                                            }
                                        }
                                    }
                                }
                            });

            // 업로드된 상세 이미지와 썸네일 구분
            HashMap<String, Object> thumbnailMap = null;
            List<HashMap<String, Object>> uploadedDetailList = new ArrayList<>();

            for (HashMap<String, Object> image : uploadedList) {
                if ("THUMBNAIL".equals(image.get("imageType"))) {
                    thumbnailMap = image;
                } else {
                    uploadedDetailList.add(image);
                }
            }

            // 최종 목록에 포함된 기존 이미지 ID
            List<Long> keepImageIdList = new ArrayList<>();

            // 새 이미지 파일 연결 순서
            int newImageIndex = 0;

            // 최종 상세 이미지 반영
            for (HashMap<String, Object> image : imageList) {

                int displayOrder = ((Number) image.get("displayOrder")).intValue();

                if (Boolean.TRUE.equals(image.get("isNew"))) {

                    // 새 이미지 등록
                    HashMap<String, Object> newImage = uploadedDetailList.get(newImageIndex++);

                    newImage.put("productId", map.get("productId"));
                    newImage.put("displayOrder", displayOrder);

                    productMapper.insertProductImage(newImage);

                } else {

                    // 기존 이미지 유지 및 순서 변경
                    Long imageId = ((Number) image.get("imageId")).longValue();

                    ProductImage oldImage = oldImageMap.get(imageId);

                    if (oldImage == null || !"DETAIL".equals(oldImage.getImageType())) {
                        throw new RuntimeException("잘못된 상품 이미지 정보입니다.");
                    }

                    if (keepImageIdList.contains(imageId)) {
                        throw new RuntimeException("중복된 상품 이미지 정보입니다.");
                    }

                    keepImageIdList.add(imageId);

                    HashMap<String, Object> updateMap = new HashMap<>();
                    updateMap.put("imageId", imageId);
                    updateMap.put("productId", map.get("productId"));
                    updateMap.put("displayOrder", displayOrder);

                    productMapper.updateProductImageDisplayOrder(updateMap);
                }
            }

            // 최종 목록에서 제외된 기존 상세 이미지 삭제
            for (ProductImage image : oldImageList) {

                if ("DETAIL".equals(image.getImageType())
                        && !keepImageIdList.contains(image.getImageId())) {

                    HashMap<String, Object> deleteMap = new HashMap<>();
                    deleteMap.put("imageId", image.getImageId());
                    deleteMap.put("productId", map.get("productId"));

                    productMapper.deleteProductImage(deleteMap);

                    deleteFileList.add(new File(
                            System.getProperty("user.dir")
                                    + "/src/main/webapp"
                                    + image.getImageUrl()));
                }
            }

            // 새 썸네일이 있다면 기존 썸네일 교체
            if (thumbnailMap != null) {

                for (ProductImage image : oldImageList) {

                    if ("THUMBNAIL".equals(image.getImageType())) {

                        HashMap<String, Object> deleteMap = new HashMap<>();
                        deleteMap.put("imageId", image.getImageId());
                        deleteMap.put("productId", map.get("productId"));

                        productMapper.deleteProductImage(deleteMap);

                        deleteFileList.add(new File(
                                System.getProperty("user.dir")
                                        + "/src/main/webapp"
                                        + image.getImageUrl()));
                    }
                }

                thumbnailMap.put("productId", map.get("productId"));

                productMapper.insertProductImage(thumbnailMap);
            }

            // 상품 정보 수정
            int result = productMapper.updateProduct(map);

            return result;

        } catch (Exception e) {
            System.out.println(e.getMessage());
            throw new RuntimeException(e);
        }
    }

    // 상품 상태 수정
    public int editProductStatus(HashMap<String, Object> map) {
        int result = 0;

        try {
            result = productMapper.updateProductStatus(map);
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        return result;
    }
}
