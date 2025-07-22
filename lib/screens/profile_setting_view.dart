import 'package:camera/camera.dart';
import 'package:esc/screens/home_view.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:esc/service/user_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class ProfileSettingView extends StatefulWidget {
  final String callFromWhere;
  const ProfileSettingView({super.key, required this.callFromWhere});

  @override
  State<ProfileSettingView> createState() => _ProfileSettingViewState();
}

class _ProfileSettingViewState extends State<ProfileSettingView> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode(); // 텍스트 필드 포커스 노드
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _previewKey = GlobalKey(); // 프리뷰 캡처용 키
  bool isEnabled = false;
  bool _isUploading = false; // 업로드 중 상태
  bool _hasChanges = false; // 변경사항 추적
  bool _showNicknameError = false; // 닉네임 에러 표시 여부
  File? _selectedImage;
  String? _profileImageUrl; // 프로필 이미지 URL
  String? _originalNickname; // 원본 닉네임
  String? _originalProfileImageUrl; // 원본 프로필 이미지 URL
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraMode = false; // 카메라 프리뷰 활성화 여부
  bool _isTakingPicture = false; // 사진 촬영 중 여부
  bool _showBlackOverlay = false; // 검은 오버레이 표시 여부

  @override
  void initState() {
    super.initState();
    _initCamera();
    // UserService에서 닉네임과 프로필 이미지 URL 받아오기
    final user = UserService().getUser();
    if (user != null) {
      _nameController.text = user.name ?? '';
      _profileImageUrl = user.profileImageUrl;
      _originalNickname = user.name ?? '';
      _originalProfileImageUrl = user.profileImageUrl;
    }
    _nameController.addListener(_onInputChanged);

    // 자동 포커스 기능 제거
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _nameFocusNode.requestFocus();
    // });
  }

  void _onInputChanged() {
    setState(() {}); // 입력값 변경 시 버튼 활성화 조건 재평가
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      final frontCamera = _cameras?.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      _cameraController = CameraController(
        frontCamera!,
        ResolutionPreset.low,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('카메라 초기화 오류: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _nameController.removeListener(_onInputChanged);
    _nameController.dispose();
    _nameFocusNode.dispose(); // FocusNode 해제
    super.dispose();
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
            '프로필 이미지 선택',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isCameraMode = true;
                    _selectedImage = null;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.person_outline, color: Colors.blue),
                title: Text('기본 이미지 사용'),
                onTap: () async {
                  Navigator.pop(context);
                  // 파이어베이스에서 기존 이미지 삭제
                  if (_profileImageUrl != null) {
                    await UserService().deleteProfileImage(); // 이 함수는 직접 구현 필요
                  }
                  setState(() {
                    _selectedImage = null;
                    _profileImageUrl = null;
                    _isCameraMode = false;
                    _hasChanges = true; // 변경사항 있음
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isUploading = true; // 업로드 시작
        });

        // 즉시 업로드 시작
        _uploadImageInBackground(_selectedImage!);
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  // 백그라운드에서 이미지 업로드
  Future<void> _uploadImageInBackground(File imageFile) async {
    try {
      final success = await UserService().uploadProfileImage(imageFile);
      if (success) {
        print('이미지 업로드 성공');
        _hasChanges = true; // 변경사항 표시
        // 업로드 완료 후 UserService에서 최신 데이터 가져오기
        await UserService().initializeUser(UserService().userId!);
        setState(() {
          _profileImageUrl = UserService().profileImageUrl;
          _isUploading = false;
        });
      } else {
        setState(() {
          _isUploading = false;
        });
        AppUtil.showErrorSnackbar(context, message: '이미지 업로드에 실패했어요.');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print('백그라운드 업로드 오류: $e');
      AppUtil.showErrorSnackbar(context, message: '이미지 업로드 중 오류가 발생했어요.');
    }
  }

  // 프리뷰 캡처 방식으로 사진 촬영
  Future<void> _capturePreview() async {
    if (_isTakingPicture) return;

    setState(() {
      _isTakingPicture = true;
    });

    try {
      // RepaintBoundary를 사용해서 프리뷰 위젯을 이미지로 캡처
      final RenderRepaintBoundary boundary =
          _previewKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        // 임시 파일로 저장
        final Uint8List imageBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final file = File(
          '${tempDir.path}/captured_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(imageBytes);

        // 이미지 미리 캐싱
        await precacheImage(FileImage(file), context);

        setState(() {
          _selectedImage = file;
          _isCameraMode = false;
          _isTakingPicture = false;
          _isUploading = true; // 업로드 시작
          if (!isEnabled) {
            isEnabled = true;
          }
        });

        // 즉시 업로드 시작
        _uploadImageInBackground(file);
      } else {
        setState(() {
          _isTakingPicture = false;
        });
        print('이미지 캡처 실패');
      }
    } catch (e) {
      setState(() {
        _isTakingPicture = false;
      });
      print('프리뷰 캡처 오류: $e');
    }
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
                              setState(() {
                                isEnabled = value.isNotEmpty ? true : false;
                                if (_showNicknameError && value.isNotEmpty) {
                                  _showNicknameError = false;
                                }
                              });
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
                          if (!isKeyboardOpen) _buildLeeImage(null),
                          if (!isKeyboardOpen) _buildActionButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // 사진 찍는 순간에는 로딩 오버레이를 띄우지 않음
        // if (_isTakingPicture)
        //   Container(
        //     color: Colors.black.withOpacity(0.2),
        //     child: Center(
        //       child: CircularProgressIndicator(
        //         color: Colors.blue,
        //         strokeWidth: 4,
        //       ),
        //     ),
        //   ),
        if (_showBlackOverlay) Container(color: Colors.black),
      ],
    );
  }

  Widget _buildSkipButton(Function() onTap, bool isEnabled) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final buttonHeight = isTablet ? 55.0 : 60.0; // 태블릿에서 버튼 높이 조정

    // 버튼 활성화 조건: 닉네임이 비어있지 않고, 닉네임 또는 이미지가 바뀐 경우
    final bool isNicknameNotEmpty = _nameController.text.trim().isNotEmpty;
    final bool isNicknameChanged =
        _nameController.text.trim() != (_originalNickname ?? '');
    final bool isImageChanged =
        (_selectedImage != null) ||
        (_profileImageUrl != _originalProfileImageUrl);
    final bool canSubmit =
        isNicknameNotEmpty &&
        (isNicknameChanged || isImageChanged) &&
        !_isUploading;

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
                child:
                    _isUploading
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ],
                        )
                        : Text(
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

  Widget _buildActionButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final buttonHeight = isTablet ? 55.0 : 60.0; // 태블릿에서 버튼 높이 조정

    // 카메라 모드에서 사진을 아직 안 찍었으면 사진찍기 버튼
    if (_isCameraMode && _isCameraInitialized && _selectedImage == null) {
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
              onTap: () async {
                await _capturePreview();
              },
              child: Ink(
                width: double.infinity,
                height: buttonHeight,
                decoration: BoxDecoration(color: Colors.blue),
                child: Center(
                  child:
                      _isTakingPicture
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            '사진 찍기',
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
    } else {
      // 사진 없이 계속하기(건너뛰기) 버튼
      return _buildSkipButton(() async {
        // 닉네임이 비어있으면 에러 표시
        if (_nameController.text.trim().isEmpty) {
          setState(() {
            _showNicknameError = true;
          });
          return;
        }

        if (_nameController.text.isEmpty) {
          setState(() {
            isEnabled = true;
          });
        } else if (widget.callFromWhere == 'setting') {
          // 업로드가 진행 중이면 완료될 때까지 대기
          while (_isUploading) {
            await Future.delayed(Duration(milliseconds: 100));
          }

          // 닉네임만 업데이트 (이미지는 이미 업로드됨)
          final nickname = _nameController.text.trim();
          if (nickname.isNotEmpty && nickname != _originalNickname) {
            await UserService().updateNickname(nickname);
            _hasChanges = true; // 변경사항 표시
          }
          Navigator.pop(context, _hasChanges); // 변경사항 여부 전달
        } else {
          // 업로드가 진행 중이면 완료될 때까지 대기
          while (_isUploading) {
            await Future.delayed(Duration(milliseconds: 100));
          }

          // 닉네임만 업데이트 (이미지는 이미 업로드됨)
          final nickname = _nameController.text.trim();
          if (nickname.isNotEmpty) {
            await UserService().updateNickname(nickname);
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeView()),
          );
        }
      }, _nameController.text.isNotEmpty);
    }
  }

  Widget _buildLeeImage(String? imageUrl) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = constraints.maxWidth * 1.2;
        final coinSize = imageSize * 0.32;
        final coinTop = imageSize * 0.006;
        final coinRight = imageSize * 0.215;
        final isCameraPreview =
            _isCameraMode && _isCameraInitialized && _selectedImage == null;

        Widget imageWidget = Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/lee.png',
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: coinTop,
              right: coinRight,
              child: GestureDetector(
                onTap: _showImagePickerDialog,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(coinSize / 2),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color.fromARGB(255, 222, 222, 222),
                            width: 0.5,
                          ),
                        ),
                        width: coinSize,
                        height: coinSize,
                        child: Center(
                          child:
                              _selectedImage != null
                                  ? Image.file(
                                    _selectedImage!,
                                    width: coinSize,
                                    height: coinSize,
                                    fit: BoxFit.cover,
                                  )
                                  : (_isCameraMode &&
                                      _isCameraInitialized &&
                                      _selectedImage == null)
                                  ? RepaintBoundary(
                                    key: _previewKey,
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: coinSize,
                                        height: coinSize,
                                        child: CameraPreview(
                                          _cameraController!,
                                        ),
                                      ),
                                    ),
                                  )
                                  : (_profileImageUrl != null &&
                                      _profileImageUrl!.isNotEmpty)
                                  ? CachedNetworkImage(
                                    imageUrl: _profileImageUrl!,
                                    width: coinSize,
                                    height: coinSize,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => Container(
                                          width: coinSize,
                                          height: coinSize,
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                    errorWidget:
                                        (context, url, error) => Container(
                                          width: coinSize,
                                          height: coinSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color.fromARGB(
                                              255,
                                              216,
                                              216,
                                              216,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.person,
                                              size: coinSize * 0.7,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                  )
                                  : Container(
                                    width: coinSize,
                                    height: coinSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color.fromARGB(
                                        255,
                                        216,
                                        216,
                                        216,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        size: coinSize * 0.7,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 10,
                      child: Container(
                        width: coinSize * 0.2,
                        height: coinSize * 0.2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: coinSize * 0.15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        if (isCameraPreview || _isTakingPicture) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _isCameraMode = false;
              });
            },
            child: imageWidget,
          );
        } else {
          return imageWidget;
        }
      },
    );
  }
}
