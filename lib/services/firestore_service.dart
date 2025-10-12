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
    return _db
        .collection(_queueCollection) // Gunakan variabel
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => QueueItem.fromFirestore(doc)).toList(),
        );
  }

  // Menambahkan item baru ke antrian
  Future<void> addQueueItem(String name, String service) async {
    return _db.runTransaction((transaction) async {
      final querySnapshot = await _db
          .collection(_queueCollection) // Gunakan variabel
          .orderBy('queueNumber', descending: true)
          .limit(1)
          .get();

      int lastNumber = 0;
      if (querySnapshot.docs.isNotEmpty) {
        lastNumber = querySnapshot.docs.first.data()['queueNumber'] ?? 0;
      }

      final newQueueNumber = lastNumber + 1;
      final newDocRef = _db
          .collection(_queueCollection)
          .doc(); // Gunakan variabel
      final newItem = {
        'name': name,
        'service': service,
        'queueNumber': newQueueNumber,
        'timestamp': FieldValue.serverTimestamp(),
      };

      transaction.set(newDocRef, newItem);
    });
  }

  // Memanggil nomor antrian berikutnya (memindahkan ke riwayat)
  Future<void> callNextItem() async {
    final querySnapshot = await _db
        .collection(_queueCollection) // Gunakan variabel
        .orderBy('timestamp', descending: false)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docToMove = querySnapshot.docs.first;
      final data = docToMove.data();
      final batch = _db.batch();

      final historyDocRef = _db
          .collection(_historyCollection)
          .doc(docToMove.id);
      batch.set(historyDocRef, {
        'name': data['name'],
        'service': data['service'],
        'queueNumber': data['queueNumber'],
        'createdAt': data['timestamp'],
        'servedAt': FieldValue.serverTimestamp(),
        'status': 'terlayani',
      });

      batch.delete(docToMove.reference);
      await batch.commit();
    }
  }

  // Menghapus item antrian spesifik berdasarkan ID
  Future<void> deleteQueueItem(String id) {
    return _db
        .collection(_queueCollection)
        .doc(id)
        .delete(); // Gunakan variabel
  }

  // Menghapus semua item dalam antrian
  Future<void> clearAllQueue() async {
    final WriteBatch batch = _db.batch();
    final querySnapshot = await _db
        .collection(_queueCollection)
        .get(); // Gunakan variabel

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Mendapatkan stream/aliran data riwayat
  Stream<List<HistoryItem>> getHistoryStream() {
    return _db
        .collection(_historyCollection) // Gunakan variabel
        .orderBy('servedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HistoryItem.fromFirestore(doc))
              .toList(),
        );
  }
}
