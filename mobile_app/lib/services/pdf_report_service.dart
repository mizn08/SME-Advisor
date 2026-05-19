import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/prediction.dart';

class PdfReportService {
  static Future<File> buildRecommendationPdf(PredictionResult r, String businessName) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('SME Advisor — Financing Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Business: $businessName'),
            pw.Divider(),
            pw.Text('Recommendation: ${r.recommendationType}'),
            pw.Text('Product: ${r.productName}'),
            pw.Text('Cash preserved: RM ${r.cashPreservedRm.toStringAsFixed(2)}'),
            pw.Text('Additional cost: RM ${r.additionalCostRm.toStringAsFixed(2)}'),
            pw.Text('Confidence: ${(r.confidence * 100).toStringAsFixed(1)}%'),
            pw.SizedBox(height: 12),
            pw.Text(r.explanation),
          ],
        ),
      ),
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/sme_advisor_report.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }
}
