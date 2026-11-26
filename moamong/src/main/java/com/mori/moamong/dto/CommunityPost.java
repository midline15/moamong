package com.mori.moamong.dto;

import java.util.HashMap;
import java.util.List;

import lombok.Data;

@Data
public class CommunityPost {
    private Long postId;
    private Long memberId;
    private String postContent;
    private String createdAt;
    private String displayName; // 표시 이름 (login_id 또는 마스킹된 이름)
    private String socialType; // KAKAO / NAVER / GOOGLE / null
    private int likeCnt; // 좋아요 수
    private int commentCnt; // 댓글 수
    private int liked; // 내가 좋아요 눌렀는지 (1/0)
    private List<HashMap<String, Object>> imageList; // 게시글 이미지
    private List<String> tagList; // 해시태그
    private String postStatus; // ACTIVE / HIDDEN (관리자 삭제)
    private String role;
    private List<HashMap<String, Object>> productList;
}