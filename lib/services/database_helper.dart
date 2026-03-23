import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

import '../core/exceptions/app_exceptions.dart';
import '../models/item_doacao.dart';
import '../models/usuario.dart';

final class DatabaseHelper {
  DatabaseHelper._();
  static sqflite.Database? _database;

  static const String _dbName = 'ecoshare.db';
  static const int _dbVersion = 1;

  static const String tableItens = 'itens_doacao';
  static const String tableUsuarios = 'usuarios';

  static Future<sqflite.Database> initDatabase() async {
    try {
      if (_database != null && _database!.isOpen) return _database!;

      final dbPath = await sqflite.getDatabasesPath();
      final path = join(dbPath, _dbName);

      _database = await sqflite.openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
      );
      return _database!;
    } on sqflite.DatabaseException catch (e) {
      throw DatabaseException(
        'Falha ao inicializar o banco de dados: $e',
        e,
      );
    }
  }

  static Future<void> _onCreate(sqflite.Database db, int version) async {
    await _createTableItens(db);
    await _createTableUsuarios(db);
  }

  static Future<void> _createTableItens(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableItens (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        categoria TEXT NOT NULL,
        estadoConservacao TEXT NOT NULL,
        imageUrl TEXT,
        isLocalSync INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> _createTableUsuarios(sqflite.Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableUsuarios (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        doacoesFeitas INTEGER NOT NULL DEFAULT 0,
        vidasSalvas INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Map<String, dynamic> _itemToDbMap(ItemDoacao item) {
    final map = Map<String, dynamic>.from(item.toJson());
    map['isLocalSync'] = item.isLocalSync ? 1 : 0;
    return map;
  }

  static Future<int> insertItem(ItemDoacao item) async {
    try {
      final db = await _getDatabase();
      return db.insert(tableItens, _itemToDbMap(item));
    } on sqflite.DatabaseException catch (e) {
      throw DatabaseException('Erro ao inserir item: $e', e);
    }
  }

  static Future<List<ItemDoacao>> getItensSalvosLocalmente() async {
    try {
      final db = await _getDatabase();
      final maps = await db.query(tableItens, orderBy: 'id DESC');
      return maps.map((m) => ItemDoacao.fromJson(m)).toList();
    } on sqflite.DatabaseException catch (e) {
      throw DatabaseException('Erro ao buscar itens: $e', e);
    }
  }

  static Future<List<ItemDoacao>> getItensPendentesSync() async {
    try {
      final db = await _getDatabase();
      final maps = await db.query(
        tableItens,
        where: 'isLocalSync = ?',
        whereArgs: [1],
        orderBy: 'id DESC',
      );
      return maps.map((m) => ItemDoacao.fromJson(m)).toList();
    } on sqflite.DatabaseException catch (e) {
      throw DatabaseException('Erro ao buscar itens pendentes: $e', e);
    }
  }

  static Future<int> marcarItemSincronizado(String id) async {
    try {
      final db = await _getDatabase();
      return db.update(
        tableItens,
        {'isLocalSync': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } on sqflite.DatabaseException catch (e) {
      throw DatabaseException('Erro ao atualizar item: $e', e);
    }
  }

  static Future<int> updateItem(ItemDoacao item) async {
    try {
      final db = await _getDatabase();
      return db.update(
        tableItens,
        _itemToDbMap(item),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    } on sqflite.DatabaseException catch (e) {
      throw DatabaseException('Erro ao atualizar item: $e', e);
    }
  }

  static Future<int> deleteItem(String id) async {
    try {
      final db = await _getDatabase();
      return db.delete(tableItens, where: 'id = ?', whereArgs: [id]);
    } on sqflite.DatabaseException catch (e) {
      throw DatabaseException('Erro ao excluir item: $e', e);
    }
  }

  static Future<int> insertOuAtualizarUsuario(Usuario usuario) async {
    try {
      final db = await _getDatabase();
      return db.insert(
        tableUsuarios,
        usuario.toJson(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    } on sqflite.DatabaseException catch (e) {
      throw DatabaseException('Erro ao salvar usuário: $e', e);
    }
  }

  static Future<int> atualizarEstatisticasUsuario({
    required String usuarioId,
    int? doacoesFeitas,
    int? vidasSalvas,
  }) async {
    try {
      final usuario = await getUsuario(usuarioId);
      if (usuario == null) {
        throw DatabaseException('Usuário não encontrado: $usuarioId');
      }

      final atualizado = usuario.copyWith(
        doacoesFeitas: doacoesFeitas ?? usuario.doacoesFeitas,
        vidasSalvas: vidasSalvas ?? usuario.vidasSalvas,
      );

      return await insertOuAtualizarUsuario(atualizado);
    } on sqflite.DatabaseException catch (e) {
      throw DatabaseException(
        'Erro ao atualizar estatísticas: $e',
        e,
      );
    }
  }

  static Future<Usuario?> getUsuario(String id) async {
    try {
      final db = await _getDatabase();
      final maps = await db.query(
        tableUsuarios,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return Usuario.fromJson(maps.first);
    } on sqflite.DatabaseException catch (e) {
      throw DatabaseException('Erro ao buscar usuário: $e', e);
    }
  }

  static Future<sqflite.Database> _getDatabase() async {
    if (_database == null || !_database!.isOpen) {
      return initDatabase();
    }
    return _database!;
  }

  static Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
