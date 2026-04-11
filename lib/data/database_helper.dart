// Arquivo: lib/data/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/assessment_model.dart';
import '../models/patient_model.dart';

class DatabaseHelper {
  static const _databaseName = "GuiaAGADatabase.db";
  
  // --- VERSÃO 7: Inclui colunas de lixeira para Avaliações ---
  static const _databaseVersion = 7;

  // Tabela de Pacientes
  static const tablePatients = 'patients';
  static const columnId = 'id';

  // Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade 
    );
  }

  // --- CRIAÇÃO INICIAL (Novas Instalações) ---
  Future _onCreate(Database db, int version) async {
    // Tabela Pacientes com suporte a Soft Delete
    await db.execute('''
          CREATE TABLE $tablePatients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            birthDate TEXT NOT NULL,
            gender TEXT,
            maritalStatus TEXT,
            emergencyContact TEXT,
            chiefComplaint TEXT,
            hda TEXT,
            pastMedicalHistory TEXT,
            medicationList TEXT,
            socialHistory TEXT,
            homeEnvironment TEXT,
            race TEXT,
            nationality TEXT,
            placeOfBirth TEXT,
            occupation TEXT,
            educationLevel TEXT,
            notes TEXT,
            is_deleted INTEGER DEFAULT 0,
            deleted_at TEXT
          )
          ''');
    
    // Tabela Avaliações com suporte a Soft Delete e Notas
    await db.execute('''
          CREATE TABLE assessments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patientId INTEGER NOT NULL,
            testName TEXT NOT NULL,
            score TEXT NOT NULL,
            interpretation TEXT NOT NULL,
            date TEXT NOT NULL,
            notes TEXT, 
            is_deleted INTEGER DEFAULT 0,
            deleted_at TEXT,
            FOREIGN KEY (patientId) REFERENCES patients (id) ON DELETE CASCADE
          )
          ''');
  }

  // --- MIGRAÇÃO DE VERSÕES (Usuários Antigos) ---
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // V4 -> V5: Adiciona notas nas avaliações
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE assessments ADD COLUMN notes TEXT');
    }

    // V5 -> V6: Adiciona lixeira para Pacientes
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE $tablePatients ADD COLUMN is_deleted INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE $tablePatients ADD COLUMN deleted_at TEXT');
    }

    // V6 -> V7: Adiciona lixeira para Avaliações
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE assessments ADD COLUMN is_deleted INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE assessments ADD COLUMN deleted_at TEXT');
    }
  }

  // ====================================================================
  // 🏥 MÉTODOS CRUD - PACIENTES
  // ====================================================================

  Future<int> insert(Patient patient) async {
    Database db = await instance.database;
    return await db.insert(tablePatients, patient.toMap());
  }

  Future<int> update(Patient patient) async {
    Database db = await instance.database;
    int id = patient.id!;
    return await db.update(tablePatients, patient.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<Patient?> getPatientById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(tablePatients,
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  // Buscar apenas Pacientes ATIVOS (Home)
  Future<List<Patient>> queryAllRows() async {
    Database db = await instance.database;
    final result = await db.query(tablePatients, 
      where: 'is_deleted = 0 OR is_deleted IS NULL',
      orderBy: "name ASC"
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  // Buscar apenas Pacientes na LIXEIRA
  Future<List<Patient>> queryDeletedRows() async {
    Database db = await instance.database;
    final result = await db.query(tablePatients, 
      where: 'is_deleted = 1',
      orderBy: "deleted_at DESC"
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  // Soft Delete Paciente (Mover para lixeira)
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.update(
      tablePatients, 
      {
        'is_deleted': 1,
        'deleted_at': DateTime.now().toIso8601String(),
      },
      where: '$columnId = ?', 
      whereArgs: [id]
    );
  }

  // Restaurar Paciente
  Future<int> restorePatient(int id) async {
    Database db = await instance.database;
    return await db.update(
      tablePatients, 
      {
        'is_deleted': 0,
        'deleted_at': null,
      },
      where: '$columnId = ?', 
      whereArgs: [id]
    );
  }

  // Hard Delete Paciente (Exclusão Permanente)
  Future<int> hardDelete(int id) async {
    Database db = await instance.database;
    return await db.delete(tablePatients, where: '$columnId = ?', whereArgs: [id]);
  }

  // ====================================================================
  // 📝 MÉTODOS CRUD - AVALIAÇÕES
  // ====================================================================

  Future<int> insertAssessment(Assessment assessment) async {
    Database db = await instance.database;
    return await db.insert('assessments', assessment.toMap());
  }

  // Buscar Avaliações ATIVAS de um paciente
  Future<List<Assessment>> getAssessmentsForPatient(int patientId) async {
    Database db = await instance.database;
    final result = await db.query('assessments', 
      where: 'patientId = ? AND (is_deleted = 0 OR is_deleted IS NULL)', 
      whereArgs: [patientId], 
      orderBy: "date DESC"
    );
    return result.map((json) => Assessment.fromMap(json)).toList();
  }

  // Buscar Avaliações DELETADAS de um paciente (Lixeira) - Método Antigo (pode manter)
  Future<List<Assessment>> getDeletedAssessmentsForPatient(int patientId) async {
    Database db = await instance.database;
    final result = await db.query('assessments', 
      where: 'patientId = ? AND is_deleted = 1', 
      whereArgs: [patientId], 
      orderBy: "deleted_at DESC"
    );
    return result.map((json) => Assessment.fromMap(json)).toList();
  }

  // NOVO: Buscar TODAS as avaliações deletadas com o nome do paciente (Para a Lixeira Geral)
  Future<List<Map<String, dynamic>>> getAllDeletedAssessmentsWithPatientName() async {
    Database db = await instance.database;
    // Fazemos um JOIN para pegar o nome do paciente associado à avaliação
    final result = await db.rawQuery('''
      SELECT a.*, p.name as patient_name
      FROM assessments a
      JOIN patients p ON a.patientId = p.id
      WHERE a.is_deleted = 1
      ORDER BY a.deleted_at DESC
    ''');
    return result;
  }

  // Soft Delete Avaliação
  Future<int> deleteAssessment(int id) async {
    Database db = await instance.database;
    return await db.update(
      'assessments', 
      {
        'is_deleted': 1,
        'deleted_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  // Restaurar Avaliação
  Future<int> restoreAssessment(int id) async {
    Database db = await instance.database;
    return await db.update(
      'assessments', 
      {
        'is_deleted': 0,
        'deleted_at': null,
      },
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  // Hard Delete Avaliação
  Future<int> hardDeleteAssessment(int id) async {
    Database db = await instance.database;
    return await db.delete('assessments', where: 'id = ?', whereArgs: [id]);
  }

  // ====================================================================
  // 🧹 LIMPEZA AUTOMÁTICA
  // ====================================================================
  
  Future<void> cleanupOldData() async {
    Database db = await instance.database;
    
    // Data de corte (90 dias atrás)
    final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
    final cutoffString = cutoffDate.toIso8601String();

    // Limpa Pacientes vencidos
    await db.delete(
      tablePatients, 
      where: 'is_deleted = 1 AND deleted_at < ?',
      whereArgs: [cutoffString]
    );
    
    // Limpa Avaliações vencidas
    await db.delete(
      'assessments', 
      where: 'is_deleted = 1 AND deleted_at < ?',
      whereArgs: [cutoffString]
    );
  }
}