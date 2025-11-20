class SessionModel {
  final int id;
  final int subjectId;
  final String date;
  final String startTime;
  final String endTime;
  final int generatedBy;

  SessionModel({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.generatedBy,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      SessionModel(
        id: json['id'],
        subjectId: json['subject_id'],
        date: json['date'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        generatedBy: json['generated_by'],
      );
}
