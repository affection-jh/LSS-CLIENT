import 'package:esc/screens/onboarding_view.dart';
import 'package:esc/service/auth_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:esc/utill/bottom_sheet.dart';
import 'package:flutter/material.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isEditingNickname = false;
  bool _isEditingProfileImage = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = UserService().getUser()?.name ?? '사용자님';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 프로필 섹션
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 프로필 이미지
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditingProfileImage = true;
                      });
                      _showImagePickerDialog();
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          child: ClipOval(
                            child:
                                UserService().profileImageUrl != null &&
                                    UserService().profileImageUrl!.isNotEmpty
                                ? Image.network(
                                    UserService().profileImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color.fromARGB(
                                          255,
                                          216,
                                          216,
                                          216,
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: const Color.fromARGB(
                                      255,
                                      216,
                                      216,
                                      216,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 150, 150),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // 닉네임
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      if (_isEditingNickname) ...[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color.fromARGB(255, 255, 150, 150),
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: _nicknameController,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: '닉네임을 입력하세요',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            if (_nicknameController.text.trim().isNotEmpty) {
                              bool success = await UserService().updateNickname(
                                _nicknameController.text.trim(),
                              );
                              if (success) {
                                setState(() {
                                  _isEditingNickname = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('닉네임이 변경되었습니다.'),
                                    backgroundColor: Colors.black,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('닉네임 변경에 실패했습니다.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: Icon(Icons.check, color: Colors.black87),
                        ),
                      ] else ...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isEditingNickname = true;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _nicknameController.text,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.edit, color: Colors.grey, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 설정 메뉴들
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: '도움말',
                    subtitle: '게임 방법을 알아보세요',
                    onTap: () {
                      showCustomBottomSheet(
                        context: context,
                        content: _buildHelpContent(),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // 법적 정보
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.privacy_tip_outlined,
                    title: '개인정보 처리방침',
                    subtitle: '개인정보 수집 및 이용에 대해 알아보세요',
                    onTap: () {
                      showCustomBottomSheet(
                        context: context,
                        content: _buildPrivacyContent(),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.description_outlined,
                    title: '이용약관',
                    subtitle: '서비스 이용약관을 확인하세요',
                    onTap: () {
                      showCustomBottomSheet(
                        context: context,
                        content: _buildTermsContent(),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // 계정 관리
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.logout,
                    title: '로그아웃',
                    subtitle: '계정에서 로그아웃합니다',
                    onTap: () {
                      _showLogoutDialog('로그아웃');
                    },
                    textColor: Colors.black87,
                    iconColor: const Color.fromARGB(255, 255, 150, 150),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.person_remove_outlined,
                    title: '탈퇴하기',
                    subtitle: '계정을 탈퇴합니다',
                    onTap: () {
                      _showLogoutDialog('탈퇴');
                    },
                    textColor: Colors.red,
                    iconColor: const Color.fromARGB(255, 255, 150, 150),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // 앱 버전 정보
            Text(
              '버전 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '프로필 이미지 변경',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '현재는 기본 이미지만 사용 가능합니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              Text(
                '추후 업데이트에서 이미지 업로드 기능이 추가될 예정입니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isEditingProfileImage = false;
                });
              },
              child: Text(
                '확인',
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 150, 150),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 235, 235),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color:
                    iconColor ??
                    textColor ??
                    const Color.fromARGB(255, 255, 150, 150),
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.grey[200],
    );
  }

  Widget _buildHelpContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이순신 게임 도움말',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 20),
        _buildHelpItem(
          title: '게임 시작',
          content: '방장이 게임을 시작하면 모든 플레이어가 순서대로 동전을 던집니다.',
        ),
        _buildHelpItem(
          title: '동전 던지기',
          content:
              '각 플레이어는 두 개의 동전을 던져 앞면/뒷면을 결정합니다.\n만약 동전 두개가 모두 뒷면이라면 진행 방향이 바뀝니다.',
        ),
        _buildHelpItem(title: '이순신 찾기', content: '동전이 모두 앞면인 플레이어가 당첨됩니다.'),
        _buildHelpItem(
          title: '게임 종료',
          content: '시간이 끝나거나 이순신이 결정되면 게임이 종료됩니다.',
        ),
      ],
    );
  }

  Widget _buildHelpItem({required String title, required String content}) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 255, 150, 150),
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '개인정보 처리방침',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 20),
        Text(
          '이순신 게임은 사용자의 개인정보를 안전하게 보호합니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
        SizedBox(height: 16),
        Text(
          '수집하는 정보:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '• 닉네임\n• 프로필 이미지\n• 게임 참여 기록',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
        SizedBox(height: 16),
        Text(
          '이용 목적:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '• 게임 서비스 제공\n• 사용자 식별\n• 게임 기록 관리',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
      ],
    );
  }

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이용약관',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 20),
        Text(
          '이순신 게임 서비스 이용약관입니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
        SizedBox(height: 16),

        // 제1조
        Text(
          '제1조 (목적)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '이 약관은 이순신 게임 서비스의 이용과 관련하여 사용자와 서비스 제공자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
        SizedBox(height: 16),

        // 제2조
        Text(
          '제2조 (서비스 이용)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '사용자는 서비스를 이용함에 있어 관련 법령 및 이 약관을 준수해야 하며, 다른 사용자의 서비스 이용을 방해해서는 안 됩니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
        SizedBox(height: 16),

        // 제3조
        Text(
          '제3조 (회원 탈퇴 및 이용 제한)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '사용자가 약관을 위반하거나 서비스 운영을 방해하는 경우, 서비스 이용을 제한하거나 탈퇴 조치할 수 있습니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
        SizedBox(height: 16),

        // 제4조
        Text(
          '제4조 (지적재산권)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '서비스에 포함된 모든 콘텐츠와 자료의 저작권은 운영자 또는 정당한 권리자에게 있으며, 무단 복제 및 배포를 금지합니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
        SizedBox(height: 16),

        // 제5조
        Text(
          '제5조 (면책 조항)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '운영자는 천재지변, 기술적 장애 등 불가항력적인 사유로 인한 서비스 중단에 대해 책임을 지지 않습니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
        SizedBox(height: 16),

        // 제6조
        Text(
          '제6조 (약관 변경)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '약관은 필요한 경우 변경될 수 있으며, 변경 시 앱 내 공지를 통해 사용자에게 안내합니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _showLogoutDialog(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            '정말로 $title 하시겠습니까?',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                if (title == '로그아웃') {
                  await AuthService.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => OnboardingView()),
                    (route) => false,
                  );
                } else {
                  // 회원 탈퇴 처리
                  bool success = await AuthService.deleteAccount();
                  if (success) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => OnboardingView()),
                      (route) => false,
                    );
                  } else {
                    // 탈퇴 실패 시 에러 메시지 표시
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('회원 탈퇴에 실패했습니다. 다시 시도해주세요.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(
                '확인',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
