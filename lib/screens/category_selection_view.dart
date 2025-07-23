import 'package:esc/screens/onboarding_view.dart';
import 'package:esc/screens/view_switcher.dart';
import 'package:esc/service/manage_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategorySelectionView extends StatefulWidget {
  @override
  _CategorySelectionViewState createState() => _CategorySelectionViewState();
}

class _CategorySelectionViewState extends State<CategorySelectionView> {
  String? selectedCategory;
  String? customCategory;
  bool isBottomSheetOpen = false;
  bool isLoading = false;

  final List<Map<String, String>> categories = [
    {'title': '직접 입력하기', 'icon': '✏️'},
    {'title': '누가 마실까요?', 'icon': '🍺'},
    {'title': '누가 설거지할까요?', 'icon': '🍽️'},
    {'title': '누가 청소할까요?', 'icon': '🧹'},
    {'title': '누가 쏠까요?', 'icon': '🍗'},
    {'title': '누가 팀장할까요?', 'icon': '👑'},
    {'title': '누가 커피살까요?', 'icon': '☕'},
    {'title': '누가 발표할까요?', 'icon': '🎤'},
    {'title': '누가 교통비낼까요?', 'icon': '🚕'},
    {'title': '아무나 한명 고르기', 'icon': '👤'},
  ];

  void _showCustomCategoryDialog() {
    final TextEditingController controller = TextEditingController();

    setState(() {
      isBottomSheetOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            setState(() {
              isBottomSheetOpen = false;
            });
            return true;
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 핸들 바
                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 제목
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '카테고리 직접 입력하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 입력 필드
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextField(
                      cursorColor: Colors.blue,
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: '예: 누가 청소할까요?',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      autofocus: true,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Spacer(),
                  // 버튼들
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              '취소',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (controller.text.trim().isNotEmpty) {
                                setState(() {
                                  selectedCategory = '직접 입력하기';
                                  customCategory = controller.text.trim();
                                });
                                Navigator.of(context).pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: Text(
                              '확인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        isBottomSheetOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            if (isLoading) {
              return;
            }
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '카테고리를 설정해볼까요?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected =
                    selectedCategory == category['title'] ||
                    (category['title'] == '직접 입력하기' &&
                        customCategory != null &&
                        selectedCategory == '직접 입력하기') ||
                    (category['title'] == '직접 입력하기' && isBottomSheetOpen);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (category['title'] == '직접 입력하기') {
                        // 직접 입력하기가 이미 선택되어 있고 커스텀 카테고리가 있으면 선택 취소
                        if (selectedCategory == '직접 입력하기' &&
                            customCategory != null) {
                          setState(() {
                            selectedCategory = null;
                            customCategory = null;
                          });
                        } else {
                          _showCustomCategoryDialog();
                        }
                      } else {
                        setState(() {
                          // 이미 선택된 셀을 다시 누르면 선택 취소
                          if (selectedCategory == category['title']) {
                            selectedCategory = null;
                          } else {
                            selectedCategory = category['title']; // title로 저장
                          }
                          customCategory = null;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[50] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              category['icon']!,
                              style: TextStyle(fontSize: 32),
                            ),
                            SizedBox(height: 8),
                            Text(
                              category['title'] == '직접 입력하기' &&
                                      customCategory != null
                                  ? customCategory!
                                  : category['title']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    selectedCategory != null
                        ? () async {
                          if (isLoading) return;

                          setState(() {
                            isLoading = true;
                          });

                          if (UserService().userId == null) {
                            AppUtil.showErrorSnackbar(
                              context,
                              message: '로그인 후 이용해주세요',
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnboardingView(),
                              ),
                              (route) => false,
                            );
                            return;
                          }

                          String categoryToSend;
                          if (selectedCategory == '직접 입력하기' &&
                              customCategory != null) {
                            categoryToSend = customCategory!;
                          } else {
                            categoryToSend = selectedCategory!;
                          }

                          try {
                            final gameManager = context.read<GameManager>();

                            // WebSocket 연결
                            await gameManager.connect();

                            // 연결 상태 확인
                            if (gameManager.wsState !=
                                WebSocketState.connected) {
                              throw Exception('WebSocket 연결 실패');
                            }

                            // 카테고리 설정 및 세션 생성
                            gameManager.createSession(
                              UserService().userId!,
                              UserService().name,
                              categoryToSend,
                            );

                            // 세션 생성 대기 (최대 10초)
                            int maxWait = 50; // 50 * 200ms = 10초
                            int waitCount = 0;

                            while (gameManager.currentSession == null &&
                                waitCount < maxWait) {
                              await Future.delayed(Duration(milliseconds: 200));
                              waitCount++;

                              // 에러 발생 시 중단
                              if (gameManager.errorCode != null) {
                                throw Exception(
                                  gameManager.errorMessage ?? '세션 생성 실패',
                                );
                              }
                            }

                            if (gameManager.currentSession == null) {
                              throw Exception('세션 생성 시간 초과');
                            }

                            await Future.delayed(Duration(milliseconds: 200));
                            // 성공 시 ViewSwitcher로 이동
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewSwitcher(),
                              ),
                            );
                          } catch (e) {
                            print('[CategorySelectionView] 세션 생성 오류: $e');
                            AppUtil.showErrorSnackbar(
                              context,
                              message: '게임 방 생성에 실패했습니다. 다시 시도해주세요.',
                            );
                          } finally {
                            if (!mounted) return;
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child:
                    isLoading
                        ? CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1,
                        )
                        : Text(
                          '게임 방 만들기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
