<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>상품 등록 테스트</title>

        <script src="https://code.jquery.com/jquery-3.7.1.js"
        integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4="
        crossorigin="anonymous"></script>
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
            
            .image-list {
                margin-top: 10px;
            }
        </style>
    </head>

    <body>
        <div id="app">

            <h2>상품 등록 테스트</h2>

            <div class="form-group">
                <label>상품명</label>
                <input type="text" v-model="info.productName">
            </div>

            <div class="form-group">
                <label>카테고리</label>
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

            <div class="form-group">
                <input type="file"
                accept="image/*"
                @change="fnThumbnailChange">
            </div>

            <div v-if="thumbnailImage">
                선택 파일: {{ thumbnailImage.name }}
                <button type="button" @click="thumbnailImage = null">
                    삭제
                </button>
            </div>

            <hr>

            <h3>상세 이미지</h3>

            <div class="form-group">
                <input type="file"
                multiple
                accept="image/*"
                @change="fnProductImageChange">
            </div>

            <div class="image-list" v-if="info.productImageList.length > 0">
                <table>
                    <tr>
                        <th>번호</th>
                        <th>파일명</th>
                        <th>파일 크기</th>
                        <th>삭제</th>
                    </tr>

                    <tr v-for="(file, index) in info.productImageList" :key="index">
                        <td>{{ index + 1 }}</td>
                        <td>{{ file.name }}</td>
                        <td>{{ (file.size / 1024).toFixed(1) }} KB</td>
                        <td>
                            <button type="button" @click="fnDeleteProductImage(index)">
                                삭제
                            </button>
                        </td>
                    </tr>
                </table>
            </div>

            <p v-else>선택한 상세 이미지가 없습니다.</p>

            <hr>

            <button type="button" @click="fnProductAdd">
                상품 등록
            </button>

        </div>
    </body>

</html>

<script>
    const app = Vue.createApp({
        data() {
            return {
                thumbnailImage: null,
                info: {
                    productName: "샘플",
                    categoryId: "1",
                    productDescription: "샘플입니다",
                    price: "1",
                    stockQuantity: "1",
                    productStatus: "SELLING",
                    productImageList: []
                }
            };
        },
        methods: {
            // 상품 등록
            fnProductAdd: function () {
                let self = this;
                
                let formData = new FormData();
                
                formData.append("productName", self.info.productName);
                formData.append("categoryId", self.info.categoryId);
                formData.append("productDescription", self.info.productDescription);
                formData.append("price", self.info.price);
                formData.append("stockQuantity", self.info.stockQuantity);
                formData.append("productStatus", self.info.productStatus);
                
                // 썸네일 이미지 추가
                if (self.thumbnailImage) {
                    formData.append("thumbnailImage", self.thumbnailImage);
                }
                
                // 상세 이미지 추가
                for (let i = 0; i < self.info.productImageList.length; i++) {
                    formData.append("productImageList", self.info.productImageList[i]);
                }
                
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
            
            // 썸네일 이미지 선택
            fnThumbnailChange: function (event) {
                this.thumbnailImage = event.target.files[0] || null;
                event.target.value = "";
            },
            
            // 상세 이미지 선택
            fnProductImageChange: function (event) {
                this.info.productImageList.push(...Array.from(event.target.files));
                event.target.value = "";
            },
            
            // 상세 이미지 삭제
            fnDeleteProductImage: function (index) {
                this.info.productImageList.splice(index, 1);
            }
        },
        mounted() {
            let self = this;
        }
    });
    
    app.mount('#app');
</script>