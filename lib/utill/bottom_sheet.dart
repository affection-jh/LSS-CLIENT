import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget content;
  final double? height;
  final bool isScrollable;

  const CustomBottomSheet({
    super.key,

    required this.content,
    this.height,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height ?? MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 핸들
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(height: 10),

          // 내용
          Expanded(
            child: isScrollable
                ? SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(20),
                    child: content,
                  )
                : Padding(padding: EdgeInsets.all(20), child: content),
          ),
        ],
      ),
    );
  }
}

// 바텀시트를 쉽게 호출할 수 있는 함수
void showCustomBottomSheet({
  required BuildContext context,
  required Widget content,
  double? height,
  bool isScrollable = true,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
    builder: (context) => CustomBottomSheet(
      content: content,
      height: height,
      isScrollable: isScrollable,
    ),
  );
}
