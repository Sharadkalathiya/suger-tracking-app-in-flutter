import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../models/record_provider.dart';
import '../models/record_model.dart';

class SweetReport extends StatefulWidget {
  @override
  _SweetReportState createState() => _SweetReportState();
}

class _SweetReportState extends State<SweetReport> {
  bool _isGenerating = false;

  Future<void> _generateReport(BuildContext context, List<Record> sweetEntries) async {
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
                  child: pw.Text('Sweet Consumption Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Total Entries: ${sweetEntries.length}',
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
                    3: pw.FlexColumnWidth(3), // Food
                    4: pw.FlexColumnWidth(3), // Remarks
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
                    ...sweetEntries.map((entry) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(entry.date),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(entry.time),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(entry.mealTime),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(entry.food),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(entry.remarks ?? ''),
                            ),
                          ],
                        )),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save the PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/sweet_report.pdf');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sweet Report'),
      ),
      body: Consumer<RecordProvider>(
        builder: (context, provider, child) {
          final sweetEntries = provider.filteredRecords
              .where((record) => record.sugar == 0)
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cake,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Generate Sweet Consumption Report',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total Entries: ${sweetEntries.length}',
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
                      onPressed: sweetEntries.isEmpty
                          ? null
                          : () => _generateReport(context, sweetEntries),
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