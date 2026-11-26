package com.mori.moamong.event.service;

import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mori.moamong.dto.Event;
import com.mori.moamong.event.mapper.EventMapper;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class EventService {
@Autowired
EventMapper eventMapper;
    // 이벤트 목록 (상태 필터 + 페이징, 카드 6개씩)
    public HashMap<String, Object> getEventList(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            // 페이징 계산
            int page = Integer.parseInt(String.valueOf(map.getOrDefault("page", "1")));
            int pageSize = 6;
            map.put("startNum", (page - 1) * pageSize);
            map.put("pageSize", pageSize);

            List<Event> list = eventMapper.selectEventList(map);
            int cnt = eventMapper.selectEventCnt(map);

            resultMap.put("list", list);
            resultMap.put("cnt", cnt);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 이벤트 상세 (이미지 목록 포함)
    public HashMap<String, Object> getEvent(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            Event info = eventMapper.selectEvent(map);

            if (info == null) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "존재하지 않는 이벤트입니다.");
            } else {
                resultMap.put("info", info);
                resultMap.put("imageList", eventMapper.selectEventImageList(map));
                resultMap.put("result", "success");
            }
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 이벤트 등록 (이미지 함께 저장)
    @Transactional
    public HashMap<String, Object> addEvent(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            eventMapper.insertEvent(map);       // 생성된 eventId가 map에 담김
            saveEventImages(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 이벤트 수정 (이미지는 지우고 다시 저장)
    @Transactional
    public HashMap<String, Object> updateEvent(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            eventMapper.updateEvent(map);
            eventMapper.deleteEventImage(map);
            saveEventImages(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 이벤트 삭제 (FK 때문에 이미지 먼저 삭제)
    @Transactional
    public HashMap<String, Object> removeEvent(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            eventMapper.deleteEventImage(map);
            eventMapper.deleteEvent(map);
            resultMap.put("result", "success");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 이미지 기록 저장 (썸네일 1개 + 본문 이미지들)
    private void saveEventImages(HashMap<String, Object> map) {

        // 썸네일 (display_order 0)
        Object thumb = map.get("thumbnail");
        if (thumb != null && !String.valueOf(thumb).trim().isEmpty() && !"null".equals(String.valueOf(thumb))) {
            HashMap<String, Object> img = new Gson().fromJson(
                    String.valueOf(thumb),
                    new TypeToken<HashMap<String, Object>>() {}.getType());
            img.put("eventId", map.get("eventId"));
            img.put("imageType", "THUMBNAIL");
            img.put("displayOrder", 0);
            eventMapper.insertEventImage(img);
        }

        // 본문 이미지 (display_order 1부터)
        Object json = map.get("images");
        if (json == null || String.valueOf(json).trim().isEmpty()) return;

        List<HashMap<String, Object>> images = new Gson().fromJson(
                String.valueOf(json),
                new TypeToken<List<HashMap<String, Object>>>() {}.getType());

        int order = 1;
        for (HashMap<String, Object> img : images) {
            img.put("eventId", map.get("eventId"));
            img.put("imageType", "DETAIL");
            img.put("displayOrder", order++);
            eventMapper.insertEventImage(img);
        }
    }

        // 메인 슬라이더용 이벤트 목록
    public HashMap<String, Object> getMainEventList() {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            resultMap.put("list", eventMapper.selectMainEventList());
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

}