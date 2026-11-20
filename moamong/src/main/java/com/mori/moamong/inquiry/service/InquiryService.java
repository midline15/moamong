package com.mori.moamong.inquiry.service;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

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

    // 1:1문의 상세
    public HashMap<String, Object> getInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            Inquiry info = inquiryMapper.selectInquiry(map);

            if (info == null) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "존재하지 않는 문의입니다.");
            } else {
                resultMap.put("info", info);
                resultMap.put("result", "success");
            }
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 1:1문의 등록
    public HashMap<String, Object> addInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            inquiryMapper.insertInquiry(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 1:1문의 수정 (답변 대기 상태만)
    public HashMap<String, Object> updateInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            int cnt = inquiryMapper.updateInquiry(map);

            if (cnt == 0) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "답변이 완료된 문의는 수정할 수 없습니다.");
            } else {
                resultMap.put("result", "success");
            }
        } catch (Exception e) {
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

    // 1:1문의 삭제
    public HashMap<String, Object> removeInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            inquiryMapper.deleteInquiry(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

}