package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CommunityComment {
    private Long commentId;
    private Long postId;
    private Long memberId;
    private Long parentCommentId;
    private String commentContent;
    private String commentStatus;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
