import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/heroi.dart';

class Banco {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final caminho = join(await getDatabasesPath(), 'agentes.db');
    _db = await openDatabase(
      caminho,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE herois(id INTEGER PRIMARY KEY, dados TEXT)',
        );

        await db.execute(
          'CREATE TABLE esquadrao(id INTEGER PRIMARY KEY)',
        );

        await db.execute(
          'CREATE TABLE contratos(id INTEGER PRIMARY KEY)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE contratos(id INTEGER PRIMARY KEY)',
          );
        }
      },
    );
    
    return _db!;
  }

  Future<void> salvarHerois(List<Heroi> lista) async {
    final banco = await db;
    final batch = banco.batch();
    for (final heroi in lista) {
      batch.insert(
        'herois',
        {'id': heroi.id, 'dados': jsonEncode(heroi.toJson())},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Heroi>> listarHerois() async {
    final banco = await db;
    final dados = await banco.query('herois', orderBy: 'id');
    return dados.map((linha) {
      return Heroi.fromJson(jsonDecode(linha['dados'] as String));
    }).toList();
  }

  Future<Heroi?> buscarHeroi(int id) async {
    final banco = await db;
    final dados = await banco.query('herois', where: 'id = ?', whereArgs: [id]);
    if (dados.isEmpty) return null;
    return Heroi.fromJson(jsonDecode(dados.first['dados'] as String));
  }

  Future<void> salvarNoEsquadrao(int id) async {
    final banco = await db;
    await banco.insert(
      'esquadrao',
      {'id': id},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removerDoEsquadrao(int id) async {
    final banco = await db;
    await banco.delete('esquadrao', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Heroi>> listarEsquadrao() async {
    final banco = await db;
    final ids = await banco.query('esquadrao', orderBy: 'id');
    final lista = <Heroi>[];
    for (final linha in ids) {
      final heroi = await buscarHeroi(linha['id'] as int);
      if (heroi != null) lista.add(heroi);
    }
    return lista;
  }

  Future<bool> estaNoEsquadrao(int id) async {
    final banco = await db;
    final dados = await banco.query('esquadrao', where: 'id = ?', whereArgs: [id]);
    return dados.isNotEmpty;
  }

  Future<int> quantidadeEsquadrao() async {
    final banco = await db;
    final resultado = await banco.rawQuery('SELECT COUNT(*) as total FROM esquadrao');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  // Salva uma alteração de powerstat depois de uma missão.
  Future<void> atualizarHeroi(Heroi heroi) async {
    final banco = await db;
    await banco.update(
      'herois',
      {'dados': jsonEncode(heroi.toJson())},
      where: 'id = ?',
      whereArgs: [heroi.id],
    );
    }
    Future<void> salvarContrato(int id) async {
    final banco = await db;

    await banco.insert(
      'contratos',
      {'id': id},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<int>> listarIdsContratos() async {
    final banco = await db;

    final dados = await banco.query('contratos');

    return dados.map((linha) {
      return linha['id'] as int;
    }).toList();
  }

  Future<int> quantidadeContratos() async {
    final banco = await db;

    final resultado = await banco.rawQuery(
      'SELECT COUNT(*) as total FROM contratos',
    );

    return Sqflite.firstIntValue(resultado) ?? 0;
  }
}
