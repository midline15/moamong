<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>상품 등록 / 수정</title>

        <script src="https://code.jquery.com/jquery-3.7.1.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.20/dist/summernote-lite.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.20/dist/lang/summernote-ko-KR.min.js"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>

        <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.20/dist/summernote-lite.min.css" rel="stylesheet">
        <!-- 상품 등록 / 수정 CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product/form.css">


    </head>

    <body>

        <div id="app">

            <div class="page-header">
                <h2>{{ isEdit ? '상품 수정' : '상품 등록' }}</h2>
                <p>{{ isEdit ? '등록된 상품 정보를 수정합니다.' : '새로운 상품 정보를 등록합니다.' }}</p>
            </div>

            <!-- 상품 기본 정보 -->
            <section class="form-section">
                <h3 class="section-title">상품 기본 정보</h3>

                <div class="form-grid">
                    <div class="form-group">
                        <label>상품명</label>
                        <input type="text" v-model="info.productName">
                    </div>

                    <div class="form-group">
                        <label>카테고리</label>
                        <input type="number" v-model="info.categoryId">
                    </div>

                    <div class="form-group">
                        <label>가격</label>
                        <input type="number" v-model="info.price">
                    </div>

                    <div class="form-group">
                        <label>재고 수량</label>
                        <input type="number" v-model="info.stockQuantity">
                    </div>

                    <div class="form-group">
                        <label>판매 상태</label>
                        <select v-model="info.productStatus">
                            <option value="SELLING">판매 중</option>
                            <option value="SOLD_OUT">품절</option>
                            <option value="STOPPED">판매 중지</option>
                        </select>
                    </div>
                </div>
            </section>

            <!-- 상품 상세 설명 -->
            <section class="form-section">
                <h3 class="section-title">상품 상세 설명</h3>

                <textarea id="productDescription"></textarea>
            </section>

            <!-- 대표 이미지 -->
            <section class="form-section">
                <h3 class="section-title">대표 이미지</h3>

                <div class="image-upload">

                    <div class="thumbnail-preview" v-if="thumbnailUrl">
                        <p>현재 대표 이미지</p>
                        <img :src="thumbnailUrl">
                    </div>

                    <div v-if="thumbnailImage" class="selected-file">
                        새 대표 이미지: {{ thumbnailImage.name }}

                        <button type="button" @click="fnDeleteNewThumbnail">
                            선택 취소
                        </button>
                    </div>

                    <div>
                        <label>
                            <input type="file" accept="image/*" @change="fnThumbnailChange" ref="thumbnailInput"
                                style="display: none;">

                            <button type="button" @click="$refs.thumbnailInput.click()">
                                {{ thumbnailUrl || thumbnailImage ? '대표 이미지 교체' : '대표 이미지 추가' }}
                            </button>
                        </label>
                    </div>

                    <button v-if="thumbnailUrl && !thumbnailImage" type="button" @click="fnDeleteThumbnail">
                        대표 이미지 삭제
                    </button>

                </div>
            </section>

            <!-- 하단 버튼 -->
            <div class="button-area">
                <button type="button" class="btn-cancel" @click="fnCancel">
                    취소
                </button>

                <button type="button" class="btn-submit" @click="fnProductSave">
                    {{ isEdit ? '상품 수정' : '상품 등록' }}
                </button>
            </div>

        </div>

        <script>
            const app = Vue.createApp({
                data() {
                    return {
                        productId: "${productId}",

                        info: {
                            productName: "",
                            categoryId: "6",
                            productDescription: "",
                            price: "1",
                            stockQuantity: "1",
                            productStatus: "SELLING"
                        },

                        // 새로 추가한 상세 이미지 파일
                        productImageList: [],

                        // 기존 상세 이미지 정보
                        existingDetailImageList: [],

                        // 새 대표 이미지
                        thumbnailImage: null,

                        // 기존 대표 이미지 URL
                        thumbnailUrl: "",

                        // 기존 대표 이미지 삭제 여부
                        deleteThumbnail: false
                    };
                },

                computed: {
                    isEdit() {
                        return this.productId !== ""
                            && this.productId !== "null"
                            && this.productId !== "undefined";
                    }
                },

                methods: {
                    // 기본 상품정보 표
                    fnGetProductInfoTable: function () {

                        return `
                                <table class="product-spec-table">
                                    <tbody>
                                        <tr>
                                            <th>제조사</th>
                                            <td>내용을 입력해주세요.</td>
                                        </tr>
                                        <tr>
                                            <th>원산지</th>
                                            <td>내용을 입력해주세요.</td>
                                        </tr>
                                        <tr>
                                            <th>사이즈</th>
                                            <td>내용을 입력해주세요.</td>
                                        </tr>
                                        <tr>
                                            <th>소재</th>
                                            <td>내용을 입력해주세요.</td>
                                        </tr>
                                        <tr>
                                            <th>제품 보관 및 세탁방법</th>
                                            <td>내용을 입력해주세요.</td>
                                        </tr>
                                    </tbody>
                                </table>
                                <p><br></p>
                            `;
                    },
                    // 상품 정보 조회
                    fnProductInfo: function () {
                        let self = this;

                        $.ajax({
                            url: "view.dox",
                            dataType: "json",
                            type: "POST",
                            data: {
                                productId: self.productId
                            },
                            success: function (data) {
                                self.info = data.info;

                                // 기존 상품 상세 설명 불러오기
                                $("#productDescription").summernote(
                                    "code",
                                    data.info.productDescription || ""
                                );

                                // 기존 대표 이미지 조회
                                let thumbnail = (data.info.productImageList || []).find(function (image) {
                                    return image.imageType === "THUMBNAIL";
                                });

                                self.thumbnailUrl = thumbnail ? thumbnail.imageUrl : "";

                                // 기존 상세 이미지 목록
                                self.existingDetailImageList = (data.info.productImageList || [])
                                    .filter(function (image) {
                                        return image.imageType === "DETAIL";
                                    });
                            },
                            error: function (xhr) {
                                console.log(xhr.responseText);
                                alert("상품 정보를 불러오지 못했습니다.");
                            }
                        });
                    },

                    // 상품 등록 / 수정 분기
                    fnProductSave: function () {
                        if (this.isEdit) {
                            this.fnProductEdit();
                        } else {
                            this.fnProductAdd();
                        }
                    },

                    // 에디터에서 실제 사용 중인 이미지 URL 목록
                    fnGetEditorImageSrcList: function () {
                        let productDescription = $("#productDescription").summernote("code");
                        let imageSrcList = [];

                        let html = $("<div>").html(productDescription);

                        html.find("img").each(function () {
                            imageSrcList.push($(this).attr("src"));
                        });

                        return imageSrcList;
                    },

                    // 에디터에 남아 있는 새 이미지 파일 목록
                    fnGetNewImages: function () {
                        let self = this;
                        let imageSrcList = self.fnGetEditorImageSrcList();
                        let images = [];

                        imageSrcList.forEach(function (src) {
                            let image = self.productImageList.find(function (item) {
                                return item.previewUrl === src;
                            });

                            if (image && !images.includes(image)) {
                                images.push(image);
                            }
                        });

                        return images;
                    },

                    // 수정 시 기존 이미지와 새 이미지의 최종 목록 생성
                    fnGetImageList: function () {
                        let self = this;
                        let imageSrcList = self.fnGetEditorImageSrcList();
                        let imageList = [];
                        let usedImageIdList = [];

                        imageSrcList.forEach(function (src) {

                            // 기존 이미지인지 확인
                            let oldImage = self.existingDetailImageList.find(function (image) {
                                return image.imageUrl === src;
                            });

                            if (oldImage) {

                                // 이미 등록된 이미지 ID라면 중복 추가하지 않음
                                if (usedImageIdList.includes(oldImage.imageId)) {
                                    return;
                                }

                                usedImageIdList.push(oldImage.imageId);

                                imageList.push({
                                    imageId: oldImage.imageId,
                                    isNew: false,
                                    displayOrder: imageList.length + 1
                                });

                                return;
                            }

                            // 새 이미지인지 확인
                            let newImage = self.productImageList.find(function (image) {
                                return image.previewUrl === src;
                            });

                            if (newImage) {
                                imageList.push({
                                    imageId: null,
                                    isNew: true,
                                    displayOrder: imageList.length + 1
                                });
                            }
                        });

                        return imageList;
                    },

                    // 공통 FormData 생성
                    fnCreateFormData: function () {
                        let self = this;

                        let productDescription = $("#productDescription").summernote("code");
                        let images = self.fnGetNewImages();

                        let formData = new FormData();

                        formData.append("productName", self.info.productName);
                        formData.append("categoryId", self.info.categoryId);
                        formData.append("productDescription", productDescription);
                        formData.append("price", self.info.price);
                        formData.append("stockQuantity", self.info.stockQuantity);
                        formData.append("productStatus", self.info.productStatus);

                        // 대표 이미지 추가
                        if (self.thumbnailImage) {
                            formData.append("thumbnailImage", self.thumbnailImage);
                        }

                        // 대표 이미지 삭제 여부
                        formData.append("deleteThumbnail", self.deleteThumbnail);

                        // 상세 이미지 파일 추가
                        images.forEach(function (image) {
                            formData.append("productImageList", image.file);
                        });

                        // 상세 이미지 미리보기 URL 목록 추가
                        let previewUrlList = images.map(function (image) {
                            return image.previewUrl;
                        });

                        formData.append("previewUrlList", JSON.stringify(previewUrlList));

                        // 수정일 때만 추가 정보 전달
                        if (self.isEdit) {
                            formData.append("productId", self.productId);

                            let imageList = self.fnGetImageList();

                            formData.append("imageList", JSON.stringify(imageList));
                        }

                        return formData;
                    },

                    // 상품 등록
                    fnProductAdd: function () {
                        let self = this;
                        let formData = self.fnCreateFormData();

                        $.ajax({
                            url: "add.dox",
                            dataType: "json",
                            type: "POST",
                            data: formData,
                            processData: false,
                            contentType: false,
                            success: function (data) {
                                if (data.result > 0) {
                                    alert("상품이 등록되었습니다.");
                                    location.href = "list.do";
                                } else {
                                    alert("상품 등록에 실패했습니다.");
                                }
                            },
                            error: function (xhr) {
                                console.log(xhr.responseText);
                                alert("상품 등록 중 오류가 발생했습니다.");
                            }
                        });
                    },

                    // 상품 수정
                    fnProductEdit: function () {
                        let self = this;
                        let formData = self.fnCreateFormData();

                        $.ajax({
                            url: "edit.dox",
                            dataType: "json",
                            type: "POST",
                            data: formData,
                            processData: false,
                            contentType: false,
                            success: function (data) {
                                if (data.result > 0) {
                                    alert("상품이 수정되었습니다.");
                                    location.href = "view.do?productId=" + self.productId;
                                } else {
                                    alert("상품 수정에 실패했습니다.");
                                }
                            },
                            error: function (xhr) {
                                console.log(xhr.responseText);
                                alert("상품 수정 중 오류가 발생했습니다.");
                            }
                        });
                    },

                    // 대표 이미지 선택
                    fnThumbnailChange: function (event) {
                        this.thumbnailImage = event.target.files[0] || null;
                        this.deleteThumbnail = false;

                        event.target.value = "";
                    },

                    // 기존 대표 이미지 삭제
                    fnDeleteThumbnail: function () {
                        this.thumbnailUrl = "";
                        this.thumbnailImage = null;
                        this.deleteThumbnail = true;
                    },

                    // 새 대표 이미지 선택 취소
                    fnDeleteNewThumbnail: function () {
                        this.thumbnailImage = null;
                    },

                    // Summernote 이미지 등록
                    fnSummernoteImageUpload: function (files) {
                        let self = this;

                        for (let i = 0; i < files.length; i++) {
                            let file = files[i];

                            // 이미지 파일만 허용
                            if (!file.type.startsWith("image/")) {
                                alert("이미지 파일만 등록할 수 있습니다.");
                                continue;
                            }

                            // 5MB 용량 제한
                            if (file.size > 5 * 1024 * 1024) {
                                alert("이미지는 5MB 이하만 등록할 수 있습니다.");
                                continue;
                            }

                            let reader = new FileReader();

                            reader.onload = function (event) {
                                let imageUrl = event.target.result;

                                self.productImageList.push({
                                    file: file,
                                    previewUrl: imageUrl
                                });

                                $("#productDescription").summernote(
                                    "insertImage",
                                    imageUrl
                                );
                            };

                            reader.readAsDataURL(file);
                        }
                    },

                    // 취소
                    fnCancel: function () {
                        history.back();
                    }
                },

                mounted() {
                    let self = this;

                    // Summernote 초기화
                    $("#productDescription").summernote({
                        height: 400,
                        lang: "ko-KR",
                        placeholder: "상품 상세 설명을 입력해주세요.",

                        toolbar: [
                            ["style", ["style"]],
                            ["font", ["bold", "italic", "underline", "clear"]],
                            ["fontname", ["fontname"]],
                            ["fontsize", ["fontsize"]],
                            ["color", ["color"]],
                            ["para", ["ul", "ol", "paragraph"]],
                            ["table", ["table"]],
                            ["insert", ["link", "picture"]],
                            ["view", ["fullscreen", "codeview"]]
                        ],

                        callbacks: {
                            onImageUpload: function (files) {
                                self.fnSummernoteImageUpload(files);
                            },

                            // 에디터에서 이미지 삭제
                            onMediaDelete: function (target) {
                                let imageUrl = $(target).attr("src");

                                self.productImageList = self.productImageList.filter(function (image) {
                                    return image.previewUrl !== imageUrl;
                                });
                            }
                        }
                    });

                    // 수정 모드라면 기존 상품 정보 조회
                    if (self.isEdit) {
                        self.fnProductInfo();
                    } else {
                        // 신규 등록이면 기본 상품정보 표 표시
                        $("#productDescription").summernote(
                            "code",
                            self.fnGetProductInfoTable()
                        );
                    }
                },

                beforeUnmount() {
                    this.productImageList.forEach(function (image) {
                        if (image.previewUrl) {
                            URL.revokeObjectURL(image.previewUrl);
                        }
                    });
                }
            });

            app.mount("#app");
        </script>

    </body>

    </html>