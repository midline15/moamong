
package com.mori.moamong.review.service;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mori.moamong.dto.Review;
import com.mori.moamong.dto.ReviewImage;
import com.mori.moamong.review.mapper.ReviewMapper;

@Service
public class ReviewService {

    @Autowired
    ReviewMapper reviewMapper;

    // 실제 이미지 저장 경로
    @Value("${file.upload-path:src/main/webapp/resources/upload/review}")
    private String uploadPath;

    // 브라우저 이미지 접근 경로
    @Value("${file.upload-url:/resources/upload/review}")
    private String uploadUrl;

    // 나의 리뷰 목록 조회
    public HashMap<String, Object> getMyReviewList(HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            Long memberId = getMemberId(map);
            map.put("memberId", memberId);

            List<Review> list = reviewMapper.selectMyReviewList(map);

            for (Review review : list) {

                HashMap<String, Object> imageMap = new HashMap<>();
                imageMap.put("reviewId", review.getReviewId());

                List<ReviewImage> imageList = reviewMapper.selectReviewImageList(imageMap);

                review.setImageList(imageList);
            }

            int count = reviewMapper.selectMyReviewCount(map);

            resultMap.put("list", list);
            resultMap.put("count", count);
            resultMap.put("result", "success");

        } catch (Exception e) {

            resultMap.put("result", "fail");
            resultMap.put("message", "리뷰 목록 조회에 실패했습니다.");

            e.printStackTrace();
        }

