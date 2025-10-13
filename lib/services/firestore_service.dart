import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/history_item.dart';
import '../models/queue_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Deklarasi variabel
  final String _queueCollection = 'queue';
  final String _historyCollection = 'history';

  // Mendapatkan stream/aliran data antrian secara real-time
  Stream<List<QueueItem>> getQueueStream() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _db
        .collection(_queueCollection)
        .where('appointmentDate', isGreaterThanOrEqualTo: startOfDay)
        .where('appointmentDate', isLessThanOrEqualTo: endOfDay)
        .orderBy('appointmentDate')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => QueueItem.fromFirestore(doc)).toList(),
        );
  }

  // Menambahkan item baru ke antrian
  Future<void> addQueueItem(
    String name,
    String service,
    String userId,
    DateTime appointmentDate,
  ) async {
    return _db.runTransaction((transaction) async {
      DateTime startOfDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );
      DateTime endOfDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        23,
        59,
        59,
      );

      final querySnapshot = await _db
          .collection(_queueCollection)
          .where('appointmentDate', isGreaterThanOrEqualTo: startOfDay)
          .where('appointmentDate', isLessThanOrEqualTo: endOfDay)
          .orderBy('queueNumber', descending: true)
          .limit(1)
          .get();

      int lastNumber = 0;
      if (querySnapshot.docs.isNotEmpty) {
        lastNumber = querySnapshot.docs.first.data()['queueNumber'] ?? 0;
      }

      final newQueueNumber = lastNumber + 1;
      final newDocRef = _db.collection(_queueCollection).doc();
      final newItem = {
        'name': name,
        'service': service,
        'queueNumber': newQueueNumber,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
        'appointmentDate': Timestamp.fromDate(appointmentDate),
      };
      transaction.set(newDocRef, newItem);
    });
  }

  Future<void> completeQueueItem({
    required QueueItem item,
    required String tellerId,
    required double transactionAmount,
    required String transactionNotes,
  }) async {
    final WriteBatch batch = _db.batch();

    final historyDocRef = _db.collection(_historyCollection).doc(item.id);
    batch.set(historyDocRef, {
      'name': item.name,
      'service': item.service,
      'queueNumber': item.queueNumber,
      'createdAt': item.timestamp,
      'appointmentDate': item.appointmentDate,
      'userId': item.userId,
      'servedAt': FieldValue.serverTimestamp(),
      'status': 'terlayani',
      'tellerId': tellerId,
      'transactionAmount': transactionAmount,
      'transactionNotes': transactionNotes,
    });

    final queueDocRef = _db.collection(_queueCollection).doc(item.id);
    batch.delete(queueDocRef);

    await batch.commit();
  }

  // Memanggil nomor antrian berikutnya (memindahkan ke riwayat)
  // Future<void> callNextItem() async {
  //   final querySnapshot = await _db
  //       .collection(_queueCollection) // Gunakan variabel
  //       .orderBy('timestamp', descending: false)
  //       .limit(1)
  //       .get();
  //
  //   if (querySnapshot.docs.isNotEmpty) {
  //     final docToMove = querySnapshot.docs.first;
  //     final data = docToMove.data();
  //     final batch = _db.batch();
  //
  //     final historyDocRef = _db
  //         .collection(_historyCollection)
  //         .doc(docToMove.id);
  //     batch.set(historyDocRef, {
  //       'name': data['name'],
  //       'service': data['service'],
  //       'queueNumber': data['queueNumber'],
  //       'createdAt': data['timestamp'],
  //       'servedAt': FieldValue.serverTimestamp(),
  //       'status': 'terlayani',
  //     });
  //
  //     batch.delete(docToMove.reference);
  //     await batch.commit();
  //   }
  // }

  // Menghapus item antrian spesifik berdasarkan ID
  Future<void> deleteQueueItem(String id) {
    return _db.collection(_queueCollection).doc(id).delete();
  }

  // Menghapus semua item dalam antrian
  Future<void> clearAllQueue() async {
    final WriteBatch batch = _db.batch();
    final querySnapshot = await _db.collection(_queueCollection).get();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Mendapatkan stream/aliran data riwayat
  Stream<List<HistoryItem>> getHistoryStream({String? userId}) {
    Query query = _db
        .collection(_historyCollection)
        .orderBy('servedAt', descending: true);
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => HistoryItem.fromFirestore(doc))
          .toList();
    });
  }
}
