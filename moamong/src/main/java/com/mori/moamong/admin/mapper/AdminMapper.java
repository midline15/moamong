package com.mori.moamong.admin.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.admin.model.Admin;

@Mapper
public interface AdminMapper {
	List<Admin> selectAdminList (HashMap<String, Object> map); 


	Admin selectStats(HashMap<String, Object> map); 
}
