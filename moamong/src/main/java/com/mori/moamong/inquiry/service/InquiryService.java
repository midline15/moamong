package com.mori.moamong.inquiry.service;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mori.moamong.dto.Inquiry;
import com.mori.moamong.inquiry.mapper.InquiryMapper;

@RequiredArgsConstructor
@Service
public class InquiryService {
    private final InquiryMapper inquiryMapper;

    // 1:1문의 목록 (검색 + 페이징)
    public HashMap<String, Object> getInquiryList(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            // 페이징 계산
            int page = Integer.parseInt(String.valueOf(map.getOrDefault("page", "1")));
            int pageSize = 10;
            map.put("startNum", (page - 1) * pageSize);
            map.put("pageSize", pageSize);

            List<Inquiry> list = inquiryMapper.selectInquiryList(map);
            int cnt = inquiryMapper.selectInquiryCnt(map);

            resultMap.put("list", list);
            resultMap.put("cnt", cnt);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 1:1문의 상세 (이미지 목록 포함)
    public HashMap<String, Object> getInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            Inquiry info = inquiryMapper.selectInquiry(map);

            if (info == null) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "존재하지 않는 문의입니다.");
            } else {
                resultMap.put("info", info);
                resultMap.put("imageList", inquiryMapper.selectInquiryImageList(map));
                resultMap.put("result", "success");
            }
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 1:1문의 등록 (이미지 함께 저장)
    @Transactional
    public HashMap<String, Object> addInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            inquiryMapper.insertInquiry(map);   // 생성된 inqId가 map에 담김
            saveInquiryImages(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 1:1문의 수정 (답변 대기 상태만, 이미지는 지우고 다시 저장)
    @Transactional
    public HashMap<String, Object> updateInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            int cnt = inquiryMapper.updateInquiry(map);

            if (cnt == 0) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "답변이 완료된 문의는 수정할 수 없습니다.");
            } else {
                inquiryMapper.deleteInquiryImage(map);
                saveInquiryImages(map);
                resultMap.put("result", "success");
            }
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 1:1문의 답변 등록/수정 (관리자)
    public HashMap<String, Object> answerInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            inquiryMapper.updateInquiryAnswer(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 1:1문의 삭제 (이미지 기록도 함께 삭제)
    @Transactional
    public HashMap<String, Object> removeInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            inquiryMapper.deleteInquiryImage(map);
            inquiryMapper.deleteInquiry(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 이미지 기록 저장 (화면에서 JSON 문자열로 넘어온 images 처리)
    private void saveInquiryImages(HashMap<String, Object> map) {
        Object json = map.get("images");
        if (json == null || String.valueOf(json).trim().isEmpty()) return;

        List<HashMap<String, Object>> images = new Gson().fromJson(
                String.valueOf(json),
                new TypeToken<List<HashMap<String, Object>>>() {}.getType());

        int order = 1;
        for (HashMap<String, Object> img : images) {
            img.put("inqId", map.get("inqId"));
            img.put("displayOrder", order++);
            inquiryMapper.insertInquiryImage(img);
        }
    }

}