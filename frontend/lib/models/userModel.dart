class User {
  final String id;
  final String name;
  final String email;
  final int rollNumber;
  final int semester;
  final String degree;
  final String department;
  final String role;
  final List<String> subscribedClubs;
  final List<String> clubsResponsible;
  final List<Map<String, dynamic>> reminders;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.semester,
    required this.degree,
    required this.department,
    required this.role,
    required this.subscribedClubs,
    required this.clubsResponsible,
    required this.reminders,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      rollNumber: json['rollNumber'] ?? 0,
      semester: json['semester'] ?? 0,
      degree: json['degree'] ?? '',
      department: json['department'] ?? '',
      role: json['role'] ?? 'normal',
      subscribedClubs: List<String>.from(json['subscribedClubs'] ?? []),
      clubsResponsible: List<String>.from(json['clubsResponsible'] ?? []),
      reminders: List<Map<String, dynamic>>.from(json['reminders'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'rollNumber': rollNumber,
      'semester': semester,
      'degree': degree,
      'department': department,
      'role': role,
      'subscribedClubs': subscribedClubs,
      'clubsResponsible': clubsResponsible,
      'reminders': reminders,
    };
  }
}
