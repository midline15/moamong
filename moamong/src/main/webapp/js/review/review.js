
// 리뷰 공통 기능
window.reviewMixin = {

    // 리뷰 데이터
    data() {
        return {
            reviewList: [],

            reviewPage: 1,
            reviewLimit: 5,
            reviewTotalCount: 0,
            reviewMaxPage: 0,

            // 선택한 별점 필터 (0이면 전체)
            selectedRating: 0,

            // 리뷰 수정
            showReviewEdit: false,
            editReviewId: "",
            editReviewContent: "",
            editReviewRating: 5,
            editReviewImageList: [],
            editReviewFiles: [],

            // 삭제할 기존 이미지 ID
            deleteReviewImageList: [],
        };
    },

    // 리뷰 계산 속성
    computed: {

        filteredReviewList() {
            if (this.selectedRating === 0) {
                return this.reviewList;
            }

            return this.reviewList.filter(function (review) {
                return review.rating === this.selectedRating;
            }, this);
        }

    },

    // 리뷰 메서드
    methods: {

        // 리뷰 탭 클릭
        fnReviewTab() {
            this.activeTab = "review";
            this.fnReviewList(1);
        },

        // 리뷰 목록 조회
        fnReviewList(page) {
            let self = this;

            let param = {
                page: page
            };

            // 상품 또는 패키지 ID 전달
            if (self.productId) {
                param.productId = self.productId;
            } else if (self.packageId) {
                param.packageId = self.packageId;
            }

            $.ajax({
                url: window.contextPath + "/review/list.dox",
                dataType: "json",
                type: "POST",
                data: param,
                success: function (data) {

                    self.reviewList = data.reviewList || [];
                    self.reviewTotalCount = data.totalCount || 0;
                    self.reviewPage = page;
                    self.reviewMaxPage = Math.ceil(
                        self.reviewTotalCount / self.reviewLimit
                    );

                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("리뷰 목록을 불러오지 못했습니다.");
                }
            });
        },

        // 리뷰 페이지 변경
        fnReviewPage(page) {
            if (page < 1 || page > this.reviewMaxPage) {
                return;
            }

            this.fnReviewList(page);
        },

        // 리뷰 수정 모달 열기
        fnReviewEdit(review) {
            this.editReviewId = review.reviewId;
            this.editReviewContent = review.reviewContent;
            this.editReviewRating = review.rating;
            this.editReviewImageList = review.imageList
                ? [...review.imageList]
                : [];

            this.editReviewFiles = [];
            this.deleteReviewImageList = [];

            this.showReviewEdit = true;
        },
        // 기존 리뷰 이미지 삭제 선택
        fnReviewImageDelete(imageId) {
            this.deleteReviewImageList.push(imageId);

            this.editReviewImageList = this.editReviewImageList.filter(
                image => image.imageId !== imageId
            );
        },
        // 리뷰 이미지 파일 선택
        fnReviewFileChange(event) {
            this.editReviewFiles = Array.from(event.target.files);

            if (this.editReviewImageList.length + this.editReviewFiles.length > 3) {
                alert("리뷰 이미지는 최대 3개까지 등록할 수 있습니다.");

                this.editReviewFiles = [];
                event.target.value = "";
                return;
            }
        },

        // 리뷰 수정 저장
        fnReviewEditSave() {
            let self = this;

            if (!self.editReviewContent.trim()) {
                alert("리뷰 내용을 입력해주세요.");
                return;
            }

            let formData = new FormData();

            formData.append("reviewId", self.editReviewId);
            formData.append("rating", self.editReviewRating);
            formData.append("reviewContent", self.editReviewContent);

            formData.append(
                "deleteImageList",
                JSON.stringify(self.deleteReviewImageList)
            );

            // 신규 이미지 추가
            self.editReviewFiles.forEach(function (file) {
                formData.append("files", file);
            });

            $.ajax({
                url: window.contextPath + "/review/edit.dox",
                type: "POST",
                data: formData,
                processData: false,
                contentType: false,
                success: function (data) {
                    if (data.result === "success") {
                        alert(data.message);

                        self.showReviewEdit = false;
                        self.fnReviewList(self.reviewPage);
                    } else {
                        alert(data.message || "리뷰 수정에 실패했습니다.");
                    }
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("리뷰 수정 중 오류가 발생했습니다.");
                }
            });
        },

    }

};
