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
  final List<String> merchOrders;
  final int version; // This corresponds to __v in the JSON
  final List<Map<String, dynamic>> tag; // Added tag field

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
    required this.merchOrders,
    required this.reminders,
    required this.tag, // Added tag field
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
      merchOrders: List<String>.from(json['merchOrders'] ?? []),
      tag: List<Map<String, dynamic>>.from(json['tag'] ?? []), // Parse tag field
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
      'merchOrders': merchOrders,
      'tag': tag, // Include tag field in JSON
      '__v': version,
    };
  }
}
