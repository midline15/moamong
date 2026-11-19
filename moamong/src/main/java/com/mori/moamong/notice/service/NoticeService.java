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


    public HashMap<String, Object> getNoticeList(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap();
		try {
			
			List<Notice> list = noticeMapper.selectNoticeList(map);
			
			resultMap.put("list", list);
			resultMap.put("result", "success");
		} catch (Exception e) {
			// TODO: handle exception
			resultMap.put("result", "fail");
			e.printStackTrace();
		}
		return resultMap;
	}

}
