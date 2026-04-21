import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../features/reports/domain/entities/individual_report_entity.dart';

class PdfReportingService {
  /// Genera y descarga un reporte PDF del estudiante
  static Future<void> generateIndividualReportPdf(
    IndividualReportEntity report, {
    bool printDirect = false,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Encabezado
          pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'REPORTE ACADÉMICO INDIVIDUAL',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Sistema de Refuerzo Escolar',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
              ],
            ),
          ),

          // Información del estudiante
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Estudiante:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          report.estudianteNombre,
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Grado:',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          '${report.estudianteGrado}',
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Fecha de generación: ${DateTime.now().toString().split('.')[0]}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 25),

          // Resumen de desempeño
          pw.Text(
            'RESUMEN DE DESEMPEÑO',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildStatBox(
                  'Total Evaluaciones',
                  '${report.totalEvaluaciones}',
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _buildStatBox(
                  'Promedio General',
                  '${report.promedio}%',
                  highlight: true,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _buildStatBox(
                  'Evauaciones Aprobadas',
                  '${_countApproved(report)}',
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 25),

          // Tabla de evaluaciones
          pw.Text(
            'CALIFICACIONES POR EVALUACIÓN',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildEvaluacionesTable(report),
          pw.SizedBox(height: 25),

          // Observaciones
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              color: PdfColors.grey50,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'OBSERVACIONES',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  _getObservaciones(report),
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Descargar o imprimir
    if (printDirect) {
      await Printing.layoutPdf(onLayout: (_) => pdf.save());
    } else {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Reporte_${report.estudianteNombre}_${DateTime.now().toString().split(' ')[0]}.pdf',
      );
    }
  }

  /// Widget para caja de estadística
  static pw.Widget _buildStatBox(
    String label,
    String value, {
    bool highlight = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: highlight ? PdfColors.blue50 : PdfColors.grey50,
        border: pw.Border.all(
          color: highlight ? PdfColors.blue300 : PdfColors.grey300,
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: highlight ? PdfColors.blue700 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Tabla de evaluaciones
  static pw.Widget _buildEvaluacionesTable(IndividualReportEntity report) {
    final datos = report.resultados.map((r) {
      final calificacion = r.puntuacion;
      final estatus = r.aprobado ? 'Aprobado' : 'No aprobado';
      return [
        r.evaluacionTitulo,
        '$calificacion%',
        estatus,
        '${r.intentos}',
        r.fecha.toString().split(' ')[0],
      ];
    }).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Encabezado
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Evaluación', header: true),
            _buildTableCell('Nota', header: true),
            _buildTableCell('Estatus', header: true),
            _buildTableCell('Intentos', header: true),
            _buildTableCell('Fecha', header: true),
          ],
        ),
        // Datos
        ...datos.map((row) {
          final calificacion = int.tryParse(row[1].replaceAll('%', '')) ?? 0;
          final bgcolor = calificacion >= 80
              ? PdfColors.green50
              : calificacion >= 60
                  ? PdfColors.orange50
                  : PdfColors.red50;

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bgcolor),
            children: [
              _buildTableCell(row[0]),
              _buildTableCell(row[1], bold: true),
              _buildTableCell(row[2]),
              _buildTableCell(row[3]),
              _buildTableCell(row[4]),
            ],
          );
        }),
      ],
    );
  }

  /// Celda de tabla
  static pw.Widget _buildTableCell(
    String text, {
    bool header = false,
    bool bold = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: header ? 11 : 10,
          fontWeight: header || bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: header ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  /// Generador de observaciones
  static String _getObservaciones(IndividualReportEntity report) {
    final promedio = report.promedio;
    final aprobadas = _countApproved(report);
    final total = report.totalEvaluaciones;

    if (promedio >= 80) {
      return 'Excelente desempeño. El estudiante muestra consistencia en sus evaluaciones con un promedio superior a 80%. Se recomienda mantener este nivel.';
    } else if (promedio >= 60) {
      return 'Desempeño aceptable. El estudiante ha aprobado ${aprobadas} de ${total} evaluaciones. Se recomienda refuerzo en temas específicos.';
    } else {
      return 'Desempeño por debajo de lo esperado. Solo ${aprobadas} de ${total} evaluaciones fueron aprobadas. Se recomienda intervención académica urgente.';
    }
  }

  /// Cuenta evaluaciones aprobadas
  static int _countApproved(IndividualReportEntity report) {
    return report.resultados.where((r) => r.aprobado).length;
  }
}
