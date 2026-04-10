// lib/screens/guardian/elder_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/medication_model.dart';
import '../../models/user_model.dart';
import '../../providers/medication_provider.dart';

class ElderDetailScreen extends StatefulWidget {
  final AppUser elder;
  const ElderDetailScreen({super.key, required this.elder});

  @override
  State<ElderDetailScreen> createState() => _ElderDetailScreenState();
}

class _ElderDetailScreenState extends State<ElderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final prov = context.read<MedicationProvider>();
    prov.subscribe(widget.elder.snrCode);
    prov.loadStats(widget.elder.snrCode);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    width: 46, height: 46,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Center(
                      child: Text('👴', style: TextStyle(fontSize: 24))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${widget.elder.name} 어르신',
                          style: const TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                        Text(
                          '${widget.elder.age ?? '-'}세 · ${widget.elder.snrCode}',
                          style: const TextStyle(fontSize: 12,
                            color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_outlined, size: 16),
                    label: const Text('전화'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabs,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: '오늘 상태'),
                  Tab(text: '복약 캘린더/히스토리'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _TodayTab(elder: widget.elder),
                  _CalendarTab(elder: widget.elder),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  final AppUser elder;
  const _TodayTab({required this.elder});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MedicationProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card(
            title: '💊 오늘 복약 현황',
            badge: prov.todayMeds.any(
              (m) => m.status == MedStatus.pending && m.isOverdue)
              ? _badge('미복약 주의', AppColors.danger, AppColors.dangerLight)
              : null,
            child: prov.todayMeds.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('오늘 복약 일정이 없습니다',
                    style: TextStyle(color: AppColors.textSecondary)))
              : Column(
                  children: prov.todayMeds
                    .map((m) => _MedRow(med: m)).toList()),
          ),
          const SizedBox(height: 14),
          _card(
            title: '📊 오늘 복약률',
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: prov.todayRate,
                        minHeight: 10,
                        backgroundColor: AppColors.bgSecondary,
                        valueColor: AlwaysStoppedAnimation(
                          prov.todayRate >= 1.0 ? AppColors.success
                          : prov.todayRate >= 0.5 ? AppColors.warning
                          : AppColors.danger),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${(prov.todayRate * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _card(
            title: '🏃 움직임 센서',
            badge: _badge('활동 중', AppColors.success, AppColors.successLight),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                Container(width: 12, height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                const Text('활동 감지됨',
                  style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
                const Spacer(),
                const Text('마지막 감지: 10분 전',
                  style: TextStyle(fontSize: 12,
                    color: AppColors.textSecondary)),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2040),
              borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Text('✨', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text('AI 복약 패턴 분석',
                    style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA5B4FC))),
                ]),
                const SizedBox(height: 10),
                Text(_insight(prov),
                  style: const TextStyle(fontSize: 13,
                    color: Color(0xFFC7D2FE), height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _insight(MedicationProvider prov) {
    final r = prov.todayRate;
    if (r < 0.5) return '최근 복약 누락이 잦습니다. 보호자의 직접 확인이 필요해 보입니다.';
    if (r < 1.0) return '최근 3일간 점심 시간대의 복약 누락 빈도가 높습니다. 특정 시간대에 외출이 잦으신지 확인이 필요해 보입니다.';
    return '복약 상태가 양호합니다. 오늘도 모든 복약을 잘 챙기고 계십니다.';
  }

  Widget _card({required String title, Widget? badge, required Widget child}) =>
    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(title, style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          if (badge != null) ...[const SizedBox(width: 8), badge],
        ]),
        const SizedBox(height: 10),
        child,
      ]),
    );

  Widget _badge(String text, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(fontSize: 11, color: fg,
      fontWeight: FontWeight.w700)),
  );
}

class _MedRow extends StatelessWidget {
  final Medication med;
  const _MedRow({required this.med});

