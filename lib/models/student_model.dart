class StudentModel {
  final int userId;
  final String rollNumber;
  final String department;
  final int year;

  StudentModel({
    required this.userId,
    required this.rollNumber,
    required this.department,
    required this.year,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      StudentModel(
        userId: json['user_id'],
        rollNumber: json['roll_number'],
        department: json['department'],
        year: json['year'],
      );
}
