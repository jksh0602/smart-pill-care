// lib/providers/medication_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/medication_model.dart';
import '../services/medication_service.dart';

class MedicationProvider extends ChangeNotifier {
  final _service = MedicationService();

  List<Medication> _todayMeds = [];
  Map<String, String> _calendarData = {};
  double _adherenceRate = 0;
  bool _isLoading = false;
  StreamSubscription<List<Medication>>? _sub;

  List<Medication> get todayMeds => _todayMeds;
  Map<String, String> get calendarData => _calendarData;
  double get adherenceRate => _adherenceRate;
  bool get isLoading => _isLoading;

  // 오늘 복약 중 미복약 건수
  int get pendingCount =>
    _todayMeds.where((m) => m.status == MedStatus.pending).length;

  // 오늘 복약률 (0.0 ~ 1.0)
  double get todayRate {
    if (_todayMeds.isEmpty) return 1.0;
    final taken = _todayMeds.where((m) => m.status == MedStatus.taken).length;
    return taken / _todayMeds.length;
  }

  // 어르신의 오늘 복약을 실시간 구독
  void subscribe(String elderSnrCode) {
    _sub?.cancel();
    _sub = _service.todayMedsStream(elderSnrCode).listen((meds) {
      _todayMeds = meds;
      notifyListeners();
    });
  }

  // 캘린더 + 복약률 로드
  Future<void> loadStats(String elderSnrCode) async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getCalendarData(elderSnrCode),
        _service.getAdherenceRate(elderSnrCode),
      ]);
      _calendarData = results[0] as Map<String, String>;
      _adherenceRate = results[1] as double;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 복약 완료
  Future<void> takeMed(String medId) async {
    await _service.markTaken(medId);
    // 스트림이 자동으로 업데이트하므로 별도 notifyListeners 불필요
  }

  // 복약 일정 추가
  Future<void> addMed(Medication med) async {
    await _service.addMedication(med);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
