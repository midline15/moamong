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

    // 관리자 여부 (ROLE 이 ADMIN 이고 탈퇴 상태가 아니면 true)
    public boolean isAdmin(long memberId) {
        try {
            HashMap<String, Object> map = new HashMap<String, Object>();
            map.put("memberId", memberId);
            return inquiryMapper.selectAdminCnt(map) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 비밀글 값 정리 (1 / 0)
    private int secretValue(Object v) {
        String s = String.valueOf(v);
        return ("1".equals(s) || "true".equals(s)) ? 1 : 0;
    }

    // 1:1문의 목록 (전체 공개, 검색 + 페이징)
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

    // 1:1문의 상세 (비밀글은 작성자/관리자만, 이미지 목록 포함)
    public HashMap<String, Object> getInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            Inquiry info = inquiryMapper.selectInquiry(map);

            if (info == null) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "존재하지 않는 문의입니다.");
                return resultMap;
            }

            boolean secret = Boolean.TRUE.equals(info.getIsSecret());
            boolean owner = String.valueOf(info.getMemberId()).equals(String.valueOf(map.get("viewerId")));
            boolean admin = "Y".equals(map.get("isAdmin"));

            if (secret && !owner && !admin) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "비밀글입니다.");
                return resultMap;
            }

            resultMap.put("info", info);
            resultMap.put("imageList", inquiryMapper.selectInquiryImageList(map));
            resultMap.put("result", "success");
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
            map.put("isSecret", secretValue(map.get("isSecret")));
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

    // 1:1문의 수정 (작성자만, 답변 대기 상태만, 이미지는 지우고 다시 저장)
    @Transactional
    public HashMap<String, Object> updateInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            map.put("isSecret", secretValue(map.get("isSecret")));
            int cnt = inquiryMapper.updateInquiry(map);

            if (cnt == 0) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "수정할 수 없는 문의입니다. (답변 완료 또는 권한 없음)");
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

    // 1:1문의 답변 등록/수정 (관리자, 컨트롤러에서 권한 확인함)
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

    // 1:1문의 삭제 (작성자 또는 관리자, 이미지 기록도 함께 삭제)
    @Transactional
    public HashMap<String, Object> removeInquiry(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            Inquiry info = inquiryMapper.selectInquiry(map);

            if (info == null) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "존재하지 않는 문의입니다.");
                return resultMap;
            }

            boolean owner = String.valueOf(info.getMemberId()).equals(String.valueOf(map.get("viewerId")));
            boolean admin = "Y".equals(map.get("isAdmin"));

            if (!owner && !admin) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "회원님이 작성한 문의만 삭제할 수 있어요.");
                return resultMap;
            }

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