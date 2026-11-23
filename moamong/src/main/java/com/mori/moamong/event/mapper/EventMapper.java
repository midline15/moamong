package com.mori.moamong.event.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Event;

@Mapper
public interface EventMapper {

    // 이벤트 목록
    List<Event> selectEventList(HashMap<String, Object> map);

    // 이벤트 전체 개수 (페이징용)
    int selectEventCnt(HashMap<String, Object> map);

    // 이벤트 상세
    Event selectEvent(HashMap<String, Object> map);

    // 이벤트 등록
    int insertEvent(HashMap<String, Object> map);

    // 이벤트 수정
    int updateEvent(HashMap<String, Object> map);

    // 이벤트 삭제
    int deleteEvent(HashMap<String, Object> map);

    // 이벤트 이미지 목록
    List<HashMap<String, Object>> selectEventImageList(HashMap<String, Object> map);

    // 이벤트 이미지 등록
    int insertEventImage(HashMap<String, Object> map);

    // 이벤트 이미지 전체 삭제 (이벤트 기준)
    int deleteEventImage(HashMap<String, Object> map);

}