// lib/services/export_service.dart

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/measurement.dart';

class ExportService {
  static Future<void> exportMeasurementAsPdf(
    Measurement measurement,
  ) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('MeasureSnap Measurement Report'),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Date: ${measurement.createdAt}'),
              pw.Text('Reference: ${measurement.referenceUsed.name}'),
              if (measurement.title != null)
                pw.Text('Title: ${measurement.title}'),
              pw.SizedBox(height: 20),
              pw.Header(
                level: 1,
                child: pw.Text('Measurements:'),
              ),
              ...measurement.measurements.asMap().entries.map(
                (entry) => pw.Container(
                  margin: const pw.EdgeInsets.symmetric(vertical: 5),
                  child: pw.Text(
                    '${entry.key + 1}. ${entry.value.distanceMm.toStringAsFixed(1)} mm '
                    '(${entry.value.distanceInches.toStringAsFixed(2)} inches)',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/measurement_${measurement.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'MeasureSnap Measurement Report',
    );
  }
  
  static Future<void> exportAllMeasurements(
    List<Measurement> measurements,
  ) async {
    final csv = StringBuffer();
    csv.writeln('Date,Title,Reference,Distance (mm),Distance (inches)');
    
    for (final measurement in measurements) {
      for (final line in measurement.measurements) {
        csv.writeln(
          '${measurement.createdAt},'
          '${measurement.title ?? "Untitled"},'
          '${measurement.referenceUsed.name},'
          '${line.distanceMm.toStringAsFixed(1)},'
          '${line.distanceInches.toStringAsFixed(2)}',
        );
      }
    }
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/measurements_export.csv');
    await file.writeAsString(csv.toString());
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'MeasureSnap Measurements Export',
    );
  }
}