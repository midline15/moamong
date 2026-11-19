package com.mori.moamong.notice.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Notice;

@Mapper
public interface NoticeMapper {

    // 공지사항 목록
    List<Notice> selectNoticeList(HashMap<String, Object> map);

}