  @override
  Widget build(BuildContext context) {
    final isTaken = med.status == MedStatus.taken;
    final isOverdue = med.isOverdue;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTaken ? AppColors.successLight
          : isOverdue ? AppColors.warningLight : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Text(isTaken ? '✅' : isOverdue ? '⚠️' : '⏰',
          style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(med.name, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('${med.timeLabel} · ${_fmt(med.scheduledAt)}',
              style: const TextStyle(fontSize: 11,
                color: AppColors.textSecondary)),
          ],
        )),
        if (isTaken && med.takenAt != null)
          Text(_fmt(med.takenAt!), style: const TextStyle(fontSize: 12,
            color: AppColors.success, fontWeight: FontWeight.w600))
        else if (isOverdue)
          const Text('확인 필요', style: TextStyle(fontSize: 12,
            color: AppColors.warning, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  String _fmt(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    return '${h < 12 ? '오전' : '오후'} ${h == 0 ? 12 : h > 12 ? h - 12 : h}:$m';
  }
}

class _CalendarTab extends StatelessWidget {
  final AppUser elder;
  const _CalendarTab({required this.elder});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MedicationProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📅 최근 4주 복약 캘린더',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
                const SizedBox(height: 14),
                prov.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _CalGrid(calData: prov.calendarData),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _stat(
              '최근 30일 복약률',
              '${(prov.adherenceRate * 100).toStringAsFixed(0)}%',
              prov.adherenceRate >= 0.8 ? AppColors.success : AppColors.warning,
            )),
            const SizedBox(width: 12),
            Expanded(child: _stat(
              '완전 누락일',
              '${prov.calendarData.values.where((v) => v == 'red').length}일',
              AppColors.danger,
            )),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC7D2FE))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Text('💡', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('주간 AI 종합 리포트',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: Color(0xFF3B3F99))),
                ]),
                const SizedBox(height: 12),
                const Text(
                  '지난 달 대비 복약률이 5% 하락했습니다. 주로 주말(토/일) 오후 시간대에 복약 누락이 집중되는 패턴이 발견되었습니다.\n\n'
                  '주말에 외출이나 외부 일정이 있으신지 확인이 필요합니다.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF3B3F99),
                    height: 1.7)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44)),
                    child: const Text('복약 시간 변경',
                      style: TextStyle(fontSize: 13)),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      foregroundColor: const Color(0xFF3B3F99),
                      side: const BorderSide(color: Color(0xFF3B3F99))),
                    child: const Text('PDF 다운로드',
                      style: TextStyle(fontSize: 13)),
                  )),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      Text(label, style: const TextStyle(fontSize: 12,
        color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
        color: color)),
    ]),
  );
}

class _CalGrid extends StatelessWidget {
  final Map<String, String> calData;
  const _CalGrid({required this.calData});
  static const _days = ['월', '화', '수', '목', '금', '토', '일'];
  static const _colorMap = {
    'green': AppColors.success,
    'amber': AppColors.warning,
    'red':   AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1 + 21));
    return Column(children: [
      Row(children: _days.map((d) => Expanded(child: Center(
        child: Text(d, style: const TextStyle(fontSize: 11,
          color: AppColors.textSecondary, fontWeight: FontWeight.w600))))).toList()),
      const SizedBox(height: 6),
      ...List.generate(4, (w) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: List.generate(7, (d) {
          final date = start.add(Duration(days: w * 7 + d));
          final key = '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
          final status = calData[key];
          final future = date.isAfter(now);
          return Expanded(child: Container(
            margin: const EdgeInsets.all(2),
            height: 30,
            decoration: BoxDecoration(
              color: future ? AppColors.bgSecondary
                : status != null ? _colorMap[status]!.withOpacity(0.8)
                : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(7)),
          ));
        })),
      )),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _leg(AppColors.success, '정상'),
        const SizedBox(width: 16),
        _leg(AppColors.warning, '누락(부분)'),
        const SizedBox(width: 16),
        _leg(AppColors.danger, '완전누락'),
      ]),
    ]);
  }

  Widget _leg(Color c, String t) => Row(children: [
    Container(width: 10, height: 10,
      decoration: BoxDecoration(color: c,
        borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(t, style: const TextStyle(fontSize: 11,
      color: AppColors.textSecondary)),
  ]);
}
