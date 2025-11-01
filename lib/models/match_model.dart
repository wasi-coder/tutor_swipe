class MatchModel {
  final String id;
  final String studentId;
  final String teacherId;
  final int createdAt;

  MatchModel({
    required this.id,
    required this.studentId,
    required this.teacherId,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        'studentId': studentId,
        'teacherId': teacherId,
        'createdAt': createdAt,
      };
}