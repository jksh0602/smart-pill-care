// lib/screens/guardian/guardian_dashboard_screen.dart
import '../home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/medication_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/medication_provider.dart';
import 'add_elder_sheet.dart';
import 'elder_detail_screen.dart';

class GuardianDashboardScreen extends StatelessWidget {
  const GuardianDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guardian = context.watch<AuthProvider>().currentUser;
    if (guardian == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final linkedCodes = guardian.linkedElderCodes ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${guardian.name}님 👋',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Text(
                            '보호자 대시보드',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: '어르신 추가',
                          onPressed: () => _addElder(context, guardian),
                          icon: const Icon(Icons.person_add_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: '로그아웃',
                          onPressed: () => context.read<AuthProvider>().signOut(),
                          icon: const Icon(Icons.logout_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.bgSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (linkedCodes.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(
                  onAdd: () => _addElder(context, guardian),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ElderCard(
                        snrCode: linkedCodes[i],
                      ),
                    ),
                    childCount: linkedCodes.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addElder(BuildContext context, AppUser guardian) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AuthProvider>(),
        child: AddElderSheet(guardianUid: guardian.uid),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('👴', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 20),
        const Text('연결된 어르신이 없습니다',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        const Text('어르신의 SNR 코드를 입력해서\n복약 현황을 모니터링하세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary,
            height: 1.6)),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('SNR 코드로 어르신 추가'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(220, 52)),
        ),
      ]),
    ),
  );
}

class _ElderCard extends StatelessWidget {
  final String snrCode;
  const _ElderCard({required this.snrCode});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collection('users')
        .where('snrCode', isEqualTo: snrCode)
        .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snap.hasError) {
          return const SizedBox(
            height: 90,
            child: Center(child: Text('어르신 정보를 불러오지 못했습니다.')),
          );
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('SNR 코드 $snrCode 에 해당하는 어르신이 없습니다.'),
          );
        }
        final doc = snap.data!.docs.first;
        final elder = AppUser.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);

        return ChangeNotifierProvider(
          create: (_) => MedicationProvider()..subscribe(elder.snrCode),
          child: Consumer<MedicationProvider>(
            builder: (ctx, medProv, _) {
              final rate = medProv.todayRate;
              final hasOverdue = medProv.todayMeds.any(
                (m) => m.status == MedStatus.pending && m.isOverdue);
              final allDone = medProv.todayMeds.isNotEmpty &&
                medProv.todayMeds.every((m) => m.status == MedStatus.taken);

              final borderColor = hasOverdue ? AppColors.warning
                : allDone ? AppColors.success
                : AppColors.primary.withOpacity(0.15);

              return GestureDetector(
                onTap: () => Navigator.push(ctx, MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => MedicationProvider(),
                    child: ElderDetailScreen(elder: elder),
                  ),
                )),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle),
                      child: const Center(
                        child: Text('👴',
                          style: TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(elder.name,
                              style: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                            const SizedBox(width: 6),
                            Text('${elder.age ?? '-'}세',
                              style: const TextStyle(fontSize: 13,
                                color: AppColors.textSecondary)),
                            const Spacer(),
                            if (hasOverdue)
                              _chip('미복약 주의',
                                AppColors.warning, AppColors.warningLight)
                            else if (allDone)
                              _chip('복약 완료',
                                AppColors.success, AppColors.successLight),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: rate,
                                  minHeight: 6,
                                  backgroundColor: AppColors.bgSecondary,
                                  valueColor: AlwaysStoppedAnimation(
                                    rate >= 1.0 ? AppColors.success
                                    : rate >= 0.5 ? AppColors.warning
                                    : AppColors.danger),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('${(rate * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right,
                      color: AppColors.textHint, size: 22),
                  ]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _chip(String text, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg,
      borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(fontSize: 11, color: fg,
      fontWeight: FontWeight.w700)),
  );
}
