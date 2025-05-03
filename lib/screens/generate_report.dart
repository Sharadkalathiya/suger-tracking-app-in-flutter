import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../models/record_provider.dart';
import '../models/record_model.dart';

class GenerateReport extends StatelessWidget {
  Future<void> _generateAndPreviewPdf(BuildContext context, RecordProvider provider) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Text('Sugar Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Report Generated on: ${DateTime.now().toString()}', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Date', 'Time', 'Meal Time', 'Sugar', 'Dose', 'Food', 'Remarks'],
              data: provider.filteredRecords.map((Record record) {
                return [
                  record.date,
                  record.time,
                  record.mealTime,
                  record.sugar.toString(),
                  record.insulinDose.toString(),
                  record.food,
                  record.remarks ?? '',
                ];
              }).toList(),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Average Sugar Levels:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            _averageSugarDetails(provider),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/Diabetes_Report.pdf');
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }

  pw.Widget _averageSugarDetails(RecordProvider provider) {
    final averages = provider.calculateAverageSugar();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Overall Average Sugar: ${averages['overall']?.toStringAsFixed(1) ?? 'N/A'} mg/dL'),
        pw.Text('Morning Average: ${averages['Morning']?.toStringAsFixed(1) ?? 'N/A'} mg/dL'),
        pw.Text('Afternoon Average: ${averages['Afternoon']?.toStringAsFixed(1) ?? 'N/A'} mg/dL'),
        pw.Text('Evening Average: ${averages['Evening']?.toStringAsFixed(1) ?? 'N/A'} mg/dL'),
        pw.Text('Night Average: ${averages['Night']?.toStringAsFixed(1) ?? 'N/A'} mg/dL'),
        pw.Text('Bedtime Average: ${averages['Bedtime']?.toStringAsFixed(1) ?? 'N/A'} mg/dL'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecordProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Report')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _generateAndPreviewPdf(context, provider),
              child: const Text('Preview Report'),
            ),
          ],
        ),
      ),
    );
  }
}