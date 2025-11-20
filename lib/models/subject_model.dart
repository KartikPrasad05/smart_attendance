class SubjectModel {
  final int id;
  final String name;
  final String code;
  final int professorId;

  SubjectModel({
    required this.id,
    required this.name,
    required this.code,
    required this.professorId,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) =>
      SubjectModel(
        id: json['id'],
        name: json['name'],
        code: json['code'],
        professorId: json['professor_id'],
      );
}
