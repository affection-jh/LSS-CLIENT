import 'package:esc/data/player.dart';
import 'package:esc/screens/home_view.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';

import 'package:esc/service/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuestProfileSettingView extends StatefulWidget {
  final String callFromWhere;
  const GuestProfileSettingView({super.key, required this.callFromWhere});

  @override
  State<GuestProfileSettingView> createState() => _ProfileSettingViewState();
}

class _ProfileSettingViewState extends State<GuestProfileSettingView> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode(); // 텍스트 필드 포커스 노드

  bool isEnabled = false;
  bool _hasChanges = false; // 변경사항 추적
  bool _showNicknameError = false; // 닉네임 에러 표시 여부
  String? _originalNickname; // 원본 닉네임

  @override
  void initState() {
    super.initState();

    final user = UserService().getUser();
    if (user != null) {
      _nameController.text = user.name;
      _originalNickname = user.name;
    }

    _nameController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (mounted) {
      setState(() {}); // 입력값 변경 시 버튼 활성화 조건 재평가
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onInputChanged);
    _nameController.dispose();
    _nameFocusNode.dispose(); // FocusNode 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 600 : double.infinity,
                  maxHeight:
                      isTablet
                          ? MediaQuery.of(context).size.height
                          : double.infinity, // 태블릿에서 세로 크기 조정
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: isTablet ? 20 : 0, // 태블릿에서 세로 패딩 추가
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppUtil.getTopPadding(context) == 80
                              ? SizedBox(height: 10)
                              : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '프로필을 설정해볼까요?',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                          TextField(
                            maxLength: 10,
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            cursorColor: Colors.blue,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  isEnabled = value.isNotEmpty ? true : false;
                                  if (_showNicknameError && value.isNotEmpty) {
                                    _showNicknameError = false;
                                  }
                                });
                              }
                            },
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      _showNicknameError
                                          ? Colors.red
                                          : const Color.fromARGB(
                                            255,
                                            216,
                                            216,
                                            216,
                                          ),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color:
                                      _showNicknameError
                                          ? Colors.red
                                          : Colors.blue,
                                  width: 1,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 1,
                                ),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              labelStyle: TextStyle(color: Colors.black),
                              hintText: '닉네임을 입력해주세요',
                              hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 48, 48, 48),
                              ),
                              errorText:
                                  _showNicknameError ? '닉네임이 필요해요' : null,
                              errorStyle: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          if (!isKeyboardOpen)
                            _buildSkipButton(() async {
                              Player? p = UserService().getUser();
                              if (p == null) return;
                              if (_nameController.text.isNotEmpty) {
                                UserService().setGuestPlayer(
                                  p.userId,
                                  _nameController.text,
                                );

                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                  "guest_name",
                                  _nameController.text,
                                );

                                widget.callFromWhere != "onboarding"
                                    ? Navigator.pop(context, _hasChanges)
                                    : Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeView(),
                                      ),
                                    );
                              }
                            }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButton(Function() onTap) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final buttonHeight = isTablet ? 55.0 : 60.0; // 태블릿에서 버튼 높이 조정

    // 버튼 활성화 조건: 닉네임이 비어있지 않고, 닉네임 또는 이미지가 바뀐 경우
    final bool isNicknameNotEmpty = _nameController.text.trim().isNotEmpty;
    final bool isNicknameChanged =
        _nameController.text.trim() != (_originalNickname ?? '');

    final bool canSubmit = (isNicknameNotEmpty && isNicknameChanged);
    _hasChanges = canSubmit;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isTablet ? 20.0 : 24.0,
        top: isTablet ? 2.0 : 2.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? 12 : 15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canSubmit ? onTap : null,
            child: Ink(
              width: double.infinity,
              height: buttonHeight,
              decoration: BoxDecoration(
                color:
                    canSubmit
                        ? Colors.blue
                        : const Color.fromARGB(255, 216, 216, 216),
              ),
              child: Center(
                child: Text(
                  '완료하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
