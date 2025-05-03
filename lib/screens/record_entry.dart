import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/record_provider.dart';
import '../models/record_model.dart';

class RecordEntry extends StatefulWidget {
  @override
  _RecordEntryState createState() => _RecordEntryState();
}

class _RecordEntryState extends State<RecordEntry> {
  final TextEditingController sugarController = TextEditingController();
  final TextEditingController insulinDoseController = TextEditingController();
  final TextEditingController foodController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  String selectedMealTime = 'Morning';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Record')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      Text('Date and Time', 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                  });
                                }
                              },
                              label: Text(selectedDate == null
                                  ? 'Pick Date'
                                  : DateFormat('dd-MM-yyyy').format(selectedDate!)),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.access_time),
                              onPressed: () async {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (pickedTime != null) {
                                  setState(() {
                                    selectedTime = pickedTime;
                                  });
                                }
                              },
                              label: Text(selectedTime == null
                                  ? 'Pick Time'
                                  : selectedTime!.format(context)),
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
                      Text('Record Details', 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedMealTime,
                        decoration: InputDecoration(
                          labelText: 'Meal Time',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Morning', 'Afternoon', 'Evening', 'Night', 'Bedtime']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedMealTime = newValue;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: sugarController,
                        decoration: InputDecoration(
                          labelText: 'Sugar Level (mg/dL)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: insulinDoseController,
                        decoration: InputDecoration(
                          labelText: 'Insulin Dose (units)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: foodController,
                        decoration: InputDecoration(
                          labelText: 'Food Consumed',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: remarksController,
                        decoration: InputDecoration(
                          labelText: 'Remarks (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Save Record', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveRecord() {
    if (!_validateInputs()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final record = Record(
      userId: userId,
      date: DateFormat('dd-MM-yyyy').format(selectedDate!),
      time: selectedTime!.format(context),
      mealTime: selectedMealTime,
      sugar: int.parse(sugarController.text),
      insulinDose: int.parse(insulinDoseController.text),
      food: foodController.text,
      remarks: remarksController.text,
      timestamp: DateTime.now(),
    );

    Provider.of<RecordProvider>(context, listen: false).addRecord(record);
    Navigator.pop(context);
  }

  bool _validateInputs() {
    if (selectedDate == null) {
      _showError('Please select a date');
      return false;
    }
    if (selectedTime == null) {
      _showError('Please select a time');
      return false;
    }
    if (sugarController.text.isEmpty) {
      _showError('Please enter sugar level');
      return false;
    }
    if (insulinDoseController.text.isEmpty) {
      _showError('Please enter insulin dose');
      return false;
    }
    if (foodController.text.isEmpty) {
      _showError('Please enter food details');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    sugarController.dispose();
    insulinDoseController.dispose();
    foodController.dispose();
    remarksController.dispose();
    super.dispose();
  }
} 