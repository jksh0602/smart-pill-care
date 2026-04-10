// lib/screens/elder/add_medication_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/medication_model.dart';
import '../../providers/medication_provider.dart';

class AddMedicationScreen extends StatefulWidget {
  final String elderSnrCode;
  const AddMedicationScreen({super.key, required this.elderSnrCode});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameCtrl = TextEditingController();
  MedTime _selectedTime = MedTime.morning;
  TimeOfDay _timeOfDay = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = false;

  // 시간대별 기본 복약 시간
  static const _defaultTimes = {
    MedTime.morning: TimeOfDay(hour: 8, minute: 0),
    MedTime.lunch:   TimeOfDay(hour: 13, minute: 0),
    MedTime.dinner:  TimeOfDay(hour: 19, minute: 0),
    MedTime.custom:  TimeOfDay(hour: 9, minute: 0),
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay,
    );
    if (picked != null) setState(() => _timeOfDay = picked);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('약 이름을 입력해 주세요.')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final scheduled = DateTime(
      now.year, now.month, now.day,
      _timeOfDay.hour, _timeOfDay.minute,
    );

    final med = Medication(
      id: '',
      elderSnrCode: widget.elderSnrCode,
      name: _nameCtrl.text.trim(),
      time: _selectedTime,
      scheduledAt: scheduled,
    );

    await context.read<MedicationProvider>().addMed(med);
    setState(() => _isLoading = false);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('복약 일정이 추가되었습니다!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('복약 일정 추가'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('약 이름',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: '예: 혈압약, 소화제, 관절약',
                prefixIcon: Icon(Icons.medication_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 24),
            const Text('복약 시간대',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            // 시간대 선택
            Row(
              children: MedTime.values.map((t) {
                final labels = {
                  MedTime.morning: '아침',
                  MedTime.lunch:   '점심',
                  MedTime.dinner:  '저녁',
                  MedTime.custom:  '기타',
                };
                final emojis = {
                  MedTime.morning: '🌅',
                  MedTime.lunch:   '☀️',
                  MedTime.dinner:  '🌙',
                  MedTime.custom:  '⏰',
                };
                final selected = _selectedTime == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedTime = t;
                      _timeOfDay = _defaultTimes[t]!;
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected
                          ? AppColors.primaryLight
                          : AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(14),
                        border: selected
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                      ),
                      child: Column(
                        children: [
                          Text(emojis[t]!,
                            style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(labels[t]!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                ? FontWeight.w700 : FontWeight.w400,
                              color: selected
                                ? AppColors.primary : AppColors.textSecondary,
                            )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('정확한 시간',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                      color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      _timeOfDay.format(context),
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                      color: AppColors.textHint),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
                : const Text('저장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
