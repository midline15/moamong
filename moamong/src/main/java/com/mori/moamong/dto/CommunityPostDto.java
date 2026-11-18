package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CommunityPostDto {
    private Long postId;
    private Long memberId;
    private String postTitle;
    private String postContent;
    private Long viewCount;
    private String postStatus;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
