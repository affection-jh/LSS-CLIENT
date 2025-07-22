import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class LeeImageLayout extends StatelessWidget {
  final String? profileImageUrl;
  final File? selectedImage;
  final VoidCallback? onImageTap;
  final Widget? actionButton;
  final bool showImagePicker;
  final double? maxWidth;
  final double? maxHeight;

  const LeeImageLayout({
    super.key,
    this.profileImageUrl,
    this.selectedImage,
    this.onImageTap,
    this.actionButton,
    this.showImagePicker = true,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = constraints.maxWidth * 1.2;
        final coinSize = imageSize * 0.32;
        final coinTop = imageSize * 0.006;
        final coinRight = imageSize * 0.215;

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
            if (showImagePicker)
              Positioned(
                top: coinTop,
                right: coinRight,
                child: GestureDetector(
                  onTap: onImageTap,
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
                          child: Center(child: _buildProfileImage(coinSize)),
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

        return Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? MediaQuery.of(context).size.width * 0.8,
                maxHeight:
                    maxHeight ?? MediaQuery.of(context).size.height * 0.6,
              ),
              child: imageWidget,
            ),
            if (actionButton != null) actionButton!,
          ],
        );
      },
    );
  }

  Widget _buildProfileImage(double coinSize) {
    if (selectedImage != null) {
      return Image.file(
        selectedImage!,
        width: coinSize,
        height: coinSize,
        fit: BoxFit.cover,
      );
    } else if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: profileImageUrl!,
        width: coinSize,
        height: coinSize,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: coinSize,
          height: coinSize,
          alignment: Alignment.center,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => Container(
          width: coinSize,
          height: coinSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromARGB(255, 216, 216, 216),
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: coinSize * 0.7,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: coinSize,
        height: coinSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromARGB(255, 216, 216, 216),
        ),
        child: Center(
          child: Icon(Icons.person, size: coinSize * 0.7, color: Colors.white),
        ),
      );
    }
  }
}
