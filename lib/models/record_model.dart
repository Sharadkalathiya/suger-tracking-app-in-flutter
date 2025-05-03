import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  final String? id;
  final String userId;
  final String date;
  final String time;
  final String mealTime;
  final int sugar;
  final int insulinDose;
  final String food;
  final String? remarks;
  final DateTime timestamp;

  Record({
    this.id,
    required this.userId,
    required this.date,
    required this.time,
    required this.mealTime,
    required this.sugar,
    required this.insulinDose,
    required this.food,
    this.remarks,
    required this.timestamp,
  });

  // Convert Record to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'time': time,
      'mealTime': mealTime,
      'sugar': sugar,
      'insulinDose': insulinDose,
      'food': food,
      'remarks': remarks,
      'timestamp': timestamp,
    };
  }

  // Create Record from Firestore Map
  static Record fromMap(Map<String, dynamic> map, String documentId) {
    return Record(
      id: documentId,
      userId: map['userId'],
      date: map['date'],
      time: map['time'],
      mealTime: map['mealTime'],
      sugar: map['sugar'],
      insulinDose: map['insulinDose'],
      food: map['food'],
      remarks: map['remarks'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
} 