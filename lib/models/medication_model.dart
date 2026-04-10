// lib/models/medication_model.dart

enum MedTime { morning, lunch, dinner, custom }
enum MedStatus { pending, taken, missed }

class Medication {
  final String id;
  final String elderSnrCode;
  final String name;           // 약 이름 (예: 혈압약, 소화제)
  final MedTime time;
  final DateTime scheduledAt;
  final DateTime? takenAt;
  final MedStatus status;

  const Medication({
    required this.id,
    required this.elderSnrCode,
    required this.name,
    required this.time,
    required this.scheduledAt,
    this.takenAt,
    this.status = MedStatus.pending,
  });

  String get timeLabel {
    switch (time) {
      case MedTime.morning: return '아침';
      case MedTime.lunch:   return '점심';
      case MedTime.dinner:  return '저녁';
      case MedTime.custom:  return '기타';
    }
  }

  bool get isOverdue =>
    status == MedStatus.pending &&
    DateTime.now().isAfter(scheduledAt.add(const Duration(hours: 1)));

  factory Medication.fromMap(Map<String, dynamic> map, String id) {
    return Medication(
      id: id,
      elderSnrCode: map['elderSnrCode'] ?? '',
      name: map['name'] ?? '',
      time: MedTime.values.firstWhere(
        (e) => e.name == map['time'],
        orElse: () => MedTime.morning,
      ),
      scheduledAt: (map['scheduledAt'] as dynamic).toDate(),
      takenAt: map['takenAt'] != null
        ? (map['takenAt'] as dynamic).toDate()
        : null,
      status: MedStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MedStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'elderSnrCode': elderSnrCode,
    'name': name,
    'time': time.name,
    'scheduledAt': scheduledAt,
    'takenAt': takenAt,
    'status': status.name,
  };
}
