import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'record_model.dart';

class RecordProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Record> _records = [];
  List<Record> _filteredRecords = [];
  String _filter = 'All';
  String _sort = 'New to Old';

  List<Record> get filteredRecords => _filteredRecords;

  Future<void> loadRecords() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('records')
          .orderBy('timestamp', descending: true)
          .get();

      _records = snapshot.docs
          .map((doc) => Record.fromMap(doc.data(), doc.id))
          .toList();
      
      _filteredRecords = List.from(_records);
      notifyListeners();
    } catch (e) {
      print('Error loading records: $e');
    }
  }

  Future<void> addRecord(Record record) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Save to Firestore
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('records')
          .add(record.toMap());

      // Add to local list with the document ID
      final newRecord = Record(
        id: docRef.id,
        userId: record.userId,
        date: record.date,
        time: record.time,
        mealTime: record.mealTime,
        sugar: record.sugar,
        insulinDose: record.insulinDose,
        food: record.food,
        remarks: record.remarks,
        timestamp: record.timestamp,
      );

      _records.insert(0, newRecord);
      _filteredRecords = List.from(_records);
      notifyListeners();
    } catch (e) {
      print('Error adding record: $e');
    }
  }

  Future<void> removeRecord(String recordId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('records')
          .doc(recordId)
          .delete();

      // Remove from local lists
      _records.removeWhere((record) => record.id == recordId);
      _filteredRecords.removeWhere((record) => record.id == recordId);
      notifyListeners();
    } catch (e) {
      print('Error removing record: $e');
    }
  }

  void applyFilter(String filter) {
    if (filter == 'All') {
      _filteredRecords = List.from(_records);
    } else {
      _filteredRecords = _records
          .where((record) => record.mealTime == filter)
          .toList();
    }
    notifyListeners();
  }

  void applySort(String sortOption) {
    switch (sortOption) {
      case 'New to Old':
        _filteredRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'Old to New':
        _filteredRecords.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'High to Low':
        _filteredRecords.sort((a, b) => b.sugar.compareTo(a.sugar));
        break;
      case 'Low to High':
        _filteredRecords.sort((a, b) => a.sugar.compareTo(b.sugar));
        break;
    }
    notifyListeners();
  }

  void clearFilter() {
    _filteredRecords = List.from(_records);
    notifyListeners();
  }

  Map<String, double?> calculateAverageSugar() {
    Map<String, List<int>> mealTimes = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
      'Night': [],
      'Bedtime': [],
    };

    for (var record in _records) {
      if (mealTimes.containsKey(record.mealTime)) {
        mealTimes[record.mealTime]!.add(record.sugar);
      }
    }

    Map<String, double?> averages = {};
    mealTimes.forEach((mealTime, sugars) {
      if (sugars.isNotEmpty) {
        averages[mealTime] = sugars.reduce((a, b) => a + b) / sugars.length;
      } else {
        averages[mealTime] = null;
      }
    });

    final allSugars = _records.map((record) => record.sugar).toList();
    if (allSugars.isNotEmpty) {
      averages['overall'] = allSugars.reduce((a, b) => a + b) / allSugars.length;
    } else {
      averages['overall'] = null;
    }

    return averages;
  }
} 