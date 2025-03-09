class User {
  final String id;
  final String fcmToken;
  final String name;
  final String email;
  final int rollNumber;
  final int semester;
  final String hostel;
  final String roomnum;
  final String contact;
  final String degree;
  final String department;
  final String role;
  final List<String> subscribedClubs;
  final List<String> clubsResponsible;
  final List<Map<String, dynamic>> reminders;
<<<<<<< HEAD
=======
  final List<String> merchOrders;
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
  final int version; // This corresponds to __v in the JSON

  User({
    required this.id,
    required this.fcmToken,
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.semester,
    required this.hostel,
    required this.roomnum,
    required this.contact,
    required this.degree,
    required this.department,
    required this.role,
    required this.subscribedClubs,
    required this.clubsResponsible,
<<<<<<< HEAD
=======
    required this.merchOrders,
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
    required this.reminders,
    this.version = 0, // Default value for __v
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fcmToken: json['fcmToken'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      rollNumber: json['rollNumber'] ?? 0,
      semester: json['semester'] ?? 0,
      hostel: json['hostel'] ?? '',
      roomnum: json['roomnum'] ?? '',
      contact: json['contact'] ?? '',
      degree: json['degree'] ?? '',
      department: json['department'] ?? '',
      role: json['role'] ?? 'normal',
      subscribedClubs: List<String>.from(json['subscribedClubs'] ?? []),
      clubsResponsible: List<String>.from(json['clubsResponsible'] ?? []),
      reminders: List<Map<String, dynamic>>.from(json['reminders'] ?? []),
<<<<<<< HEAD
=======
      merchOrders: List<String>.from(json['merchOrders'] ?? []),
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fcmToken': fcmToken,
      'name': name,
      'email': email,
      'rollNumber': rollNumber,
      'semester': semester,
      'hostel': hostel,
      'roomnum': roomnum,
      'contact': contact,
      'degree': degree,
      'department': department,
      'role': role,
      'subscribedClubs': subscribedClubs,
      'clubsResponsible': clubsResponsible,
      'reminders': reminders,
<<<<<<< HEAD
=======
      'merchOrders' : merchOrders,
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
      '__v': version,
    };
  }
}
