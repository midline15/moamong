package com.mori.moamong.review.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mori.moamong.review.mapper.ReviewMapper;

@RequiredArgsConstructor
@Service
public class ReviewService {
    private final ReviewMapper reviewMapper;

}
