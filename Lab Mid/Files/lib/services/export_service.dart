import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/task_item.dart';

class ExportService {
  Future<void> exportCsv(List<TaskItem> tasks) async {
    final rows = <List<String>>[
      <String>[
        'Title',
        'Description',
        'Due Date',
        'Completed',
        'Repeat',
        'Progress',
      ],
      ...tasks.map(
        (task) => <String>[
          task.title,
          task.description,
          DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate),
          task.isCompleted ? 'Yes' : 'No',
          task.repeatLabel,
          '${(task.progress * 100).round()}%',
        ],
      ),
    ];

    final file = await _writeTempFile(
      'tasks_export.csv',
      const ListToCsvConverter().convert(rows),
    );
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path)],
        text: 'TaskFlow CSV export',
      ),
    );
  }

  Future<void> exportPdf(List<TaskItem> tasks) async {
    final document = pw.Document();
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.all(28),
        ),
        build: (context) {
          return <pw.Widget>[
            pw.Text(
              'TaskFlow Pro Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Total tasks: ${tasks.length}'),
            pw.SizedBox(height: 20),
            ...tasks.map(
              (task) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.teal300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      task.title,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(task.description),
                    pw.SizedBox(height: 6),
                    pw.Text('Due: ${formatter.format(task.dueDate)}'),
                    pw.Text('Status: ${task.isCompleted ? 'Completed' : 'Pending'}'),
                    pw.Text('Repeat: ${task.repeatLabel}'),
                    pw.Text('Progress: ${(task.progress * 100).round()}%'),
                  ],
                ),
              ),
            ),
          ];
        },
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/tasks_export.pdf');
    await file.writeAsBytes(await document.save());
    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path)],
        text: 'TaskFlow PDF export',
      ),
    );
  }

  Future<void> emailTasks(List<TaskItem> tasks) async {
    final completed = tasks.where((task) => task.isCompleted).length;
    final body = StringBuffer()
      ..writeln('TaskFlow Pro Summary')
      ..writeln()
      ..writeln('Total tasks: ${tasks.length}')
      ..writeln('Completed tasks: $completed')
      ..writeln()
      ..writeln('Upcoming items:')
      ..writeln();

    for (final task in tasks.take(10)) {
      body.writeln(
        '- ${task.title} | ${DateFormat('dd MMM yyyy, hh:mm a').format(task.dueDate)} | ${task.repeatLabel}',
      );
    }

    final uri = Uri(
      scheme: 'mailto',
      queryParameters: <String, String>{
        'subject': 'TaskFlow Pro Export',
        'body': body.toString(),
      },
    );

    await launchUrl(uri);
  }

  Future<File> _writeTempFile(String fileName, String content) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }
}
