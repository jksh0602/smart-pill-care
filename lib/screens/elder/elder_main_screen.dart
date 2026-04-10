// lib/screens/elder/elder_main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/medication_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medication_provider.dart';
import 'add_medication_screen.dart';

class ElderMainScreen extends StatefulWidget {
  const ElderMainScreen({super.key});

  @override
  State<ElderMainScreen> createState() => _ElderMainScreenState();
}

class _ElderMainScreenState extends State<ElderMainScreen> {
  bool _soundOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser!;
      context.read<MedicationProvider>().subscribe(user.snrCode);
    });
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = h < 12 ? '오전' : '오후';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$ampm $hour:$m';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final medProv = context.watch<MedicationProvider>();
    final allDone = medProv.todayMeds.isNotEmpty &&
      medProv.todayMeds.every((m) => m.status == MedStatus.taken);

    return Scaffold(
      backgroundColor: AppColors.elderBg,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user.name} 님',
                        style: const TextStyle(
                          color: Colors.white70, fontSize: 15,
                          fontWeight: FontWeight.w600)),
                      Text(user.snrCode,
                        style: const TextStyle(
                          color: Colors.white30, fontSize: 12,
                          fontFamily: 'monospace')),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                            AddMedicationScreen(elderSnrCode: user.snrCode))),
                        icon: const Icon(Icons.add_circle_outline,
                          color: Colors.white54, size: 26),
                      ),
                      IconButton(
                        onPressed: () =>
                          context.read<AuthProvider>().signOut(),
                        icon: const Icon(Icons.logout,
                          color: Colors.white30, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 알림 버튼
                    GestureDetector(
                      onTap: () => setState(() => _soundOn = !_soundOn),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.elderCard,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 20, spreadRadius: 2)],
                              ),
                              child: Icon(
                                _soundOn ? Icons.volume_off : Icons.volume_up,
                                color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _soundOn ? '알림이 켜졌습니다' : '여기를 터치해서\n알림 켜기',
                              style: const TextStyle(
                                color: Colors.white, fontSize: 17,
                                fontWeight: FontWeight.w700, height: 1.4)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 복약 목록
                    Expanded(
                      child: medProv.todayMeds.isEmpty
                        ? _EmptyMedState()
                        : ListView.separated(
                            itemCount: medProv.todayMeds.length,
                            separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                            itemBuilder: (_, i) =>
                              _MedCard(med: medProv.todayMeds[i],
                                formatTime: _formatTime),
                          ),
                    ),
                    if (allDone) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16)),
                        child: const Text(
                          '🎉 오늘 복약을 모두 완료했습니다!\n수고하셨습니다 👏',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.primary,
                            fontWeight: FontWeight.w700, fontSize: 15,
                            height: 1.5)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  final Medication med;
  final String Function(DateTime) formatTime;
  const _MedCard({required this.med, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    final isTaken = med.status == MedStatus.taken;
    final isOverdue = med.isOverdue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isTaken
          ? const Color(0xFF1E3A2F)
          : isOverdue ? const Color(0xFF3A1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(med.timeLabel,
                          style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isTaken
                              ? Colors.white60 : AppColors.textSecondary)),
                        if (isOverdue && !isTaken) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(20)),
                            child: const Text('시간 초과',
                              style: TextStyle(fontSize: 11,
                                color: AppColors.danger,
                                fontWeight: FontWeight.w700))),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(med.name,
                      style: TextStyle(fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isTaken
                          ? Colors.white70 : AppColors.textPrimary)),
                    Text(formatTime(med.scheduledAt),
                      style: TextStyle(fontSize: 13,
                        color: isTaken
                          ? Colors.white38 : AppColors.textSecondary)),
                  ],
                ),
              ),
              if (!isTaken)
                GestureDetector(
                  onTap: () =>
                    context.read<MedicationProvider>().takeMed(med.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(14)),
                    child: const Text('💊 먹었음',
                      style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14)),
                  child: const Text('✅ 완료',
                    style: TextStyle(color: AppColors.success,
                      fontWeight: FontWeight.w800, fontSize: 16)),
                ),
            ],
          ),
          if (isTaken && med.takenAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle,
                  color: AppColors.success, size: 14),
                const SizedBox(width: 6),
                Text('${formatTime(med.takenAt!)} 복용 완료',
                  style: const TextStyle(
                    fontSize: 12, color: AppColors.success)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyMedState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text('💊', style: TextStyle(fontSize: 48)),
        SizedBox(height: 16),
        Text('오늘 복약 일정이 없습니다',
          style: TextStyle(color: Colors.white60, fontSize: 16,
            fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text('+ 버튼으로 복약 일정을 추가해 보세요',
          style: TextStyle(color: Colors.white30, fontSize: 13)),
      ],
    ),
  );
}
