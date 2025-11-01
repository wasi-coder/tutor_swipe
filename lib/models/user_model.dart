class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // "Student" or "Teacher"
  final List<String> subjects;
  final int? rate;
  final String? bio;
  final String? photoUrl;
  final String? location;
  final double rating;
  final int ratingCount;
  final bool autoAccept;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.subjects = const [],
    this.rate,
    this.bio,
    this.photoUrl,
    this.location,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.autoAccept = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'Student',
      subjects: List<String>.from(map['subjects'] ?? []),
      rate: map['rate'],
      bio: map['bio'],
      photoUrl: map['photoUrl'],
      location: map['location'],
      rating: (map['rating'] ?? 0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      autoAccept: map['autoAccept'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'subjects': subjects,
      'rate': rate,
      'bio': bio,
      'photoUrl': photoUrl,
      'location': location,
      'rating': rating,
      'ratingCount': ratingCount,
      'autoAccept': autoAccept,
    };
  }
}