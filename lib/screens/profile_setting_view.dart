import 'package:esc/screens/home_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileSettingView extends StatefulWidget {
  @override
  State<ProfileSettingView> createState() => _ProfileSettingViewState();
}

class _ProfileSettingViewState extends State<ProfileSettingView> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool isEnabled = false;
  File? _selectedImage;
  //final CameraController _cameraController = CameraController();
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
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
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
        });
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, scrolledUnderElevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('프로필을 설정해볼까요?', style: TextStyle(fontSize: 24)),
                SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  cursorColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      isEnabled = value.isNotEmpty ? true : false;
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 216, 216, 216),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: '닉네임을 입력해주세요',
                    hintStyle: TextStyle(
                      color: const Color.fromARGB(255, 48, 48, 48),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                _buildLeeImage(null),
                _buildSkipButton(() {
                  if (_nameController.text.isEmpty) {
                    setState(() {
                      isEnabled = true;
                    });
                  } else {
                    // 이름이 입력된 경우 처리
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeView()),
                    );
                  }
                }, _nameController.text.isNotEmpty),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton(Function() onTap, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: isEnabled
                    ? Colors.blue
                    : const Color.fromARGB(255, 216, 216, 216),
              ),
              child: Center(
                child: Text(
                  '건너뛰기',
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

  Widget _buildLeeImage(String? imageUrl) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 화면 크기에 따라 이미지 크기 조정

        final imageSize = constraints.maxWidth * 1.2; // 화면 너비의 80%
        final coinSize = imageSize * 0.32; // 이미지 크기의 16%

        // 동전 위치를 이미지 크기에 비례하여 계산
        final coinTop = imageSize * 0.001; // 이미지 높이의 16.8%
        final coinRight = imageSize * 0.21; // 이미지 너비의 25.2%

        return Stack(
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
                            color: const Color.fromARGB(255, 212, 212, 212),
                            width: 0.5,
                          ),
                        ),
                        width: coinSize,
                        height: coinSize,
                        child: Center(
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  width: coinSize,
                                  height: coinSize,
                                  fit: BoxFit.cover,
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
                    // + 버튼
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
      },
    );
  }
}
