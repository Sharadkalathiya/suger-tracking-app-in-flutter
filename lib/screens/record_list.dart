import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/record_provider.dart';
import '../models/record_model.dart';

class RecordList extends StatefulWidget {
  @override
  _RecordListState createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  String selectedFilter = 'All';
  String selectedSort = 'New to Old';

  Future<bool> _confirmDelete(BuildContext context, Record record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this record?'),
              SizedBox(height: 8),
              Text(
                '${record.date} at ${record.time}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Sugar Level: ${record.sugar} mg/dL'),
              Text('Meal Time: ${record.mealTime}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmed) {
      Provider.of<RecordProvider>(context, listen: false).removeRecord(record.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Record deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO: Implement undo functionality if needed
            },
          ),
        ),
      );
    }
    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecordProvider>(context);
    // Filter to show only regular records (where sugar > 0)
    final regularRecords = provider.filteredRecords.where((record) => record.sugar > 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Records'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFilter,
                    decoration: InputDecoration(
                      labelText: 'Filter',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: ['All', 'Morning', 'Afternoon', 'Evening', 'Night', 'Bedtime']
                        .map((filter) => DropdownMenuItem<String>(
                              value: filter,
                              child: Text(filter),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedFilter = value;
                          if (value == 'All') {
                            provider.clearFilter();
                          } else {
                            provider.applyFilter(value);
                          }
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSort,
                    decoration: InputDecoration(
                      labelText: 'Sort',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      'New to Old',
                      'Old to New',
                      'High to Low',
                      'Low to High'
                    ]
                        .map((sort) => DropdownMenuItem<String>(
                              value: sort,
                              child: Text(sort),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedSort = value;
                          provider.applySort(value);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: regularRecords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No records found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: regularRecords.length,
              itemBuilder: (context, index) {
                final record = regularRecords[index];
                final sugarLevel = record.sugar;
                final color = _getSugarLevelColor(sugarLevel);

                return Dismissible(
                  key: Key(record.id ?? DateTime.now().toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await _confirmDelete(context, record);
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${record.sugar} mg/dL',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            record.mealTime,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text('${record.date} at ${record.time}'),
                          Text('Food: ${record.food}'),
                          if (record.remarks?.isNotEmpty ?? false)
                            Text('Remarks: ${record.remarks}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${record.insulinDose} units',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            'Insulin',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getSugarLevelColor(int sugarLevel) {
    if (sugarLevel >= 91 && sugarLevel <= 150) {
      return Colors.green;
    } else if (sugarLevel >= 151 && sugarLevel <= 170) {
      return Colors.orange;
    } else if (sugarLevel >= 171 && sugarLevel <= 250) {
      return Colors.deepOrange;
    } else if (sugarLevel >= 251) {
      return Colors.red;
    } else {
      return Colors.purple;
    }
  }
} 