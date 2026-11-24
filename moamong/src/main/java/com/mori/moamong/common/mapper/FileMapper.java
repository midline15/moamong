package com.mori.moamong.common.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface FileMapper {

    // 이 이미지 주소가 이미 어느 글/문의/공지에 연결되어 있는지 (0 이면 임시 파일)
    int selectImageUsedCnt(@Param("url") String url);

}