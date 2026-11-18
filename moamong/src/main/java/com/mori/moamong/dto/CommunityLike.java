package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CommunityLike {
    private Long communityLikeId;
    private Long postId;
    private Long memberId;
    private LocalDateTime createdAt;
}
