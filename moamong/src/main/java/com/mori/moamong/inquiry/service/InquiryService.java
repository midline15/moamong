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

     public HashMap<String, Object> getInquiryList(HashMap<String, Object> map) {
		HashMap<String, Object> resultMap = new HashMap();
		try {
			
			List<Inquiry> list = inquiryMapper.selectInquiryList(map);
			
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
