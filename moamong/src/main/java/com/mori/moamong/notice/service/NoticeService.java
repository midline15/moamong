package com.mori.moamong.notice.service;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mori.moamong.dto.Notice;
import com.mori.moamong.notice.mapper.NoticeMapper;

@RequiredArgsConstructor
@Service
public class NoticeService {
    private final NoticeMapper noticeMapper;

    // 관리자 여부 (ROLE 이 ADMIN 이고 탈퇴 상태가 아니면 true)
    public boolean isAdmin(long memberId) {
        try {
            HashMap<String, Object> map = new HashMap<String, Object>();
            map.put("memberId", memberId);
            return noticeMapper.selectAdminCnt(map) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 공지사항 목록 (검색 + 페이징)
    public HashMap<String, Object> getNoticeList(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            // 페이징 계산
            int page = Integer.parseInt(String.valueOf(map.getOrDefault("page", "1")));
            int pageSize = 10;
            map.put("startNum", (page - 1) * pageSize);
            map.put("pageSize", pageSize);

            List<Notice> list = noticeMapper.selectNoticeList(map);
            int cnt = noticeMapper.selectNoticeCnt(map);

            resultMap.put("list", list);
            resultMap.put("cnt", cnt);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 공지사항 상세 (addView = Y 이면 조회수 +1, 이미지 목록 포함)
    public HashMap<String, Object> getNotice(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            if ("Y".equals(map.get("addView"))) {
                noticeMapper.updateNoticeViewCount(map);
            }

            Notice info = noticeMapper.selectNotice(map);

            if (info == null) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "존재하지 않는 공지사항입니다.");
            } else {
                resultMap.put("info", info);
                resultMap.put("imageList", noticeMapper.selectNoticeImageList(map));
                resultMap.put("result", "success");
            }
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 공지사항 등록 (이미지 함께 저장)
    @Transactional
    public HashMap<String, Object> addNotice(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            noticeMapper.insertNotice(map); // 생성된 noticeId가 map에 담김
            saveNoticeImages(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 공지사항 수정 (이미지는 지우고 다시 저장)
    @Transactional
    public HashMap<String, Object> updateNotice(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            noticeMapper.updateNotice(map);
            noticeMapper.deleteNoticeImage(map);
            saveNoticeImages(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 공지사항 삭제 (FK 때문에 이미지 먼저 삭제)
    @Transactional
    public HashMap<String, Object> removeNotice(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            noticeMapper.deleteNoticeImage(map);
            noticeMapper.deleteNotice(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 이미지 기록 저장 (화면에서 JSON 문자열로 넘어온 images 처리)
    private void saveNoticeImages(HashMap<String, Object> map) {
        Object json = map.get("images");
        if (json == null || String.valueOf(json).trim().isEmpty())
            return;

        List<HashMap<String, Object>> images = new Gson().fromJson(
                String.valueOf(json),
                new TypeToken<List<HashMap<String, Object>>>() {
                }.getType());

        int order = 1;
        for (HashMap<String, Object> img : images) {
            img.put("noticeId", map.get("noticeId"));
            img.put("displayOrder", order++);
            noticeMapper.insertNoticeImage(img);
        }
    }

}