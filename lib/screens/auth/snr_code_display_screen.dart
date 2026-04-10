// lib/screens/auth/snr_code_display_screen.dart
// 어르신 회원가입 완료 후 발급된 SNR 코드를 크게 보여주는 화면

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../elder/elder_main_screen.dart';

class SnrCodeDisplayScreen extends StatelessWidget {
  final String snrCode;
  final String name;

  const SnrCodeDisplayScreen({
    super.key,
    required this.snrCode,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            children: [
              const Spacer(),
              // 성공 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '$name 님,\n환영합니다!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '아래 고유 관리 번호(SNR)를\n보호자에게 알려주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              // SNR 코드 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '나의 관리 번호',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      snrCode,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 복사 버튼
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: snrCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('복사되었습니다!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              '번호 복사하기',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDE7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Text('⚠️', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '이 번호는 마이페이지에서 언제든지\n다시 확인할 수 있습니다.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF92400E),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const ElderMainScreen()),
                  (route) => false,
                ),
                child: const Text('복약 관리 시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
