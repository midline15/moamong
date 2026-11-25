
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

    // 1. 나의 리뷰 페이지 이동

    @RequestMapping("/review/myReview.do")
    public String myReview(@RequestParam HashMap<String, Object> map, Model model) {

        model.addAttribute("memberId", map.get("memberId"));

        return "review/list";
    }

    // 2. 나의 리뷰 목록 조회

    @RequestMapping(value = "/review/my-list.dox", method = RequestMethod.POST, produces = "application/json;charset=UTF-8")
    @ResponseBody
    public String myReviewList(@RequestParam HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

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
            @RequestParam(value = "files", required = false) MultipartFile[] files) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            // 서비스에 리뷰 수정 요청
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
    public String removeReview(@RequestParam HashMap<String, Object> map) {

        HashMap<String, Object> resultMap = new HashMap<>();

        try {

            // 서비스에 리뷰 삭제 요청
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
    // 리뷰 목록 조회
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
}
