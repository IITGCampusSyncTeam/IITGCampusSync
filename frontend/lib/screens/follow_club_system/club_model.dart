class Club {
  final String id;
  final String name;
  final String? logo;
  final bool isFollowing; //state

  Club({
    required this.id,
    required this.name,
    this.logo,
    this.isFollowing = false,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['_id'],
      name: json['name'],
      logo: json['logo'] ?? "",
      isFollowing: json['isFollowing'] ?? false,
    );
  }

  Club copyWith({bool? isFollowing}) {
    return Club(
      id: id,
      name: name,
      logo: logo,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
