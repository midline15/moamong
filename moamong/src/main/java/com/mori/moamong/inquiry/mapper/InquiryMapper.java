package com.mori.moamong.inquiry.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Inquiry;

@Mapper
public interface InquiryMapper {

    List<Inquiry> selectInquiryList(HashMap<String, Object> map);
}
