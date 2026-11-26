package com.mori.moamong.info.mapper;

import java.util.HashMap;
import java.util.List;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface InfoMapper {
    List<HashMap<String, Object>> selectActivePolicies();
}
