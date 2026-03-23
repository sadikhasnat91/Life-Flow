import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'database_service.dart';

class ExportService {
  static Future<void> exportData() async {
    final pdf = pw.Document();
    final tasks = DatabaseService.getAllTasks();
    final goals = DatabaseService.getAllGoals();
    final habits = DatabaseService.getAllHabits();
    final notes = DatabaseService.getAllNotes();
    final now = DateFormat('MMM dd, yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('LifeFlow - Data Export',
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Generated on $now',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
            pw.Divider(),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (context) => [
          // Tasks section
          pw.Text('Tasks (${tasks.length})',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (tasks.isEmpty)
            pw.Text('No tasks', style: const pw.TextStyle(color: PdfColors.grey))
          else
            ...tasks.map((t) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(children: [
                    pw.Text(t.isCompleted ? '[x]' : '[ ]',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(t.title,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold)),
                          if (t.deadline != null)
                            pw.Text(
                              'Due: ${DateFormat('MMM dd, yyyy hh:mm a').format(t.deadline!)}',
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey),
                            ),
                        ],
                      ),
                    ),
                    pw.Text(t.priorityLabel,
                        style: const pw.TextStyle(fontSize: 10)),
                  ]),
                )),
          pw.SizedBox(height: 20),

          // Goals section
          pw.Text('Goals (${goals.length})',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (goals.isEmpty)
            pw.Text('No goals', style: const pw.TextStyle(color: PdfColors.grey))
          else
            ...goals.map((g) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(g.title,
                          style:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        'Target: ${DateFormat('MMM dd, yyyy').format(g.targetDate)} | ${g.isCompleted ? "Completed" : "In Progress"} | ${(g.progress * 100).toInt()}%',
                        style:
                            const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                      ),
                    ],
                  ),
                )),
          pw.SizedBox(height: 20),

          // Habits section
          pw.Text('Habits (${habits.length})',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (habits.isEmpty)
            pw.Text('No habits', style: const pw.TextStyle(color: PdfColors.grey))
          else
            ...habits.map((h) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(h.title,
                          style:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                          'Streak: ${h.currentStreak}d | Best: ${h.longestStreak}d',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                )),
          pw.SizedBox(height: 20),

          // Notes section
          pw.Text('Notes (${notes.length})',
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          if (notes.isEmpty)
            pw.Text('No notes', style: const pw.TextStyle(color: PdfColors.grey))
          else
            ...notes.map((n) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 6),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(n.title,
                          style:
                              pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      if (n.content.isNotEmpty)
                        pw.Text(
                          n.content.length > 200
                              ? '${n.content.substring(0, 200)}...'
                              : n.content,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                    ],
                  ),
                )),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'LifeFlow_Export_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
