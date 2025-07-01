import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

Future<void> printBook(String htmlText) async {
  final pdf = pw.Document();
  final fontData = await rootBundle.load('assets/fonts/dijlah-reg.ttf');
  final customFont = pw.Font.ttf(fontData);

  final document = html_parser.parse(htmlText);
  final body = document.body;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      margin: pw.EdgeInsets.all(20),
      theme: pw.ThemeData.withFont(base: customFont),
      build: (pw.Context context) {
        return _parseHtmlToWidgets(body!, customFont);
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

List<pw.Widget> _parseHtmlToWidgets(dom.Element element, pw.Font font) {
  final widgets = <pw.Widget>[];

  for (var node in element.nodes) {
    if (node is dom.Element) {
      switch (node.localName) {
        case 'p':
          widgets.add(pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              node.text.trim(),
              style: pw.TextStyle(font: font, fontSize: 14),
            ),
          ));
          break;
        case 'h1':
          widgets.add(pw.Text(
            node.text.trim(),
            style: pw.TextStyle(
                font: font, fontSize: 20, fontWeight: pw.FontWeight.bold),
          ));
          break;
        case 'b':
        case 'strong':
          widgets.add(pw.Text(
            node.text.trim(),
            style: pw.TextStyle(
                font: font, fontSize: 14, fontWeight: pw.FontWeight.bold),
          ));
          break;
        case 'br':
          widgets.add(pw.SizedBox(height: 10));
          break;
        default:
          widgets.addAll(_parseHtmlToWidgets(node, font));
          break;
      }
    } else if (node is dom.Text) {
      widgets.add(pw.Text(
        node.text.trim(),
        style: pw.TextStyle(font: font, fontSize: 14),
      ));
    }
  }

  return widgets;
}
