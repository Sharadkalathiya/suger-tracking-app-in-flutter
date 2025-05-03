import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Add a new record
  Future<void> addRecord(Map<String, dynamic> record) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('records')
        .add(record);
  }

  // Get all records
  Stream<List<Map<String, dynamic>>> getRecords() {
    if (currentUserId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('records')
        .orderBy('date', descending: true)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID to the data
            return data;
          }).toList();
        });
  }

  // Delete a record
  Future<void> deleteRecord(String recordId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('records')
        .doc(recordId)
        .delete();
  }

  // Update a record
  Future<void> updateRecord(String recordId, Map<String, dynamic> record) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('records')
        .doc(recordId)
        .update(record);
  }

  // Get filtered records
  Stream<List<Map<String, dynamic>>> getFilteredRecords(String mealTime) {
    if (currentUserId == null) throw Exception('User not authenticated');

    Query query = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('records');

    if (mealTime != 'All') {
      query = query.where('mealTime', isEqualTo: mealTime);
    }

    return query
        .orderBy('date', descending: true)
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // Calculate average sugar levels
  Future<Map<String, double?>> calculateAverageSugar() async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('records')
        .get();

    Map<String, List<int>> mealTimes = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
      'Night': [],
      'Bedtime': [],
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final mealTime = data['mealTime'] as String;
      final sugar = data['sugar'] as int;

      if (mealTimes.containsKey(mealTime)) {
        mealTimes[mealTime]!.add(sugar);
      }
    }

    Map<String, double?> averages = {};
    
    // Calculate averages for each meal time
    mealTimes.forEach((mealTime, sugars) {
      if (sugars.isNotEmpty) {
        averages[mealTime] = sugars.reduce((a, b) => a + b) / sugars.length;
      } else {
        averages[mealTime] = null;
      }
    });

    // Calculate overall average
    final allSugars = snapshot.docs
        .map((doc) => doc.data()['sugar'] as int)
        .toList();
    
    if (allSugars.isNotEmpty) {
      averages['overall'] = allSugars.reduce((a, b) => a + b) / allSugars.length;
    } else {
      averages['overall'] = null;
    }

    return averages;
  }
} 