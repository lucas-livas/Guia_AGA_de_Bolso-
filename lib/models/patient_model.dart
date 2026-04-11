class Patient {
  int? id;
  String name;
  String birthDate;
  String gender;
  String maritalStatus;
  String emergencyContact;
  String chiefComplaint;
  String hda;
  String pastMedicalHistory;
  String medicationList;
  String socialHistory;
  String homeEnvironment;
  String race;
  String nationality;
  String placeOfBirth;
  String occupation;
  String educationLevel;
  String notes;
  
  // --- NOVOS CAMPOS PARA A LIXEIRA ---
  int isDeleted; // 0 = Ativo, 1 = Na Lixeira
  String? deletedAt; // Data em que foi movido para a lixeira (ISO8601)

  Patient({
    this.id,
    required this.name,
    required this.birthDate,
    this.gender = '',
    this.maritalStatus = '',
    this.emergencyContact = '',
    this.chiefComplaint = '',
    this.hda = '',
    this.pastMedicalHistory = '',
    this.medicationList = '',
    this.socialHistory = '',
    this.homeEnvironment = '',
    this.race = '',
    this.nationality = '',
    this.placeOfBirth = '',
    this.occupation = '',
    this.educationLevel = '',
    this.notes = '',
    // Valores padrão para novos pacientes
    this.isDeleted = 0, 
    this.deletedAt,
  });

  // Converter para Map (Salvar no Banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'emergencyContact': emergencyContact,
      'chiefComplaint': chiefComplaint,
      'hda': hda,
      'pastMedicalHistory': pastMedicalHistory,
      'medicationList': medicationList,
      'socialHistory': socialHistory,
      'homeEnvironment': homeEnvironment,
      'race': race,
      'nationality': nationality,
      'placeOfBirth': placeOfBirth,
      'occupation': occupation,
      'educationLevel': educationLevel,
      'notes': notes,
      // Novos campos
      'is_deleted': isDeleted,
      'deleted_at': deletedAt,
    };
  }

  // Criar objeto a partir do Map (Ler do Banco)
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      birthDate: map['birthDate'],
      gender: map['gender'] ?? '',
      maritalStatus: map['maritalStatus'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '',
      chiefComplaint: map['chiefComplaint'] ?? '',
      hda: map['hda'] ?? '',
      pastMedicalHistory: map['pastMedicalHistory'] ?? '',
      medicationList: map['medicationList'] ?? '',
      socialHistory: map['socialHistory'] ?? '',
      homeEnvironment: map['homeEnvironment'] ?? '',
      race: map['race'] ?? '',
      nationality: map['nationality'] ?? '',
      placeOfBirth: map['placeOfBirth'] ?? '',
      occupation: map['occupation'] ?? '',
      educationLevel: map['educationLevel'] ?? '',
      notes: map['notes'] ?? '',
      // Novos campos com tratamento de nulos
      isDeleted: map['is_deleted'] ?? 0,
      deletedAt: map['deleted_at'],
    );
  }
}