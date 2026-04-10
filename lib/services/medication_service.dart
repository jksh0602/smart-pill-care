// lib/services/medication_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication_model.dart';

class MedicationService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('medications');

  // --------------------------------------------------
  // 어르신의 오늘 복약 목록 실시간 스트림
  // --------------------------------------------------
  Stream<List<Medication>> todayMedsStream(String elderSnrCode) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _col
      .where('elderSnrCode', isEqualTo: elderSnrCode)
      .where('scheduledAt', isGreaterThanOrEqualTo: startOfDay)
      .where('scheduledAt', isLessThan: endOfDay)
      .orderBy('scheduledAt')
      .snapshots()
      .map((snap) => snap.docs
        .map((d) => Medication.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList());
  }

  // 특정 기간 복약 기록 (캘린더용)
  Future<List<Medication>> getMedsByRange(
    String elderSnrCode,
    DateTime from,
    DateTime to,
  ) async {
    final snap = await _col
      .where('elderSnrCode', isEqualTo: elderSnrCode)
      .where('scheduledAt', isGreaterThanOrEqualTo: from)
      .where('scheduledAt', isLessThan: to)
      .orderBy('scheduledAt')
      .get();
    return snap.docs
      .map((d) => Medication.fromMap(d.data() as Map<String, dynamic>, d.id))
      .toList();
  }

  // --------------------------------------------------
  // 복약 완료 처리
  // --------------------------------------------------
  Future<void> markTaken(String medId) async {
    await _col.doc(medId).update({
      'status': MedStatus.taken.name,
      'takenAt': FieldValue.serverTimestamp(),
    });
  }

  // 복약 누락 처리 (Cloud Functions에서도 호출 가능)
  Future<void> markMissed(String medId) async {
    await _col.doc(medId).update({'status': MedStatus.missed.name});
  }

  // --------------------------------------------------
  // 복약 일정 등록
  // --------------------------------------------------
  Future<String> addMedication(Medication med) async {
    final doc = await _col.add(med.toMap());
    return doc.id;
  }

  // 복약 일정 삭제
  Future<void> deleteMedication(String medId) =>
    _col.doc(medId).delete();

  // --------------------------------------------------
  // 복약률 계산 (최근 N일)
  // --------------------------------------------------
  Future<double> getAdherenceRate(String elderSnrCode, {int days = 30}) async {
    final from = DateTime.now().subtract(Duration(days: days));
    final meds = await getMedsByRange(
      elderSnrCode, from, DateTime.now().add(const Duration(days: 1)));

    if (meds.isEmpty) return 1.0;
    final taken = meds.where((m) => m.status == MedStatus.taken).length;
    return taken / meds.length;
  }

  // 날짜별 복약 상태 요약 (캘린더 히트맵용)
  // 반환: { '2026-04-01': 'green'|'amber'|'red' }
  Future<Map<String, String>> getCalendarData(
    String elderSnrCode, {int weeks = 4}) async {
    final from = DateTime.now().subtract(Duration(days: weeks * 7));
    final meds = await getMedsByRange(
      elderSnrCode, from, DateTime.now().add(const Duration(days: 1)));

    final Map<String, List<Medication>> byDay = {};
    for (final m in meds) {
      final key = _dateKey(m.scheduledAt);
      byDay.putIfAbsent(key, () => []).add(m);
    }

    return byDay.map((date, dayMeds) {
      final total = dayMeds.length;
      final taken = dayMeds.where((m) => m.status == MedStatus.taken).length;
      final String color;
      if (taken == total) {
        color = 'green';
      } else if (taken == 0) {
        color = 'red';
      } else {
        color = 'amber';
      }
      return MapEntry(date, color);
    });
  }

  String _dateKey(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
