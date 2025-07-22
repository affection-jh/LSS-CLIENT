import 'package:flutter/material.dart';
import 'package:esc/utill/lee_image_layout.dart';
import 'dart:io';

// 다른 화면에서 LeeImageLayout을 사용하는 예시
class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('예시 화면')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 영역
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('제목', style: TextStyle(fontSize: 24)),
                SizedBox(height: 10),
                // 여기에 다른 위젯들...
              ],
            ),

            // 하단 영역 - LeeImageLayout 사용
            LeeImageLayout(
              profileImageUrl: 'https://example.com/profile.jpg', // 프로필 이미지 URL
              selectedImage: null, // 선택된 이미지 파일
              onImageTap: () {
                // 이미지 선택 다이얼로그 표시
                print('이미지 선택');
              },
              actionButton: ElevatedButton(
                onPressed: () {
                  print('버튼 클릭');
                },
                child: Text('완료하기'),
              ),
              showImagePicker: true, // 이미지 선택 버튼 표시 여부
              maxWidth: 300, // 최대 너비 (선택사항)
              maxHeight: 400, // 최대 높이 (선택사항)
            ),
          ],
        ),
      ),
    );
  }
}

// 읽기 전용 화면에서 사용하는 예시
class ReadOnlyExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('읽기 전용 화면')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: LeeImageLayout(
          profileImageUrl: 'https://example.com/profile.jpg',
          showImagePicker: false, // 이미지 선택 버튼 숨김
          actionButton: null, // 액션 버튼 없음
        ),
      ),
    );
  }
}
