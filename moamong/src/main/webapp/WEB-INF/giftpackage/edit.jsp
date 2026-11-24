<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>상품 수정</title>

        <script src="https://code.jquery.com/jquery-3.7.1.js"
            integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script src="/js/page-change.js"></script>

        <style>
            table,
            tr,
            td,
            th {
                border: 1px solid black;
                border-collapse: collapse;
                padding: 5px 10px;
                text-align: center;
            }

            th {
                background-color: beige;
            }

            tr:nth-child(even) {
                background-color: azure;
            }

            .form-group {
                margin-bottom: 15px;
            }

            .form-group label {
                display: inline-block;
                width: 130px;
            }

            .image-item {
                border: 1px solid #ccc;
                padding: 10px;
                margin: 10px 0;
                width: 250px;
            }

            .image-item img {
                display: block;
                width: 150px;
                height: 150px;
                object-fit: contain;
                margin-bottom: 10px;
            }

            .image-item button {
                margin-top: 10px;
            }
        </style>
    </head>

    <body>

        <div id="app">

            <h2>상품 수정</h2>

            <h3>상품 정보</h3>

            <div class="form-group">
                <label>상품명</label>
                <input type="text" v-model="info.productName">
            </div>

            <div class="form-group">
                <label>카테고리 ID</label>
                <input type="number" v-model="info.categoryId">
            </div>

            <div class="form-group">
                <label>상품 설명</label>
                <textarea v-model="info.productDescription"></textarea>
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
                    <option value="SELLING">판매중</option>
                    <option value="SOLD_OUT">품절</option>
                    <option value="STOP">판매중지</option>
                </select>
            </div>

            <hr>

            <h3>썸네일 이미지</h3>

            <div v-if="thumbnailUrl">
                <p>현재 썸네일</p>
                <img :src="thumbnailUrl" width="150">
                <button v-if="thumbnailUrl" type="button" @click="fnDeleteThumbnail">
                    썸네일 삭제
                </button>
            </div>

            <div v-if="thumbnailImage">
                <p>새 썸네일: {{ thumbnailImage.name }}</p>
            </div>

            <div>
                <input type="file" accept="image/*" @change="fnThumbnailChange">
            </div>

            <hr>

            <h3>상세 이미지</h3>

            <div>
                <input type="file" multiple accept="image/*" @change="fnProductImageChange">
            </div>

            <p>이미지를 드래그하여 순서를 변경할 수 있습니다.</p>

            <div v-for="(image, index) in productImageList" :key="image.imageId || index" class="image-item"
                draggable="true" @dragstart="fnDragStart(index)" @dragover.prevent @drop="fnDrop(index)">

                <p>{{ index + 1 }}번 이미지</p>

                <img v-if="!image.isNew" :src="image.imageUrl">

                <div v-else>
                    <p>새 이미지: {{ image.file.name }}</p>
                    <img :src="image.previewUrl">
                </div>

                <div>
                    <label>이미지 교체</label>
                    <input type="file" accept="image/*" @change="fnReplaceProductImage(index, $event)">
                </div>

                <button type="button" @click="fnDeleteProductImage(index)">
                    이미지 삭제
                </button>

            </div>

            <p v-if="productImageList.length === 0">
                등록된 상세 이미지가 없습니다.
            </p>

            <hr>

            <button type="button" @click="fnProductEdit">
                상품 수정
            </button>

        </div>

    </body>

    </html>

    <script>
        const app = Vue.createApp({
            data() {
                return {
                    productId: "${productId}",

                    info: {
                        productName: "",
                        categoryId: "",
                        productDescription: "",
                        price: "",
                        stockQuantity: "",
                        productStatus: ""
                    },

                    // 최종 이미지 목록
                    productImageList: [],

                    // 새 썸네일 이미지
                    thumbnailImage: null,

                    // 기존 썸네일 경로
                    thumbnailUrl: "",

                    dragIndex: null,

                    deleteThumbnail: false
                };
            },
            methods: {
                // 기존 상품 정보 조회
                fnProductInfo: function () {
                    let self = this;

                    let param = {
                        productId: self.productId
                    };

                    $.ajax({
                        url: "view.dox",
                        dataType: "json",
                        type: "POST",
                        data: param,
                        success: function (data) {
                            self.info = data.info;

                            // 기존 썸네일 조회
                            let thumbnail = (data.info.productImageList || []).find(function (image) {
                                return image.imageType === "THUMBNAIL";
                            });

                            self.thumbnailUrl = thumbnail ? thumbnail.imageUrl : "";

                            // 기존 상세 이미지 목록
                            self.productImageList = (data.info.productImageList || [])
                                .filter(function (image) {
                                    return image.imageType === "DETAIL";
                                })
                                .map(function (image) {
                                    return {
                                        imageId: image.imageId,
                                        imageUrl: image.imageUrl,
                                        imageType: image.imageType,
                                        displayOrder: image.displayOrder,
                                        isNew: false,
                                        file: null,
                                        previewUrl: null
                                    };
                                });
                        }
                    });
                },

                // 썸네일 변경
                fnThumbnailChange: function (event) {
                    this.thumbnailImage = event.target.files[0] || null;
                    this.deleteThumbnail = false;
                    event.target.value = "";
                },

                // 썸네일 삭제
                fnDeleteThumbnail: function () {
                    this.thumbnailUrl = "";
                    this.thumbnailImage = null;
                    this.deleteThumbnail = true;
                },

                // 새 상세 이미지 추가
                fnProductImageChange: function (event) {
                    let self = this;
                    let files = Array.from(event.target.files);

                    files.forEach(function (file) {
                        self.productImageList.push({
                            imageId: null,
                            imageUrl: null,
                            imageType: "DETAIL",
                            displayOrder: 0,
                            isNew: true,
                            file: file,
                            previewUrl: URL.createObjectURL(file)
                        });
                    });

                    event.target.value = "";
                },

                // 상세 이미지 교체
                fnReplaceProductImage: function (index, event) {
                    let file = event.target.files[0];

                    if (!file) {
                        return;
                    }

                    let oldImage = this.productImageList[index];

                    if (oldImage.previewUrl) {
                        URL.revokeObjectURL(oldImage.previewUrl);
                    }

                    this.productImageList.splice(index, 1, {
                        imageId: null,
                        imageUrl: null,
                        imageType: "DETAIL",
                        displayOrder: 0,
                        isNew: true,
                        file: file,
                        previewUrl: URL.createObjectURL(file)
                    });

                    event.target.value = "";
                },

                // 상세 이미지 삭제
                fnDeleteProductImage: function (index) {
                    let image = this.productImageList[index];

                    if (image.previewUrl) {
                        URL.revokeObjectURL(image.previewUrl);
                    }

                    this.productImageList.splice(index, 1);
                },

                // 이미지 드래그 시작
                fnDragStart: function (index) {
                    this.dragIndex = index;
                },

                // 이미지 순서 변경
                fnDrop: function (index) {
                    if (this.dragIndex === null || this.dragIndex === index) {
                        this.dragIndex = null;
                        return;
                    }

                    let image = this.productImageList.splice(this.dragIndex, 1)[0];

                    this.productImageList.splice(index, 0, image);

                    this.dragIndex = null;
                },

                // 상품 수정
                fnProductEdit: function () {
                    let self = this;

                    let formData = new FormData();

                    formData.append("productId", self.productId);
                    formData.append("productName", self.info.productName);
                    formData.append("categoryId", self.info.categoryId);
                    formData.append("productDescription", self.info.productDescription);
                    formData.append("price", self.info.price);
                    formData.append("stockQuantity", self.info.stockQuantity);
                    formData.append("productStatus", self.info.productStatus);

                    // 최종 상세 이미지 목록
                    let imageList = self.productImageList.map(function (image, index) {
                        return {
                            imageId: image.imageId,
                            isNew: image.isNew,
                            displayOrder: index + 1
                        };
                    });

                    formData.append("imageList", JSON.stringify(imageList));

                    // 새 상세 이미지 파일
                    self.productImageList.forEach(function (image) {
                        if (image.isNew) {
                            formData.append("productImageList", image.file);
                        }
                    });

                    // 새 썸네일 이미지
                    if (self.thumbnailImage) {
                        formData.append("thumbnailImage", self.thumbnailImage);
                    }

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
                }
            },
            mounted() {
                let self = this;
                self.fnProductInfo();
            },
            beforeUnmount() {
                this.productImageList.forEach(function (image) {
                    if (image.previewUrl) {
                        URL.revokeObjectURL(image.previewUrl);
                    }
                });
            }
        });

        app.mount('#app');
    </script>