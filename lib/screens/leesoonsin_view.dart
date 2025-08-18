import 'package:esc/service/manage_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:esc/utill/appBar.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LeeSoonSinView extends StatefulWidget {
  const LeeSoonSinView({super.key});

  @override
  State<LeeSoonSinView> createState() => _LeeSoonSinViewState();
}

class _LeeSoonSinViewState extends State<LeeSoonSinView> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final gameManager = context.read<GameManager>();
    final isPresident =
        gameManager.currentSession!.presidentId ==
        UserService().getUser()?.userId;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(
          context,
          isPresident,
          category: gameManager.currentSession!.category,
        ),
        body: Consumer<GameManager>(
          builder: (context, gameManager, child) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 700 : double.infinity,
                  maxHeight: isTablet ? screenHeight : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: isTablet ? 20 : 0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "${gameManager.currentSession!.currentPlayer!.name} 장군님이 오셨어요!",
                              style: TextStyle(
                                fontSize: isTablet ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: _buildLeeImage(
                                gameManager
                                    .currentSession!
                                    .currentPlayer!
                                    .profileImageUrl,
                              ),
                            );
                          },
                        ),

                        if (gameManager.currentSession!.isPresident)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 24,
                              right: 24,
                              bottom: 10,
                              top: 1,
                            ),
                            child: Material(
                              color: ColorPalette.secondaryColor,
                              borderRadius: BorderRadius.circular(15),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  gameManager.continueLeeSoonSin();
                                  Future.delayed(Duration(seconds: 5), () {
                                    if (mounted) {
                                      AppUtil.showErrorSnackbar(
                                        context,
                                        message: "네트워크 연결을 확인해주세요.",
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    '계속하기',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        if (!gameManager.currentSession!.isPresident)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 24,
                              right: 24,
                              bottom: 10,
                              top: 1,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '방장이 계속하기를 누를 때까지 기다려주세요.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeeImage(String? imageUrl) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 태블릿에서는 이미지 크기를 적당히 조정
        final imageSize = constraints.maxWidth * 1.2; // 모바일용 기존 크기
        final coinSize = imageSize * 0.32;
        final coinTop = imageSize * 0.008;
        final coinRight = imageSize * 0.21;

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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(coinSize / 2),
                child: SizedBox(
                  width: coinSize,
                  height: coinSize,
                  child: Center(
                    child:
                        imageUrl != null && imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: coinSize,
                              height: coinSize,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
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
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
