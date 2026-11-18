package com.mori.moamong.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class MemberDto {
    private Long memberId;
    private String loginId;
    private String password;
    private String memberName;
    private String email;
    private String phone;
    private String role;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime withdrawnAt;
    private String socialType;
    private String socialUserId;
    private LocalDateTime connectedAt;
}
