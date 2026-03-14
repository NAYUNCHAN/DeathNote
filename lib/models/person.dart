class Person {
  final int? id;
  final String name;
  final String? memo;
  final String createdAt;
  final String updatedAt;

  const Person({
    this.id,
    required this.name,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  Person copyWith({
    int? id,
    String? name,
    String? memo,
    String? createdAt,
    String? updatedAt,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'memo': memo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as int?,
      name: map['name'] as String,
      memo: map['memo'] as String?,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }
}
