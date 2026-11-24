package com.mori.moamong.dto;

import java.util.Date;
import java.util.List;

import lombok.Data;

@Data
public class Review {

	// 리뷰 정보
	private Long reviewId;
	private Long memberId;
	private Long productId;
	private Long orderItemId;
	private Integer rating;
	private String reviewContent;
	private String reviewStatus;
	private Date createdAt;
	private Date updatedAt;

	// 상품명
	private String productName;

	// 리뷰 이미지 정보
	private Long imageId;
	private String imageUrl;
	private String imageOriginName;
	private String imageName;
	private String imageSize;
	private String imageType;
	private Integer displayOrder;

	// 리뷰 하나에 연결된 이미지 목록
	private List<Review> imageList;

}
