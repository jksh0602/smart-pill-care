// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_gate_screen.dart';
import '../../models/user_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8ECFF), Color(0xFFD0D9FF), Color(0xFFE0E8FF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // 타이틀
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '스마트 ',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2B2D6E),
                        ),
                      ),
                      TextSpan(
                        text: '복약 관리',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '안전하고 편리한 맞춤형 건강 케어 솔루션',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 60),
                // 모드 선택 카드
                Row(
                  children: [
                    Expanded(
                      child: _ModeCard(
                        emoji: '👴',
                        iconBgColor: const Color(0xFFE8F5E8),
                        title: '어르신 화면',
                        subtitle: '크고 직관적인\n1버튼 복약 확인',
                        onTap: () => _navigate(context, UserRole.elder),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ModeCard(
                        emoji: '👨‍👩‍👧',
                        iconBgColor: const Color(0xFFE8EEFF),
                        title: '보호자 화면',
                        subtitle: '실시간 데이터\n모니터링',
                        onTap: () => _navigate(context, UserRole.guardian),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthGateScreen(role: role),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String emoji;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({
    required this.emoji,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
