package com.mori.moamong.productInq.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mori.moamong.dto.ProductInq;
import com.mori.moamong.productInq.mapper.ProductInqMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ProductInqService {
    private final ProductInqMapper productInqMapper;

    // 상품 ID 또는 패키지 ID 전달 여부 확인
    private boolean hasTargetId(HashMap<String, Object> map) {
        Object productId = map.get("productId");
        Object packageId = map.get("packageId");

        return (productId != null && !productId.toString().trim().isEmpty())
                || (packageId != null && !packageId.toString().trim().isEmpty());
    }

    // 상품 문의 목록 조회
    public HashMap<String, Object> getProductInqList(HashMap<String, Object> map) {

        HashMap<String, Object> result = new HashMap<>();

        try {

            // 상품 ID 또는 패키지 ID 확인
            if (!hasTargetId(map)) {
                result.put("inquiryList", List.of());
                result.put("totalCount", 0);
                result.put("filteredCount", 0);
                result.put("answeredCount", 0);
                result.put("waitingCount", 0);
                return result;
            }

            int page = Integer.parseInt(map.get("page").toString());
            int limit = 5;
            int offset = (page - 1) * limit;

            map.put("limit", limit);
            map.put("offset", offset);

            List<ProductInq> inquiryList = productInqMapper.selectProductInqList(map);

            int totalCount = productInqMapper.selectProductInqCount(map);
            int filteredCount = productInqMapper.selectProductInqFilteredCount(map);
            int answeredCount = productInqMapper.selectProductInqAnsweredCount(map);
            int waitingCount = productInqMapper.selectProductInqWaitingCount(map);

            result.put("inquiryList", inquiryList);
            result.put("totalCount", totalCount);
            result.put("filteredCount", filteredCount);
            result.put("answeredCount", answeredCount);
            result.put("waitingCount", waitingCount);

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return result;
    }

    // 상품 문의 등록
    public HashMap<String, Object> addProductInq(HashMap<String, Object> map) {

        HashMap<String, Object> result = new HashMap<>();

        try {
            // 상품 ID 또는 패키지 ID 확인
            if (!hasTargetId(map)) {
                result.put("result", "fail");
                result.put("message", "문의 대상을 확인할 수 없습니다.");
                return result;
            }

            // 문의 내용 확인
            if (map.get("inqContent") == null
                    || map.get("inqContent").toString().trim().isEmpty()) {
                result.put("result", "fail");
                result.put("message", "문의 내용을 입력해 주세요.");
                return result;
            }

            // 비밀 문의 여부 확인
            String isSecret = map.get("isSecret") == null
                    ? "N"
                    : map.get("isSecret").toString();

            if (!isSecret.equals("Y") && !isSecret.equals("N")) {
                result.put("result", "fail");
                result.put("message", "비밀 문의 설정이 올바르지 않습니다.");
                return result;
            }

            map.put("isSecret", isSecret);

            int cnt = productInqMapper.insertProductInq(map);

            if (cnt > 0) {
                result.put("result", "success");
            } else {
                result.put("result", "fail");
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }

        return result;
    }

    // 상품 문의 답변 등록
    public HashMap<String, Object> addProductInqAnswer(HashMap<String, Object> map) {
        HashMap<String, Object> result = new HashMap<>();
        try {
            if (map.get("answerContent") == null
                    || map.get("answerContent").toString().trim().isEmpty()) {
                result.put("result", "fail");
                result.put("message", "답변 내용을 입력해 주세요.");
                return result;
            }

            int cnt = productInqMapper.updateProductInqAnswer(map);

            if (cnt > 0) {
                result.put("result", "success");
            } else {
                result.put("result", "fail");
                result.put("message", "답변 등록에 실패했습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
        return result;
    }

    // 상품 문의 수정
    public HashMap<String, Object> editProductInq(HashMap<String, Object> map) {
        HashMap<String, Object> result = new HashMap<>();
        try {
            if (map.get("inqContent") == null
                    || map.get("inqContent").toString().trim().isEmpty()) {
                result.put("result", "fail");
                result.put("message", "문의 내용을 입력해 주세요.");
                return result;
            }

            int cnt = productInqMapper.updateProductInq(map);

            if (cnt > 0) {
                result.put("result", "success");
            } else {
                result.put("result", "fail");
                result.put("message", "수정할 수 없는 문의입니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
        return result;
    }

    // 상품 문의 삭제
    public HashMap<String, Object> removeProductInq(HashMap<String, Object> map) {
        HashMap<String, Object> result = new HashMap<>();
        try {
            int cnt = productInqMapper.deleteProductInq(map);

            if (cnt > 0) {
                result.put("result", "success");
            } else {
                result.put("result", "fail");
                result.put("message", "삭제할 수 없는 문의입니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
        return result;
    }

    // 상품 문의 답변 수정
    public HashMap<String, Object> editProductInqAnswer(HashMap<String, Object> map) {
        HashMap<String, Object> result = new HashMap<>();
        try {
            if (map.get("answerContent") == null
                    || map.get("answerContent").toString().trim().isEmpty()) {
                result.put("result", "fail");
                result.put("message", "답변 내용을 입력해 주세요.");
                return result;
            }

            int cnt = productInqMapper.updateProductInqAnswerEdit(map);

            if (cnt > 0) {
                result.put("result", "success");
            } else {
                result.put("result", "fail");
                result.put("message", "답변 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
        return result;
    }

    // 상품 문의 답변 삭제
    public HashMap<String, Object> removeProductInqAnswer(HashMap<String, Object> map) {
        HashMap<String, Object> result = new HashMap<>();
        try {
            int cnt = productInqMapper.deleteProductInqAnswer(map);

            if (cnt > 0) {
                result.put("result", "success");
            } else {
                result.put("result", "fail");
                result.put("message", "답변 삭제에 실패했습니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
        return result;
    }

}
