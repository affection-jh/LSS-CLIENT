import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

enum CoinState { head, tail }

class CoinSpinWidget extends StatefulWidget {
  final bool clickable;
  final double coinSize;
  final double coinSpacing;

  // 각 동전별 콜백 추가
  final Function(String) onCoin1Stopped;
  final Function(String) onCoin2Stopped;

  const CoinSpinWidget({
    super.key,
    required this.onCoin1Stopped,
    required this.onCoin2Stopped,
    this.clickable = true,
    this.coinSize = 180,
    this.coinSpacing = 100,
  });

  @override
  State<CoinSpinWidget> createState() => _CoinSpinWidgetState();
}

class _CoinSpinWidgetState extends State<CoinSpinWidget>
    with TickerProviderStateMixin {
  late AnimationController _coinController1;
  late AnimationController _coinController2;
  late AnimationController _coinController3;
  late AnimationController _coinController4;
  bool isCoin1Spinning = true;
  bool isCoin2Spinning = true;
  Timer? _speedChangeTimer;
  final Random _random = Random();

  // 중복 호출 방지를 위한 플래그
  bool _isProcessingCoin1 = false;
  bool _isProcessingCoin2 = false;

  @override
  void initState() {
    super.initState();
    // 첫 번째 동전: X축 회전 (빠름)
    _coinController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat();

    // 첫 번째 동전: Y축 회전 (중간)
    _coinController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat();

    // 두 번째 동전: X축 회전 (느림)
    _coinController3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat();

    // 두 번째 동전: Y축 회전 (빠름)
    _coinController4 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat();

    // 랜덤하게 속도 변경
    _startRandomSpeedChanges();
  }

  void _startRandomSpeedChanges() {
    _speedChangeTimer = Timer.periodic(const Duration(milliseconds: 800), (
      timer,
    ) {
      if (!isCoin1Spinning && !isCoin2Spinning) {
        timer.cancel();
        return;
      }

      // 랜덤하게 속도 변경
      final newDuration1 = Duration(milliseconds: 100 + _random.nextInt(200));
      final newDuration2 = Duration(milliseconds: 150 + _random.nextInt(250));
      final newDuration3 = Duration(milliseconds: 120 + _random.nextInt(180));
      final newDuration4 = Duration(milliseconds: 80 + _random.nextInt(160));

      if (mounted) {
        setState(() {
          _coinController1.duration = newDuration1;
          _coinController2.duration = newDuration2;
          _coinController3.duration = newDuration3;
          _coinController4.duration = newDuration4;
        });
      }
    });
  }

  @override
  void dispose() {
    _speedChangeTimer?.cancel();
    _coinController1.dispose();
    _coinController2.dispose();
    _coinController3.dispose();
    _coinController4.dispose();
    super.dispose();
  }

  Future<void> _stopCoin1() async {
    if (!isCoin1Spinning || _isProcessingCoin1) return;

    _isProcessingCoin1 = true;

    if (mounted) {
      setState(() => isCoin1Spinning = false);
    }

    _coinController1.stop();
    _coinController2.stop();

    final currentY = _coinController2.value * 2 * pi;
    final normalizedAngle = currentY % (2 * pi);

    // 새로운 앞뒤 판별 로직
    CoinState result;
    double targetAngle;

    // 0~π/2 또는 3π/2~2π 범위면 앞면, π/2~3π/2 범위면 뒷면
    if ((normalizedAngle >= 0 && normalizedAngle < pi / 2) ||
        (normalizedAngle >= 3 * pi / 2 && normalizedAngle < 2 * pi)) {
      result = CoinState.head;
      targetAngle = 0;
    } else {
      result = CoinState.tail;
      targetAngle = pi;
    }

    // 동전을 정확한 각도로 보정
    _coinController1.value = 0;
    _coinController2.value = targetAngle / (2 * pi);
    _isProcessingCoin1 = false;

    widget.onCoin1Stopped(result == CoinState.head ? "head" : "tail");
  }

  Future<void> _stopCoin2() async {
    if (!isCoin2Spinning || _isProcessingCoin2) return;

    _isProcessingCoin2 = true;

    if (mounted) {
      setState(() => isCoin2Spinning = false);
    }

    _coinController3.stop();
    _coinController4.stop();

    final currentY = _coinController4.value * 2 * pi;
    final normalizedAngle = currentY % (2 * pi);

    // 새로운 앞뒤 판별 로직
    CoinState result;
    double targetAngle;

    // 0~π/2 또는 3π/2~2π 범위면 앞면, π/2~3π/2 범위면 뒷면
    if ((normalizedAngle >= 0 && normalizedAngle < pi / 2) ||
        (normalizedAngle >= 3 * pi / 2 && normalizedAngle < 2 * pi)) {
      result = CoinState.head;
      targetAngle = 0;
    } else {
      result = CoinState.tail;
      targetAngle = pi;
    }

    // 동전을 정확한 각도로 보정
    _coinController3.value = 0;
    _coinController4.value = targetAngle / (2 * pi);
    _isProcessingCoin2 = false;

    // 두 번째 동전 콜백 호출
    widget.onCoin2Stopped(result == CoinState.head ? "head" : "tail");
  }

  bool isCoinFront(double normalizedAngle) {
    return ((normalizedAngle >= 0 && normalizedAngle < pi / 2) ||
        (normalizedAngle >= 3 * pi / 2 && normalizedAngle < 2 * pi));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 첫 번째 동전: X축과 Y축 동시 회전
        GestureDetector(
          onTap: widget.clickable && isCoin1Spinning ? _stopCoin1 : null,
          child: SizedBox(
            width: widget.coinSize + 20,
            height: widget.coinSize + 20,

            child: Center(
              child: SizedBox(
                width: widget.coinSize,
                height: widget.coinSize,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _coinController1,
                    _coinController2,
                  ]),
                  builder: (context, child) {
                    // 회전 각도 계산
                    final angleX = _coinController1.value * 2 * pi;
                    final angleY = _coinController2.value * 2 * pi;

                    // 새로운 앞뒤 판별 로직
                    bool isFront;
                    final normalizedAngle = angleY % (2 * pi);

                    if (isCoin1Spinning) {
                      // 돌고 있을 때는 새로운 로직
                      isFront = isCoinFront(normalizedAngle);
                    } else {
                      // 멈춘 상태일 때는 정확히 앞뒤만
                      isFront = isCoinFront(normalizedAngle);
                    }

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(isCoin1Spinning ? angleX : 0)
                        ..rotateY(angleY),
                      child: isFront
                          ? Image.asset(
                              'assets/coin_head.png',
                              width: widget.coinSize,
                              height: widget.coinSize,
                            )
                          : Image.asset(
                              'assets/coin_tail.png',
                              width: widget.coinSize,
                              height: widget.coinSize,
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: widget.coinSpacing),
        // 두 번째 동전: X축과 Y축 동시 회전 (다른 속도, 더 무질서)
        GestureDetector(
          onTap: widget.clickable && isCoin2Spinning ? _stopCoin2 : null,
          child: SizedBox(
            width: widget.coinSize + 20,
            height: widget.coinSize + 20,
            child: Center(
              child: SizedBox(
                width: widget.coinSize,
                height: widget.coinSize,
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _coinController3,
                    _coinController4,
                  ]),
                  builder: (context, child) {
                    final angleX = _coinController3.value * 2 * pi;
                    final angleY = _coinController4.value * 2 * pi;

                    // 새로운 앞뒤 판별 로직
                    bool isFront;
                    final normalizedAngle = angleY % (2 * pi);

                    if (isCoin2Spinning) {
                      // 돌고 있을 때는 새로운 로직
                      isFront = isCoinFront(normalizedAngle);
                    } else {
                      // 멈춘 상태일 때는 정확히 앞뒤만
                      isFront = isCoinFront(normalizedAngle);
                    }

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(isCoin2Spinning ? angleX : 0)
                        ..rotateY(angleY),
                      child: isFront
                          ? Image.asset(
                              'assets/coin_head.png',
                              width: widget.coinSize,
                              height: widget.coinSize,
                            )
                          : Image.asset(
                              'assets/coin_tail.png',
                              width: widget.coinSize,
                              height: widget.coinSize,
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
