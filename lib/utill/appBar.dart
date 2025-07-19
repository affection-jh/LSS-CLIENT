import 'package:esc/screens/home_view.dart';
import 'package:esc/service/manage_service.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

PreferredSizeWidget buildAppBar(BuildContext context, bool isPresident) {
  return AppBar(
    backgroundColor: Colors.white,
    scrolledUnderElevation: 0,
    leading: Builder(
      builder: (context) => IconButton(
        onPressed: () async {
          bool? result = await AppUtil.ShowExitDiaglog(context, isPresident);
          if (result == true) {
            context.read<GameManager>().disconnect();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeView()),
              (route) => false,
            );
          }
        },
        icon: Icon(Icons.arrow_back_ios_new_rounded),
      ),
    ),
  );
}
