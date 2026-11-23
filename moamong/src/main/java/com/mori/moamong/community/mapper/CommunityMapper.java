package com.mori.moamong.community.mapper;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.mori.moamong.dto.CommunityPost;

@Mapper
public interface CommunityMapper {

    // 게시글 목록
    List<CommunityPost> selectPostList(HashMap<String, Object> map);

    // 게시글 이미지 목록 (여러 게시글 한 번에)
    List<HashMap<String, Object>> selectPostImageList(HashMap<String, Object> map);

    // 게시글 해시태그 목록 (여러 게시글 한 번에)
    List<HashMap<String, Object>> selectPostTagList(HashMap<String, Object> map);

    // 게시글 등록
    int insertPost(HashMap<String, Object> map);

    // 게시글 이미지 등록
    int insertPostImage(HashMap<String, Object> map);

    // 게시글 해시태그 등록
    int insertPostHashtag(HashMap<String, Object> map);

    // 게시글 삭제 (상태 변경)
    int deletePost(HashMap<String, Object> map);

    // 좋아요 등록
    int insertPostLike(HashMap<String, Object> map);

    // 좋아요 취소
    int deletePostLike(HashMap<String, Object> map);

    // 좋아요 수
    int selectPostLikeCnt(HashMap<String, Object> map);

    // 내가 좋아요 눌렀는지 (1/0)
    int selectPostLikeExists(HashMap<String, Object> map);

    // 게시글 전체 개수 (페이징용)
    int selectPostCnt(HashMap<String, Object> map);

    // 관리자 여부 확인 (1/0)
    int selectAdminCnt(HashMap<String, Object> map);

    // 댓글 목록
    List<HashMap<String, Object>> selectCommentList(HashMap<String, Object> map);

    // 댓글 등록
    int insertComment(HashMap<String, Object> map);

    // 댓글 삭제 (상태 변경)
    int deleteComment(HashMap<String, Object> map);

    // 글의 댓글 수 (ACTIVE)
    int selectCommentCnt(HashMap<String, Object> map);

    // 댓글을 달 수 있는 글인지 (1/0)
    int selectPostActiveCnt(HashMap<String, Object> map);

    // 답글을 달 수 있는 부모 댓글인지 (1/0)
    int selectParentCommentCnt(HashMap<String, Object> map);

}