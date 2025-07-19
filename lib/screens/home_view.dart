import 'package:esc/screens/join_view.dart';
import 'package:esc/screens/making_view.dart';
import 'package:esc/screens/setting_view.dart';
import 'package:esc/service/manage_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//158.179.174.166

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  initState() {
    super.initState();
    context.read<GameManager>().disconnect();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 255, 255, 255),
              const Color.fromARGB(255, 255, 219, 219),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  SizedBox(height: height * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingView(),
                              ),
                            );
                          },
                          icon: Icon(Icons.menu, size: 20),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${UserService().getUser()?.name}님 환영해요,",
                              style: TextStyle(
                                fontSize: 18,
                                color: const Color.fromARGB(255, 86, 86, 86),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "오늘도 달려볼까요?",
                              style: TextStyle(
                                fontSize: 30,
                                color: const Color.fromARGB(255, 30, 30, 30),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  SizedBox(height: width > 600 ? height * 0.2 : 10),

                  Row(
                    children: [
                      Spacer(),
                      SizedBox(
                        height: height * 0.45,
                        width: width * 0.6,
                        child: Image.asset("assets/cute_lee.png"),
                      ),
                    ],
                  ),
                  _buildingButton(context),
                  _joiningButton(context),
                  SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildingButton(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BuildingView()),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Ink(
            height: 100,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "게임 방 만들기",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "언제 어디서든 가볍게 즐겨보세요.",
                          style: TextStyle(
                            fontSize: 15,
                            color: const Color.fromARGB(255, 100, 100, 100),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _joiningButton(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 20, vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GameJoiningView()),
            );
          },
          borderRadius: BorderRadius.circular(30),
          child: Ink(
            height: 150,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 25, 25, 25),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "게임 참여하기",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "초대 코드로 친구들과 함께",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
