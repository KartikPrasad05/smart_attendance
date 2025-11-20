class ProfessorModel {
  final int userId;
  final String employeeId;
  final String department;

  ProfessorModel({
    required this.userId,
    required this.employeeId,
    required this.department,
  });

  factory ProfessorModel.fromJson(Map<String, dynamic> json) =>
      ProfessorModel(
        userId: json['user_id'],
        employeeId: json['employee_id'],
        department: json['department'],
      );
}
