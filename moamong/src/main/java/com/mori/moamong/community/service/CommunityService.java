package com.mori.moamong.community.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.interceptor.TransactionAspectSupport;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.mori.moamong.community.mapper.CommunityMapper;
import com.mori.moamong.dto.CommunityPost;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class CommunityService {
    private final CommunityMapper communityMapper;

    private static final int PAGE_SIZE = 5; // 한 번에 불러올 게시글 수
    private static final int MAX_CONTENT = 1000; // 본문 최대 글자 수
    private static final int MAX_COMMENT = 1000; // 댓글 최대 글자 수
    private static final int MAX_IMAGE = 4; // 게시글당 최대 이미지 수
    private static final int MAX_TAG = 10; // 게시글당 최대 해시태그 수
    private static final Pattern TAG_PATTERN = Pattern.compile("#([0-9A-Za-z_가-힣]{1,30})");
    private static final int MAX_PRODUCT = 3; // 게시글당 최대 상품(단품+패키지) 수

    // 상품 종류
    private static final String TYPE_PRODUCT = "PRODUCT"; // 단품
    private static final String TYPE_PACKAGE = "PACKAGE"; // 패키지

    // 상세 페이지 주소 (종류에 따라 다름)
    private String itemUrl(Object type, Object id) {
        if (TYPE_PACKAGE.equals(String.valueOf(type))) {
            return "/package/view.do?packageId=" + id;
        }
        return "/product/view.do?productId=" + id;
    }

    // 게시글 목록 (스크롤 방식, page 번호로 이어서 조회)
    public HashMap<String, Object> getPostList(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            int page = Integer.parseInt(String.valueOf(map.getOrDefault("page", "1")));
            if (page < 1)
                page = 1;
            map.put("startNum", (page - 1) * PAGE_SIZE);
            map.put("pageSize", PAGE_SIZE);

            List<CommunityPost> list = communityMapper.selectPostList(map);
            int cnt = communityMapper.selectPostCnt(map);

            // 이미지, 해시태그, 상품은 한 번에 조회해서 게시글에 붙이기
            if (!list.isEmpty()) {
                List<Long> ids = new ArrayList<Long>();
                for (CommunityPost p : list)
                    ids.add(p.getPostId());
                map.put("postIdList", ids);

                // 1) 이미지를 글 번호별로 묶기
                HashMap<String, List<HashMap<String, Object>>> imageMap = new HashMap<String, List<HashMap<String, Object>>>();
                for (HashMap<String, Object> img : communityMapper.selectPostImageList(map)) {
                    String key = String.valueOf(img.get("postId"));
                    if (!imageMap.containsKey(key))
                        imageMap.put(key, new ArrayList<HashMap<String, Object>>());
                    imageMap.get(key).add(img);
                }

                // 2) 해시태그를 글 번호별로 묶기
                HashMap<String, List<String>> tagMap = new HashMap<String, List<String>>();
                for (HashMap<String, Object> tag : communityMapper.selectPostTagList(map)) {
                    String key = String.valueOf(tag.get("postId"));
                    if (!tagMap.containsKey(key))
                        tagMap.put(key, new ArrayList<String>());
                    tagMap.get(key).add(String.valueOf(tag.get("tagName")));
                }

                // 2-1) 첨부 상품(단품/패키지)을 글 번호별로 묶기 (실패해도 글 목록은 보이게)
                HashMap<String, List<HashMap<String, Object>>> productMap = new HashMap<String, List<HashMap<String, Object>>>();
                try {
                    for (HashMap<String, Object> pr : communityMapper.selectPostProductList(map)) {
                        pr.put("itemUrl", itemUrl(pr.get("itemType"), pr.get("itemId")));
                        String key = String.valueOf(pr.get("postId"));
                        if (!productMap.containsKey(key))
                            productMap.put(key, new ArrayList<HashMap<String, Object>>());
                        productMap.get(key).add(pr);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                // 3) 글에 붙이기 (관리자가 지운 글은 비워서 내려줌)
                for (CommunityPost p : list) {
                    if ("HIDDEN".equals(p.getPostStatus())) {
                        p.setImageList(new ArrayList<HashMap<String, Object>>());
                        p.setTagList(new ArrayList<String>());
                        p.setProductList(new ArrayList<HashMap<String, Object>>());
                        continue;
                    }
                    String key = String.valueOf(p.getPostId());
                    p.setImageList(
                            imageMap.containsKey(key) ? imageMap.get(key) : new ArrayList<HashMap<String, Object>>());
                    p.setTagList(tagMap.containsKey(key) ? tagMap.get(key) : new ArrayList<String>());
                    p.setProductList(productMap.containsKey(key) ? productMap.get(key)
                            : new ArrayList<HashMap<String, Object>>());
                }
            }

            resultMap.put("list", list);
            resultMap.put("cnt", cnt);
            resultMap.put("pageSize", PAGE_SIZE);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 최근 7일 구매 상품 (단품 + 패키지)
    public HashMap<String, Object> getBuyList(long memberId) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            HashMap<String, Object> map = new HashMap<String, Object>();
            map.put("memberId", memberId);
            List<HashMap<String, Object>> list = communityMapper.selectBuyList(map);

            // 상세 페이지 주소는 서버에서 내려줌
            for (HashMap<String, Object> b : list) {
                b.put("itemUrl", itemUrl(b.get("itemType"), b.get("itemId")));
            }
            resultMap.put("list", list);
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 게시글 등록 (해시태그, 이미지, 구매 상품 함께 저장)
    @Transactional
    public HashMap<String, Object> addPost(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            String content = String.valueOf(map.getOrDefault("postContent", "")).trim();

            if (content.length() > MAX_CONTENT) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "내용은 " + MAX_CONTENT + "자까지 입력할 수 있습니다.");
                return resultMap;
            }

            // 본문에서 해시태그 뽑기 (중복 제거)
            LinkedHashSet<String> tags = new LinkedHashSet<String>();
            Matcher m = TAG_PATTERN.matcher(content);
            while (m.find() && tags.size() < MAX_TAG) {
                tags.add(m.group(1));
            }

            // 본문에서는 해시태그를 빼고 저장
            String text = TAG_PATTERN.matcher(content).replaceAll("").replaceAll("[ \\t]{2,}", " ").trim();

            if (text.isEmpty()) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "내용을 입력해주세요.");
                return resultMap;
            }

            // 제목은 본문 첫 줄 (최대 50자)
            String title = text.split("\n")[0].trim();
            if (title.length() > 50)
                title = title.substring(0, 50);

            // 첨부 상품 검증: 최대 3개, 내가 최근 7일 안에 구매한 단품/패키지만
            List<String> itemKeys = parseItems(map); // "PRODUCT:19", "PACKAGE:36" 형태
            if (itemKeys.size() > MAX_PRODUCT) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "상품은 최대 " + MAX_PRODUCT + "개까지 선택할 수 있습니다.");
                return resultMap;
            }
            if (!itemKeys.isEmpty()) {
                HashSet<String> boughtKeys = new HashSet<String>();
                for (HashMap<String, Object> b : communityMapper.selectBuyList(map)) {
                    boughtKeys.add(String.valueOf(b.get("itemType")) + ":" + String.valueOf(b.get("itemId")));
                }
                if (!boughtKeys.containsAll(itemKeys)) {
                    resultMap.put("result", "fail");
                    resultMap.put("msg", "최근 7일 안에 구매한 상품만 붙일 수 있습니다.");
                    return resultMap;
                }
            }

            map.put("postTitle", title);
            map.put("postContent", text);
            communityMapper.insertPost(map); // 생성된 postId가 map에 담김

            // 해시태그 저장
            for (String tag : tags) {
                HashMap<String, Object> tagMap = new HashMap<String, Object>();
                tagMap.put("postId", map.get("postId"));
                tagMap.put("tagName", tag);
                communityMapper.insertPostHashtag(tagMap);
            }

            // 이미지 저장
            saveImages(map);

            // 구매 상품 저장
            int pOrder = 1;
            for (String key : itemKeys) {
                String[] parts = key.split(":");
                HashMap<String, Object> pMap = new HashMap<String, Object>();
                pMap.put("postId", map.get("postId"));
                pMap.put("itemType", parts[0]);
                pMap.put("itemId", Long.parseLong(parts[1]));
                pMap.put("displayOrder", pOrder++);
                communityMapper.insertPostProduct(pMap);
            }

            resultMap.put("result", "success");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 화면에서 JSON 으로 넘어온 products([{type:"PRODUCT", id:19}, ...]) 파싱, 중복 제거
    // 결과는 "PRODUCT:19" 같은 문자열 목록
    private List<String> parseItems(HashMap<String, Object> map) {
        String json = String.valueOf(map.getOrDefault("products", "")).trim();
        if (json.isEmpty() || "null".equals(json))
            return new ArrayList<String>();

        List<HashMap<String, Object>> raw = new Gson().fromJson(json,
                new TypeToken<List<HashMap<String, Object>>>() {
                }.getType());

        LinkedHashSet<String> keys = new LinkedHashSet<String>();
        if (raw != null) {
            for (HashMap<String, Object> r : raw) {
                String type = String.valueOf(r.get("type"));
                if (!TYPE_PRODUCT.equals(type) && !TYPE_PACKAGE.equals(type))
                    continue;
                Object id = r.get("id");
                if (!(id instanceof Number))
                    continue;
                keys.add(type + ":" + ((Number) id).longValue());
            }
        }
        return new ArrayList<String>(keys);
    }

    // 관리자 여부 (role 이 ADMIN 이고 활성 계정이면 true)
    public boolean isAdmin(long memberId) {
        try {
            HashMap<String, Object> map = new HashMap<String, Object>();
            map.put("memberId", memberId);
            return communityMapper.selectAdminCnt(map) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 게시글 삭제 (본인 글 또는 관리자, 상태만 DELETED 로 변경)
    public HashMap<String, Object> removePost(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            int cnt = communityMapper.deletePost(map);

            if (cnt == 0) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "삭제할 수 없는 게시글입니다.");
            } else {
                resultMap.put("result", "success");
            }
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 좋아요 토글 (한 계정당 1번, 이미 눌렀으면 취소)
    @Transactional
    public HashMap<String, Object> toggleLike(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            boolean liked;

            if (communityMapper.selectPostLikeExists(map) > 0) {
                communityMapper.deletePostLike(map); // 이미 눌렀으면 취소
                liked = false;
            } else {
                communityMapper.insertPostLike(map); // 처음이면 등록
                liked = true;
            }

            resultMap.put("liked", liked);
            resultMap.put("likeCnt", communityMapper.selectPostLikeCnt(map));
            resultMap.put("result", "success");
        } catch (Exception e) {
            TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 댓글 목록 (글 하나의 댓글 전체, 화면에서 대댓글로 묶음)
    public HashMap<String, Object> getCommentList(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            resultMap.put("list", communityMapper.selectCommentList(map));
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 댓글 등록 (대댓글은 1단계까지)
    public HashMap<String, Object> addComment(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            String content = String.valueOf(map.getOrDefault("commentContent", "")).trim();

            if (content.isEmpty()) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "댓글 내용을 입력해주세요.");
                return resultMap;
            }
            if (content.length() > MAX_COMMENT) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "댓글은 " + MAX_COMMENT + "자까지 입력할 수 있습니다.");
                return resultMap;
            }
            map.put("commentContent", content);

            // 삭제/숨김 처리된 글에는 댓글을 달 수 없음
            if (communityMapper.selectPostActiveCnt(map) == 0) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "댓글을 달 수 없는 게시글입니다.");
                return resultMap;
            }

            // 대댓글이면 부모가 같은 글의 최상위 댓글인지 확인
            String parent = String.valueOf(map.getOrDefault("parentCommentId", "")).trim();
            if (parent.isEmpty() || "null".equals(parent)) {
                map.put("parentCommentId", null);
            } else {
                map.put("parentCommentId", Long.parseLong(parent));
                if (communityMapper.selectParentCommentCnt(map) == 0) {
                    resultMap.put("result", "fail");
                    resultMap.put("msg", "답글을 달 수 없는 댓글입니다.");
                    return resultMap;
                }
            }

            communityMapper.insertComment(map);

            resultMap.put("commentCnt", communityMapper.selectCommentCnt(map));
            resultMap.put("result", "success");
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 댓글 삭제 (본인 댓글 또는 관리자, 상태만 DELETED 로 변경)
    public HashMap<String, Object> removeComment(HashMap<String, Object> map) {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();
        try {
            int cnt = communityMapper.deleteComment(map);

            if (cnt == 0) {
                resultMap.put("result", "fail");
                resultMap.put("msg", "삭제할 수 없는 댓글입니다.");
            } else {
                resultMap.put("commentCnt", communityMapper.selectCommentCnt(map));
                resultMap.put("result", "success");
            }
        } catch (Exception e) {
            resultMap.put("result", "fail");
            e.printStackTrace();
        }
        return resultMap;
    }

    // 이미지 기록 저장 (화면에서 JSON 문자열로 넘어온 images 처리)
    private void saveImages(HashMap<String, Object> map) {
        Object json = map.get("images");
        if (json == null || String.valueOf(json).trim().isEmpty())
            return;

        List<HashMap<String, Object>> images = new Gson().fromJson(
                String.valueOf(json),
                new TypeToken<List<HashMap<String, Object>>>() {
                }.getType());

        int order = 1;
        for (HashMap<String, Object> img : images) {
            if (order > MAX_IMAGE)
                break;

            // 우리 서버에 올린 이미지 주소만 허용 (커뮤니티 폴더만)
            String url = String.valueOf(img.get("imageUrl"));
            if (!url.startsWith("/resources/upload/community/"))
                continue;

            img.put("postId", map.get("postId"));
            img.put("imageType", "DETAIL");
            img.put("displayOrder", order++);
            communityMapper.insertPostImage(img);
        }
    }

}