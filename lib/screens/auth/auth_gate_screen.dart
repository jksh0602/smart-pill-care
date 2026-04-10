// lib/screens/auth/auth_gate_screen.dart
// 어르신/보호자 각각 → 로그인 or 회원가입 선택

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthGateScreen extends StatelessWidget {
  final UserRole role;
  const AuthGateScreen({super.key, required this.role});

  bool get isElder => role == UserRole.elder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 모드 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isElder
                  ? const Color(0xFFE8F5E8)
                  : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isElder ? '👴' : '👨‍👩‍👧',
                    style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    isElder ? '어르신 모드' : '보호자 모드',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isElder
                        ? const Color(0xFF166534)
                        : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '안녕하세요!\n계속하려면\n로그인해 주세요.',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isElder
                ? '회원가입 시 고유 관리 번호(SNR)가 발급됩니다.\n이 번호를 보호자에게 알려주세요.'
                : '로그인 후 어르신의 SNR 코드를 입력해서\n복약 상태를 모니터링하세요.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            // 로그인 버튼
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(role: role),
                ),
              ),
              child: const Text('로그인'),
            ),
            const SizedBox(height: 14),
            // 회원가입 버튼
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RegisterScreen(role: role),
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
