<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
	<% String ctx=request.getContextPath(); String eventId=request.getParameter("eventId"); %>
		<!DOCTYPE html>
		<html lang="ko">

		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>이벤트 등록/수정</title>

			<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
			<link href="https://cdn.jsdelivr.net/npm/summernote@0.9.0/dist/summernote-lite.min.css" rel="stylesheet">
			<script src="https://cdn.jsdelivr.net/npm/summernote@0.9.0/dist/summernote-lite.min.js"></script>
			<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/adminLayout.css">
			<link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin/event/write.css">
			
		</head>

		<body>

			<%@ include file="/WEB-INF/common/adminHeader.jsp"%>

			<div class="adm-shell">

				<%@ include file="/WEB-INF/common/adminSidebar.jsp"%>

				<main class="adm-main">

					<div class="event-wrap">
						<h2 id="pageTitle">이벤트 등록</h2>

						<div class="event-form">
							<div class="form-row">
								<label>이벤트 제목</label>
								<input type="text" id="eventTitle" placeholder="이벤트 제목 입력">
							</div>

							<div class="form-row">
								<label>이벤트 상태</label>
								<select id="eventStatus">
									<option value="READY">예정</option>
									<option value="ONGOING">진행중</option>
									<option value="ENDED">종료</option>
									<option value="HIDDEN">숨김</option>
								</select>
							</div>

							<div class="form-row">
								<label>시작일</label>
								<input type="datetime-local" id="startedAt">
							</div>

							<div class="form-row">
								<label>종료일</label>
								<input type="datetime-local" id="endedAt">
							</div>

							<div class="form-row">
								<label>썸네일 이미지</label>
								<input type="file" id="thumbnailFile" accept="image/*">
								<img id="thumbnailPreview" class="thumbnail-preview" style="display:none;">
								<button type="button" id="removeThumbnail" style="display:none;">
									썸네일 삭제
								</button>
							</div>

							<div class="form-row">
								<label>이벤트 내용</label>
								<div id="summernote"></div>
							</div>

							<div class="event-buttons">
								<button class="btn-gray" type="button" onclick="goList()">취소</button>
								<button class="btn-dark" type="button" onclick="saveEvent()">저장</button>
							</div>
						</div>
					</div>

				</main>

			</div>

			<script>
				const ctx = '<%=ctx%>';
				const eventId = '<%=eventId%>';
				const isEdit = eventId !== 'null' && eventId !== '';

				let thumbnail = null;
				let detailImages = [];

				$(function () {
					$('#summernote').summernote({
						height: 450,
						lang: 'ko-KR',
						placeholder: '이벤트 내용을 입력하세요.',
						callbacks: {
							onImageUpload: function (files) {
								for (let i = 0; i < files.length; i++) {
									uploadImage(files[i], function (data) {
										$('#summernote').summernote(
											'insertImage',
											data.imageUrl,
											data.imageOriginName
										);

										detailImages.push({
											imageUrl: data.imageUrl,
											imageOriginName: data.imageOriginName,
											imageName: data.imageName,
											imageSize: data.imageSize
										});
									});
								}
							},
							onMediaDelete: function (target) {
								const url = target.attr('src');
								detailImages = detailImages.filter(
									img => img.imageUrl !== url
								);
								// 기존 파일은 저장 시 DB 이미지 목록에서 제외
							}
						}
					});

					$('#thumbnailFile').on('change', function () {
						const file = this.files[0];
						if (!file) return;

						uploadImage(file, function (data) {
							thumbnail = {
								imageUrl: data.imageUrl,
								imageOriginName: data.imageOriginName,
								imageName: data.imageName,
								imageSize: data.imageSize
							};

							$('#thumbnailPreview')
								.attr('src', data.imageUrl)
								.show();

							$('#removeThumbnail').show();
						});
					});

					$('#removeThumbnail').on('click', function () {
						thumbnail = null;
						$('#thumbnailPreview').attr('src', '').hide();
						$('#thumbnailFile').val('');
						$(this).hide();
					});

					if (isEdit) {
						$('#pageTitle').text('이벤트 수정');
						loadEvent();
					}
				});

				// 이미지 업로드
				function uploadImage(file, callback) {
					if (file.size > 5 * 1024 * 1024) {
						alert('이미지는 5MB 이하만 업로드할 수 있습니다.');
						return;
					}

					const formData = new FormData();
					formData.append('file', file);
					formData.append('type', 'event');

					$.ajax({
						url: ctx + '/common/image-upload.dox',
						type: 'POST',
						data: formData,
						processData: false,
						contentType: false,
						success: function (data) {
							if (typeof data === 'string') data = JSON.parse(data);

							if (data.result === 'success') {
								callback(data);
							} else {
								alert(data.msg || '이미지 업로드 실패');
							}
						},
						error: function () {
							alert('이미지 업로드 중 오류가 발생했습니다.');
						}
					});
				}

				// 기존 이벤트 조회
				function loadEvent() {
					$.ajax({
						url: ctx + '/event/view.dox',
						type: 'POST',
						data: {eventId: eventId},
						success: function (data) {
							if (typeof data === 'string') data = JSON.parse(data);

							if (data.result !== 'success') {
								alert('이벤트 정보를 불러오지 못했습니다.');
								goList();
								return;
							}

							const info = data.info;

							$('#eventTitle').val(info.eventTitle);
							$('#eventStatus').val(info.eventStatus);
							$('#startedAt').val(toDateTimeLocal(info.startedAt));
							$('#endedAt').val(toDateTimeLocal(info.endedAt));

							$('#summernote').summernote('code', info.eventContent || '');

							const imageList = data.imageList || [];

							const thumb = imageList.find(
								img => img.imageType === 'THUMBNAIL'
							);

							if (thumb) {
								thumbnail = {
									imageUrl: thumb.imageUrl,
									imageOriginName: thumb.imageOriginName,
									imageName: thumb.imageName,
									imageSize: thumb.imageSize
								};

								$('#thumbnailPreview').attr('src', thumb.imageUrl).show();
								$('#removeThumbnail').show();
							}

							detailImages = imageList
								.filter(img => img.imageType === 'DETAIL')
								.map(img => ({
									imageUrl: img.imageUrl,
									imageOriginName: img.imageOriginName,
									imageName: img.imageName,
									imageSize: img.imageSize
								}));
						},
						error: function () {
							alert('이벤트 조회 중 오류가 발생했습니다.');
						}
					});
				}

				// 이벤트 저장
				function saveEvent() {
					const title = $('#eventTitle').val().trim();
					const startedAt = $('#startedAt').val();
					const endedAt = $('#endedAt').val();
					const content = $('#summernote').summernote('code');
					const textContent = $('<div>').html(content).text().trim();

					if (!title) {
						alert('이벤트 제목을 입력하세요.');
						return;
					}

					if (!startedAt || !endedAt) {
						alert('이벤트 기간을 입력하세요.');
						return;
					}

					if (new Date(startedAt) > new Date(endedAt)) {
						alert('종료일은 시작일보다 빠를 수 없습니다.');
						return;
					}

					if (!thumbnail) {
						alert('썸네일 이미지를 등록하세요.');
						return;
					}

					if (!textContent) {
						alert('이벤트 내용을 입력하세요.');
						return;
					}

					// 에디터에서 삭제된 본문 이미지 제외
					const editorHtml = $('#summernote').summernote('code');

					const images = detailImages.filter(function (img) {
						return editorHtml.includes(img.imageUrl);
					});

					const params = {
						eventTitle: title,
						eventStatus: $('#eventStatus').val(),
						startedAt: startedAt.replace('T', ' ') + ':00',
						endedAt: endedAt.replace('T', ' ') + ':00',
						eventContent: content,
						thumbnail: JSON.stringify(thumbnail),
						images: JSON.stringify(images)
					};

					let url = ctx + '/event/add.dox';

					if (isEdit) {
						url = ctx + '/event/update.dox';
						params.eventId = eventId;
					}

					$.ajax({
						url: url,
						type: 'POST',
						data: params,
						success: function (data) {
							if (typeof data === 'string') data = JSON.parse(data);

							if (data.result === 'success') {
								alert(isEdit ? '이벤트 수정 완료' : '이벤트 등록 완료');

								if (isEdit) {
									location.href = ctx + '/admin/event/view.do?eventId=' + eventId;
								} else {
									goList();
								}
							} else {
								alert(data.msg || '저장에 실패했습니다.');
							}
						},
						error: function () {
							alert('저장 중 오류가 발생했습니다.');
						}
					});
				}

				function toDateTimeLocal(date) {
					if (!date) return '';
					return String(date).replace(' ', 'T').substring(0, 16);
				}

				function goList() {
					location.href = ctx + '/admin/event/list.do';
				}
			</script>

		</body>

		</html>