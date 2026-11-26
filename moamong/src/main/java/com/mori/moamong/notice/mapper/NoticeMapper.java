package com.mori.moamong.notice.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.Notice;

@Mapper
public interface NoticeMapper {

    // 공지사항 목록
    List<Notice> selectNoticeList(HashMap<String, Object> map);

    // 공지사항 전체 개수 (페이징용)
    int selectNoticeCnt(HashMap<String, Object> map);

    // 공지사항 상세
    Notice selectNotice(HashMap<String, Object> map);

    // 조회수 증가
    int updateNoticeViewCount(HashMap<String, Object> map);

    // 공지사항 등록
    int insertNotice(HashMap<String, Object> map);

    // 공지사항 수정
    int updateNotice(HashMap<String, Object> map);

    // 공지사항 삭제
    int deleteNotice(HashMap<String, Object> map);

    // 공지사항 이미지 목록
    List<HashMap<String, Object>> selectNoticeImageList(HashMap<String, Object> map);

    // 공지사항 이미지 등록
    int insertNoticeImage(HashMap<String, Object> map);

    // 공지사항 이미지 전체 삭제 (공지 기준)
    int deleteNoticeImage(HashMap<String, Object> map);

    // 관리자 여부 확인 (1/0)
    int selectAdminCnt(HashMap<String, Object> map);

}