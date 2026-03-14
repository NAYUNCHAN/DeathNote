import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/incident_record.dart';
import '../models/person.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'incident_note.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Person (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            memo TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE IncidentRecord (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            personId INTEGER NOT NULL,
            occurredAt TEXT NOT NULL,
            location TEXT NOT NULL,
            whatHappened TEXT NOT NULL,
            howHappened TEXT NOT NULL,
            memo TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (personId) REFERENCES Person(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<List<Person>> getPersons() async {
    final db = await database;
    final maps = await db.query('Person', orderBy: 'updatedAt DESC');
    return maps.map(Person.fromMap).toList();
  }

  Future<int> insertPerson(Person person) async {
    final db = await database;
    return db.insert('Person', person.toMap());
  }

  Future<int> updatePerson(Person person) async {
    final db = await database;
    return db.update(
      'Person',
      person.toMap(),
      where: 'id = ?',
      whereArgs: [person.id],
    );
  }

  Future<int> deletePerson(int id) async {
    final db = await database;
    return db.delete('Person', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getRecordCountByPerson(int personId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM IncidentRecord WHERE personId = ?',
      [personId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<IncidentRecord>> getRecordsByPerson(int personId) async {
    final db = await database;
    final maps = await db.query(
      'IncidentRecord',
      where: 'personId = ?',
      whereArgs: [personId],
      orderBy: 'occurredAt DESC',
    );
    return maps.map(IncidentRecord.fromMap).toList();
  }

  Future<int> insertRecord(IncidentRecord record) async {
    final db = await database;
    return db.insert('IncidentRecord', record.toMap());
  }

  Future<int> updateRecord(IncidentRecord record) async {
    final db = await database;
    return db.update(
      'IncidentRecord',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteRecord(int id) async {
    final db = await database;
    return db.delete('IncidentRecord', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getPersonCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM Person');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalRecordCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM IncidentRecord');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
