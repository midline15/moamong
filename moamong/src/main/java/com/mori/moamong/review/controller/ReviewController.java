package com.mori.moamong.review.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;

import com.mori.moamong.review.service.ReviewService;

@RequiredArgsConstructor
@Controller
public class ReviewController {
    private final ReviewService reviewService;

}
