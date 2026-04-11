class Assessment {
  final int? id;
  final int patientId;
  final String testName;
  final String score;
  final String interpretation;
  final String date;
  final String? notes;
  
  // --- NOVOS CAMPOS ---
  final int isDeleted; 
  final String? deletedAt;

  Assessment({
    this.id,
    required this.patientId,
    required this.testName,
    required this.score,
    required this.interpretation,
    required this.date,
    this.notes,
    this.isDeleted = 0,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'testName': testName,
      'score': score,
      'interpretation': interpretation,
      'date': date,
      'notes': notes,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt,
    };
  }

  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'],
      patientId: map['patientId'],
      testName: map['testName'],
      score: map['score'],
      interpretation: map['interpretation'],
      date: map['date'],
      notes: map['notes'],
      isDeleted: map['is_deleted'] ?? 0,
      deletedAt: map['deleted_at'],
    );
  }
}