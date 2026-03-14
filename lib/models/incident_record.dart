class IncidentRecord {
  final int? id;
  final int personId;
  final String occurredAt;
  final String location;
  final String whatHappened;
  final String howHappened;
  final String? memo;
  final String createdAt;
  final String updatedAt;

  const IncidentRecord({
    this.id,
    required this.personId,
    required this.occurredAt,
    required this.location,
    required this.whatHappened,
    required this.howHappened,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  IncidentRecord copyWith({
    int? id,
    int? personId,
    String? occurredAt,
    String? location,
    String? whatHappened,
    String? howHappened,
    String? memo,
    String? createdAt,
    String? updatedAt,
  }) {
    return IncidentRecord(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      occurredAt: occurredAt ?? this.occurredAt,
      location: location ?? this.location,
      whatHappened: whatHappened ?? this.whatHappened,
      howHappened: howHappened ?? this.howHappened,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personId': personId,
      'occurredAt': occurredAt,
      'location': location,
      'whatHappened': whatHappened,
      'howHappened': howHappened,
      'memo': memo,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory IncidentRecord.fromMap(Map<String, dynamic> map) {
    return IncidentRecord(
      id: map['id'] as int?,
      personId: map['personId'] as int,
      occurredAt: map['occurredAt'] as String,
      location: map['location'] as String,
      whatHappened: map['whatHappened'] as String,
      howHappened: map['howHappened'] as String,
      memo: map['memo'] as String?,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
    );
  }
}
