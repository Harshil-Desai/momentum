import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class PendingOp {
  final int? id;
  final String method;
  final String endpoint;
  final Map<String, dynamic> body;
  final int createdAt;
  final int retryCount;

  const PendingOp({
    this.id,
    required this.method,
    required this.endpoint,
    required this.body,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'method': method,
        'endpoint': endpoint,
        'body': jsonEncode(body),
        'created_at': createdAt,
        'retry_count': retryCount,
      };

  factory PendingOp.fromRow(Map<String, dynamic> row) => PendingOp(
        id: row['id'] as int,
        method: row['method'] as String,
        endpoint: row['endpoint'] as String,
        body: jsonDecode(row['body'] as String) as Map<String, dynamic>,
        createdAt: row['created_at'] as int,
        retryCount: row['retry_count'] as int,
      );
}

class OfflineQueue {
  static Database? _db;

  static Future<Database> _open() async {
    if (_db != null) return _db!;
    final dbPath = p.join(await getDatabasesPath(), 'momentum_queue.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE pending_ops (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          method TEXT NOT NULL,
          endpoint TEXT NOT NULL,
          body TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          retry_count INTEGER NOT NULL DEFAULT 0
        )
      '''),
    );
    return _db!;
  }

  static Future<void> enqueue(PendingOp op) async {
    final db = await _open();
    await db.insert('pending_ops', op.toRow());
  }

  static Future<List<PendingOp>> pending() async {
    final db = await _open();
    final rows = await db.query(
      'pending_ops',
      orderBy: 'created_at ASC, id ASC',
    );
    return rows.map(PendingOp.fromRow).toList();
  }

  static Future<void> delete(int id) async {
    final db = await _open();
    await db.delete('pending_ops', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> incrementRetry(int id) async {
    final db = await _open();
    await db.rawUpdate(
      'UPDATE pending_ops SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  static Future<int> count() async {
    final db = await _open();
    final result =
        await db.rawQuery('SELECT COUNT(*) as c FROM pending_ops');
    return (result.first['c'] as int?) ?? 0;
  }
}
