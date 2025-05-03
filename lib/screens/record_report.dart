import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../models/record_provider.dart';
import '../models/record_model.dart';

class RecordReport extends StatefulWidget {
  @override
  _RecordReportState createState() => _RecordReportState();
}

class _RecordReportState extends State<RecordReport> {
  bool _isGenerating = false;

  Future<void> _generateReport(BuildContext context, List<Record> records) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final pdf = pw.Document();

      // Add title
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Text('Diabetes Records Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Total Records: ${records.length}',
                  style: pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 20),
                // Create table
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: pw.FlexColumnWidth(2), // Date
                    1: pw.FlexColumnWidth(1.5), // Time
                    2: pw.FlexColumnWidth(1.5), // Time of Day
                    3: pw.FlexColumnWidth(1.5), // Sugar Level
                    4: pw.FlexColumnWidth(1.5), // Insulin
                    5: pw.FlexColumnWidth(2), // Food
                    6: pw.FlexColumnWidth(2), // Remarks
                  },
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Date',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Time',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Time of Day',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Sugar Level\n(mg/dL)',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Insulin\n(units)',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Food',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Remarks',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Data rows
                    ...records.map((record) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(record.date),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(record.time),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(record.mealTime),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text('${record.sugar}'),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text('${record.insulinDose}'),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(record.food),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(record.remarks ?? ''),
                            ),
                          ],
                        )),
                  ],
                ),
                pw.SizedBox(height: 20),
                // Add statistics
                pw.Header(
                  level: 1,
                  child: pw.Text('Statistics',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ),
                pw.SizedBox(height: 10),
                _buildStatistics(records),
              ],
            );
          },
        ),
      );

      // Save the PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/diabetes_report.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open the PDF
      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report generated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  pw.Widget _buildStatistics(List<Record> records) {
    // Calculate overall average
    final overallAvg = records.isEmpty
        ? 0.0
        : records.map((r) => r.sugar).reduce((a, b) => a + b) / records.length;

    // Calculate averages by time of day
    final morningRecords = records.where((r) => r.mealTime == 'Morning').toList();
    final afternoonRecords = records.where((r) => r.mealTime == 'Afternoon').toList();
    final eveningRecords = records.where((r) => r.mealTime == 'Evening').toList();
    final nightRecords = records.where((r) => r.mealTime == 'Night').toList();
    final bedtimeRecords = records.where((r) => r.mealTime == 'Bedtime').toList();

    String calculateAverage(List<Record> records) {
      if (records.isEmpty) return 'N/A';
      final avg = records.map((r) => r.sugar).reduce((a, b) => a + b) / records.length;
      return '${avg.toStringAsFixed(1)} mg/dL';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Average Sugar Levels:',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Overall Average Sugar: ${overallAvg.toStringAsFixed(1)} mg/dL'),
        pw.Text('Morning Average: ${calculateAverage(morningRecords)}'),
        pw.Text('Afternoon Average: ${calculateAverage(afternoonRecords)}'),
        pw.Text('Evening Average: ${calculateAverage(eveningRecords)}'),
        pw.Text('Night Average: ${calculateAverage(nightRecords)}'),
        pw.Text('Bedtime Average: ${calculateAverage(bedtimeRecords)}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Records Report'),
      ),
      body: Consumer<RecordProvider>(
        builder: (context, provider, child) {
          final records = provider.filteredRecords
              .where((record) => record.sugar > 0)
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Generate Records Report',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total Records: ${records.length}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 32),
                  if (_isGenerating)
                    CircularProgressIndicator()
                  else
                    ElevatedButton.icon(
                      onPressed: records.isEmpty
                          ? null
                          : () => _generateReport(context, records),
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text('Generate PDF Report'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

int max(int a, int b) => a > b ? a : b;
int min(int a, int b) => a < b ? a : b; 