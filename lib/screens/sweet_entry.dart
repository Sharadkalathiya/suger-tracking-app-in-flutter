import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/record_provider.dart';
import '../models/record_model.dart';

class SweetEntry extends StatefulWidget {
  @override
  _SweetEntryState createState() => _SweetEntryState();
}

class _SweetEntryState extends State<SweetEntry> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _foodController = TextEditingController();
  final _remarksController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<RecordProvider>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      final DateTime combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final record = Record(
        userId: user.uid,
        timestamp: combinedDateTime,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        time: _selectedTime.format(context),
        mealTime: _getMealTime(_selectedTime),
        food: _foodController.text,
        remarks: _remarksController.text,
        sugar: 0, // Not applicable for sweet entry
        insulinDose: 0, // Not applicable for sweet entry
      );

      provider.addRecord(record);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sweet data saved successfully')),
      );
      
      Navigator.pop(context);
    }
  }

  String _getMealTime(TimeOfDay time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 11) return 'Morning';
    if (hour >= 11 && hour < 16) return 'Afternoon';
    if (hour >= 16 && hour < 20) return 'Evening';
    if (hour >= 20 && hour < 22) return 'Night';
    return 'Bedtime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Sweet Data')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date and Time',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectDate(context),
                                icon: Icon(Icons.calendar_today),
                                label: Text(
                                  DateFormat('yyyy-MM-dd').format(_selectedDate),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _selectTime(context),
                                icon: Icon(Icons.access_time),
                                label: Text(_selectedTime.format(context)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sweet Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _foodController,
                          decoration: InputDecoration(
                            labelText: 'What did you consume?',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.fastfood),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter what you consumed';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _remarksController,
                          decoration: InputDecoration(
                            labelText: 'Remarks (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.note),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Sweet Data',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _foodController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
} 