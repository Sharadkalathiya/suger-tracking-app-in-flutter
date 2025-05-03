import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/record_provider.dart';
import '../models/record_model.dart';

class SweetList extends StatefulWidget {
  @override
  _SweetListState createState() => _SweetListState();
}

class _SweetListState extends State<SweetList> {
  String selectedFilter = 'All';
  String selectedSort = 'New to Old';

  Future<bool> _confirmDelete(BuildContext context, Record record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Sweet Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this sweet entry?'),
              SizedBox(height: 8),
              Text(
                '${record.date} at ${record.time}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Food: ${record.food}'),
              if (record.remarks?.isNotEmpty ?? false)
                Text('Remarks: ${record.remarks}'),
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
          content: Text('Sweet entry deleted'),
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
    // Filter to show only sweet entries (where sugar is 0)
    final sweetEntries = provider.filteredRecords.where((record) => record.sugar == 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sweet Entries'),
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
      body: sweetEntries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cookie, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No sweet entries found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: sweetEntries.length,
              itemBuilder: (context, index) {
                final record = sweetEntries[index];
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
                      leading: Icon(Icons.cookie, color: Theme.of(context).primaryColor),
                      title: Text(
                        record.food,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${record.date} at ${record.time}'),
                          Text('Time of day: ${record.mealTime}'),
                          if (record.remarks?.isNotEmpty ?? false)
                            Text('Remarks: ${record.remarks}'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
    );
  }
} 