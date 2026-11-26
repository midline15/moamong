
package com.mori.moamong.review.controller;

import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.google.gson.Gson;
import com.mori.moamong.dto.Review;
import com.mori.moamong.review.service.ReviewService;

@Controller
public class ReviewController {

	@Autowired
	private ReviewService reviewService;

	// 세션에서 memberId 자동 보완용 헬퍼 메서드
	private void fillMemberId(HashMap<String, Object> map, jakarta.servlet.http.HttpSession session) {
		Object val = map.get("memberId");
		if ((val == null || String.valueOf(val).trim().isEmpty() || "null".equals(String.valueOf(val)))
				&& session.getAttribute("sessionId") != null) {
			map.put("memberId", session.getAttribute("sessionId"));
		}
	}

	// 1. 나의 리뷰 페이지 이동
	@RequestMapping("/review/myReview.do")
	public String myReview(@RequestParam HashMap<String, Object> map, jakarta.servlet.http.HttpSession session,
			Model model) {
		fillMemberId(map, session);
		model.addAttribute("memberId", map.get("memberId"));
		return "review/list";
	}

	// 2. 나의 리뷰 목록 조회
	@RequestMapping(value = "/review/my-list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String myReviewList(@RequestParam HashMap<String, Object> map, jakarta.servlet.http.HttpSession session) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			fillMemberId(map, session);
			resultMap = reviewService.getMyReviewList(map);
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "리뷰 목록 조회에 실패했습니다.");
			e.printStackTrace();
		}
		return new Gson().toJson(resultMap);
	}

	// 3. 리뷰 수정
	@RequestMapping(value = "/review/edit.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String editReview(@RequestParam HashMap<String, Object> map,
			@RequestParam(value = "files", required = false) MultipartFile[] files,
			jakarta.servlet.http.HttpSession session) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			fillMemberId(map, session);
			resultMap = reviewService.editReview(map, files);
		} catch (IllegalArgumentException e) {
			resultMap.put("result", "fail");
			resultMap.put("message", e.getMessage());
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "리뷰 수정 중 오류가 발생했습니다.");
			e.printStackTrace();
		}
		return new Gson().toJson(resultMap);
	}

	// 4. 리뷰 삭제
	@RequestMapping(value = "/review/remove.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
	@ResponseBody
	public String removeReview(@RequestParam HashMap<String, Object> map, jakarta.servlet.http.HttpSession session) {
		HashMap<String, Object> resultMap = new HashMap<>();
		try {
			fillMemberId(map, session);
			resultMap = reviewService.removeReview(map);
		} catch (IllegalArgumentException e) {
			resultMap.put("result", "fail");
			resultMap.put("message", e.getMessage());
		} catch (Exception e) {
			resultMap.put("result", "fail");
			resultMap.put("message", "리뷰 삭제 중 오류가 발생했습니다.");
			e.printStackTrace();
		}
		return new Gson().toJson(resultMap);
	}

    ////////////////////////////////////////////////////////////
    // 상품에서 리뷰 목록 조회
    @RequestMapping(value = "/review/list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String list(Model model, @RequestParam HashMap<String, Object> map) throws Exception {
        HashMap<String, Object> resultMap = new HashMap<String, Object>();

        // 리뷰 목록 조회
        List<Review> reviewList = reviewService.getReviewList(map);

        // 리뷰 전체 개수 조회
        int totalCount = reviewService.getReviewCount(map);

        resultMap.put("reviewList", reviewList);
        resultMap.put("totalCount", totalCount);

        return new Gson().toJson(resultMap);
    }
    
    
    
    
    // 5. 리뷰 작성 가능한 주문 상품 목록 조회
    @RequestMapping(value = "/review/reviewable-list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String reviewableList(@RequestParam HashMap<String, Object> map, jakarta.servlet.http.HttpSession session) {
        HashMap<String, Object> resultMap = new HashMap<>();
        try {
            fillMemberId(map, session);
            resultMap = reviewService.getReviewableOrderItems(map);
        } catch (Exception e) {
            resultMap.put("result", "fail");
            resultMap.put("message", "작성 가능한 주문 내역 조회에 실패했습니다.");
            e.printStackTrace();
        }
        return new Gson().toJson(resultMap);
    }

    // 6. 신규 리뷰 등록
    @RequestMapping(value = "/review/add.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String addReview(@RequestParam HashMap<String, Object> map,
            @RequestParam(value = "files", required = false) MultipartFile[] files,
            jakarta.servlet.http.HttpSession session) {
        HashMap<String, Object> resultMap = new HashMap<>();
        try {
            fillMemberId(map, session);
            resultMap = reviewService.addReview(map, files);
        } catch (Exception e) {
            resultMap.put("result", "fail");
            resultMap.put("message", "리뷰 등록 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        return new Gson().toJson(resultMap);
    }

    
}