        return resultMap;
    }

    // 리뷰 수정
    @Transactional(rollbackFor = Exception.class)
    public HashMap<String, Object> editReview(
            HashMap<String, Object> map,
            MultipartFile[] files) throws Exception {

        HashMap<String, Object> resultMap = new HashMap<>();

        Long memberId = getMemberId(map);
        Long reviewId = Long.parseLong(map.get("reviewId").toString());

        // 리뷰 소유자 확인
        HashMap<String, Object> checkMap = new HashMap<>();
        checkMap.put("memberId", memberId);
        checkMap.put("reviewId", reviewId);

        Review review = reviewMapper.selectReview(checkMap);

        if (review == null) {
            resultMap.put("result", "fail");
            resultMap.put("message", "수정할 리뷰가 없거나 권한이 없습니다.");
            return resultMap;
        }

        // 별점 검사
        int rating = Integer.parseInt(map.get("rating").toString());

        if (rating < 1 || rating > 5) {
            throw new IllegalArgumentException("별점은 1점부터 5점까지 가능합니다.");
        }

        // 리뷰 내용 검사
        String reviewContent = map.get("reviewContent").toString().trim();

        if (reviewContent.isEmpty()) {
            throw new IllegalArgumentException("리뷰 내용을 입력해주세요.");
        }

        map.put("memberId", memberId);
        map.put("reviewId", reviewId);
        map.put("rating", rating);
        map.put("reviewContent", reviewContent);

        // 삭제할 이미지 목록
        String deleteJson = map.get("deleteImageList") == null
                ? "[]"
                : map.get("deleteImageList").toString();

        List<Long> deleteImageList = new Gson().fromJson(
                deleteJson,
                new TypeToken<List<Long>>() {
                }.getType());

        if (deleteImageList == null) {
            deleteImageList = new ArrayList<>();
        }

        // 기존 이미지 조회
        HashMap<String, Object> imageMap = new HashMap<>();
        imageMap.put("reviewId", reviewId);

        List<ReviewImage> currentImageList = reviewMapper.selectReviewImageList(imageMap);

        int remainingCount = currentImageList.size();

        // 삭제 대상 이미지 확인
        for (Long imageId : deleteImageList) {

            boolean exists = currentImageList.stream()
                    .anyMatch(img -> img.getImageId().equals(imageId));

            if (!exists) {
                throw new IllegalArgumentException(
                        "잘못된 이미지 삭제 요청입니다.");
            }
        }

        remainingCount -= deleteImageList.size();

        // 신규 이미지 개수 확인
        int newFileCount = 0;

        if (files != null) {

            for (MultipartFile file : files) {

                if (file != null && !file.isEmpty()) {
                    newFileCount++;
                }
            }
        }

        // 이미지 최대 3장 제한
        if (remainingCount + newFileCount > 3) {
            throw new IllegalArgumentException(
                    "리뷰 이미지는 최대 3개까지 등록할 수 있습니다.");
        }

        // 신규 이미지 사전 검사
        if (files != null) {

            for (MultipartFile file : files) {

                if (file == null || file.isEmpty()) {
                    continue;
                }

                if (file.getSize() > 5 * 1024 * 1024) {
                    throw new IllegalArgumentException(
                            "이미지는 한 장당 5MB 이하만 가능합니다.");
                }

                String originName = file.getOriginalFilename();

                if (originName == null || originName.isBlank()) {
                    throw new IllegalArgumentException(
                            "파일명이 올바르지 않습니다.");
                }

                String extName = "";

                int dotIndex = originName.lastIndexOf(".");

                if (dotIndex >= 0) {
                    extName = originName.substring(dotIndex).toLowerCase();
                }

                if (!List.of(".jpg", ".jpeg", ".png").contains(extName)) {
                    throw new IllegalArgumentException(
                            "JPG, JPEG, PNG 파일만 업로드할 수 있습니다.");
                }

                String contentType = file.getContentType();

                if (!List.of("image/jpeg", "image/png").contains(contentType)) {
                    throw new IllegalArgumentException(
                            "JPG, PNG 이미지 파일만 업로드할 수 있습니다.");
                }
            }
        }

        // 리뷰 내용 수정
        int updateCnt = reviewMapper.updateReview(map);

        if (updateCnt == 0) {
            throw new Exception("리뷰 수정에 실패했습니다.");
        }

        // 기존 이미지 실제 파일 경로 수집
        List<Path> deleteFiles = new ArrayList<>();

        if (!deleteImageList.isEmpty()) {

            Path directory = Paths.get(uploadPath)
                    .toAbsolutePath()
                    .normalize();

            for (Long imageId : deleteImageList) {

                currentImageList.stream()
                        .filter(image -> image.getImageId().equals(imageId))
                        .findFirst()
                        .ifPresent(image -> {

                            Path target = directory.resolve(image.getImageName())
                                    .normalize();

                            if (target.startsWith(directory)) {
                                deleteFiles.add(target);
                            }
                        });
            }

            // 기존 이미지 DB 삭제
            HashMap<String, Object> deleteMap = new HashMap<>();

            deleteMap.put("reviewId", reviewId);
            deleteMap.put("deleteImageList", deleteImageList);

            reviewMapper.deleteReviewImage(deleteMap);
        }

        // 신규 이미지 저장
        List<Path> savedFiles = new ArrayList<>();

        try {

            if (files != null && newFileCount > 0) {

                // WebConfig와 동일한 실제 업로드 폴더
                Path directory = Paths.get(uploadPath)
                        .toAbsolutePath()
                        .normalize();

                Files.createDirectories(directory);

                int displayOrder = remainingCount;

                for (MultipartFile file : files) {

                    if (file == null || file.isEmpty()) {
                        continue;
                    }

                    String originName = file.getOriginalFilename();

                    String extName = originName.substring(
                            originName.lastIndexOf(".")).toLowerCase();

                    String contentType = file.getContentType();

                    // 중복되지 않는 파일명 생성
                    String saveName = UUID.randomUUID().toString() + extName;

                    Path target = directory.resolve(saveName).normalize();

                    if (!target.startsWith(directory)) {
                        throw new IllegalArgumentException(
                                "잘못된 파일 경로입니다.");
                    }

                    // 실제 파일 저장
                    file.transferTo(target.toFile());

                    savedFiles.add(target);

                    // 이미지 DB 등록
                    HashMap<String, Object> insertMap = new HashMap<>();

                    insertMap.put("reviewId", reviewId);

                    // WebConfig에서 접근 가능한 URL
                    insertMap.put(
                            "imageUrl",
                            uploadUrl + "/" + saveName);

                    insertMap.put("imageOriginName", originName);
                    insertMap.put("imageName", saveName);
                    insertMap.put("imageSize", String.valueOf(file.getSize()));
                    insertMap.put("imageType", contentType);
                    insertMap.put("displayOrder", displayOrder++);

                    reviewMapper.insertReviewImage(insertMap);
                }
            }

        } catch (Exception e) {

            // 업로드 실패 시 저장된 파일 정리
            for (Path savedFile : savedFiles) {

                try {
                    Files.deleteIfExists(savedFile);

                } catch (Exception fileException) {
                    fileException.printStackTrace();
                }
            }

            throw e;
        }

        resultMap.put("result", "success");
        resultMap.put("message", "리뷰가 수정되었습니다.");

        return resultMap;
    }

    // 리뷰 삭제
    // 리뷰 논리삭제로 변경해서 사진 지우는 메소드 제거
    @Transactional(rollbackFor = Exception.class)
    public HashMap<String, Object> removeReview(HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<>();

        Long memberId = getMemberId(map);
        Long reviewId = Long.parseLong(map.get("reviewId").toString());

        map.put("memberId", memberId);
        map.put("reviewId", reviewId);

        Review review = reviewMapper.selectReview(map);

        if (review == null) {
            resultMap.put("result", "fail");
            resultMap.put("message", "삭제할 리뷰가 없거나 권한이 없습니다.");
            return resultMap;
        }

        int deleteCnt = reviewMapper.deleteReview(map);

        if (deleteCnt > 0) {
            resultMap.put("result", "success");
            resultMap.put("message", "리뷰가 삭제되었습니다.");
        } else {
            throw new RuntimeException("리뷰 삭제에 실패했습니다.");
        }

        return resultMap;
    }

    // 회원 번호 가져오기 (공백 및 null 문자열 방어)
    private Long getMemberId(HashMap<String, Object> map) {
        if (map == null || map.get("memberId") == null) {
            return null;
        }
        String str = String.valueOf(map.get("memberId")).trim();
        if (str.isEmpty() || "null".equalsIgnoreCase(str)) {
            return null;
        }
        return Long.parseLong(str);
    }

    ///////////////////////////////////////////////////////////////////////////////////
    // 상품 또는 패키지 리뷰 목록 조회
    public List<Review> getReviewList(HashMap<String, Object> map) throws Exception {

        List<Review> reviewList = null;

        try {

            boolean hasProductId = map.get("productId") != null
                    && !map.get("productId").toString().isEmpty();

            boolean hasPackageId = map.get("packageId") != null
                    && !map.get("packageId").toString().isEmpty();

            // 상품 또는 패키지 ID 중 하나만 전달되어야 함
            if (hasProductId == hasPackageId) {
                throw new IllegalArgumentException("상품 또는 패키지 ID를 하나만 전달해야 합니다.");
            }

            // 페이지 번호 및 조회 개수 설정
            int page = map.get("page") == null ? 1
                    : Integer.parseInt(map.get("page").toString());

            int limit = 5;
            int offset = (page - 1) * limit;

            map.put("limit", limit);
            map.put("offset", offset);

            // 리뷰 목록 조회
            reviewList = reviewMapper.selectReviewList(map);

            // 조회된 리뷰가 있는 경우 이미지 조회
            if (reviewList != null && !reviewList.isEmpty()) {

                List<Long> reviewIds = new ArrayList<>();

                for (Review review : reviewList) {
                    reviewIds.add(review.getReviewId());
                }

                HashMap<String, Object> imageMap = new HashMap<>();
                imageMap.put("reviewIds", reviewIds);

                List<ReviewImage> imageList = reviewMapper.selectReviewImageList(imageMap);

                // 리뷰별 이미지 연결
                for (Review review : reviewList) {

                    List<ReviewImage> reviewImageList = new ArrayList<>();

                    for (ReviewImage image : imageList) {
                        if (review.getReviewId().equals(image.getReviewId())) {
                            reviewImageList.add(image);
                        }
                    }

                    review.setImageList(reviewImageList);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return reviewList;
    }

    // 상품 또는 패키지 리뷰 전체 개수 조회
    public int getReviewCount(HashMap<String, Object> map) throws Exception {

        int totalCount = 0;

        try {
            totalCount = reviewMapper.selectReviewCount(map);
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return totalCount;
    }

}
