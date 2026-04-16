class StudentEntity {
  final String id;
  final String fullName;
  final int grade;
  final int age;
  final bool isActive;
  final DateTime createdAt;
  final List<String> conditions;
  final String? photoUrl;

  const StudentEntity({
    required this.id,
    required this.fullName,
    required this.grade,
    required this.age,
    this.isActive = true,
    required this.createdAt,
    this.conditions = const [],
    this.photoUrl,
  });

  StudentEntity copyWith({
    String? id,
    String? fullName,
    int? grade,
    int? age,
    bool? isActive,
    DateTime? createdAt,
    List<String>? conditions,
    String? photoUrl,
  }) {
    return StudentEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      grade: grade ?? this.grade,
      age: age ?? this.age,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      conditions: conditions ?? this.conditions,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  String get firstName => fullName.split(' ').first;

  /// Iniciales para avatar.
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
