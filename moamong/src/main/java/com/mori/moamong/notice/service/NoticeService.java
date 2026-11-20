package com.mori.moamong.notice.service;

import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.mori.moamong.dto.Notice;
import com.mori.moamong.notice.mapper.NoticeMapper;

@RequiredArgsConstructor
@Service
public class NoticeService {
    private final NoticeMapper noticeMapper;

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

    // 공지사항 상세 (addView = Y 이면 조회수 +1)
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
                resultMap.put("result", "success");
            }
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 공지사항 등록
    public HashMap<String, Object> addNotice(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            noticeMapper.insertNotice(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 공지사항 수정
    public HashMap<String, Object> updateNotice(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            noticeMapper.updateNotice(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 공지사항 삭제
    public HashMap<String, Object> removeNotice(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            noticeMapper.deleteNotice(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

}