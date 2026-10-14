import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/services/api_config.dart';
import '../models/pesanan.dart';
import 'formatter.dart';

/// Membuat struk/invoice PDF dari data pesanan memakai package `pdf`.
class PdfGenerator {
  PdfGenerator._();

  static const _teal = PdfColor.fromInt(0xFF1C6E7D);
  static const _green = PdfColor.fromInt(0xFF8ADC64);
  static const _muted = PdfColor.fromInt(0xFF6B7A75);
  static const _line = PdfColor.fromInt(0xFFD7E2DC);

  static String namaFile(Pesanan p) => 'Struk_${p.nomorPesanan}.pdf';

  /// Font bawaan PDF (Helvetica) hanya mendukung Latin-1, jadi karakter lain diganti.
  static String _t(String s) => s
      .replaceAll(RegExp('[–—]'), '-')
      .replaceAll(RegExp('[‘’]'), "'")
      .replaceAll(RegExp('[“”]'), '"')
      .replaceAll(RegExp(r'[^\x00-\xFF]'), '?');

  static Future<Uint8List> buildStruk(Pesanan p, {PdfPageFormat? format}) async {
    final doc = pw.Document(
      title: 'Struk ${p.nomorPesanan}',
      author: ApiConfig.namaToko,
      creator: ApiConfig.namaAplikasi,
    );

    pw.MemoryImage? logo;
    try {
      final bytes = await rootBundle.load('assets/logo/logo_icon.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      logo = null; // struk tetap dibuat walau logo gagal dimuat
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: format ?? PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => ctx.pageNumber == 1 ? _header(logo) : pw.SizedBox(),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Halaman ${ctx.pageNumber}/${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ),
        build: (ctx) => [
          pw.SizedBox(height: 10),
          _infoPesanan(p),
          pw.SizedBox(height: 14),
          _tabelItem(p),
          pw.SizedBox(height: 10),
          _rincianBiaya(p),
          pw.SizedBox(height: 18),
          _penutup(p),
        ],
      ),
    );
    return doc.save();
  }

  static pw.Widget _header(pw.MemoryImage? logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _green, width: 2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logo != null) pw.Image(logo, width: 42, height: 42),
          if (logo != null) pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(ApiConfig.namaToko,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold, color: _teal)),
                pw.Text('${ApiConfig.namaAplikasi} - ${ApiConfig.taglineToko}',
                    style: const pw.TextStyle(fontSize: 8, color: _muted)),
              ],
            ),
          ),
          pw.Text('STRUK PEMBELIAN',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _teal)),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
                width: 78,
                child: pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: _muted))),
            pw.Text(': ', style: const pw.TextStyle(fontSize: 9)),
            pw.Expanded(child: pw.Text(_t(value), style: const pw.TextStyle(fontSize: 9))),
          ],
        ),
      );

  static pw.Widget _infoPesanan(Pesanan p) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _infoRow('No. Pesanan', p.nomorPesanan),
        _infoRow('Tanggal', Formatter.tanggalJam(p.tanggal)),
        _infoRow('Pemesan', p.namaPemesan),
        _infoRow('No. HP', p.noHp),
        _infoRow('Pengambilan', p.metodePengambilan),
        if (p.alamat != null) _infoRow('Alamat', p.alamat!),
        if (p.catatan != null) _infoRow('Catatan', p.catatan!),
        _infoRow('Status', p.status),
      ],
    );
  }

  static pw.Widget _tabelItem(Pesanan p) {
    const head = pw.TextStyle(fontSize: 9, color: PdfColors.white);
    return pw.TableHelper.fromTextArray(
      headers: ['Produk', 'Qty', 'Harga', 'Subtotal'],
      data: p.items
          .map((e) => [
                _t(e.namaProduk),
                '${e.jumlah}',
                Formatter.rupiah(e.hargaSatuan),
                Formatter.rupiah(e.subtotal),
              ])
          .toList(),
      headerStyle: head.copyWith(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: _teal),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FixedColumnWidth(28),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2.2),
      },
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _line, width: 0.6),
        bottom: pw.BorderSide(color: _line, width: 0.6),
      ),
    );
  }

  static pw.Widget _biayaRow(String label, String value, {bool bold = false}) {
    final style = pw.TextStyle(
      fontSize: bold ? 11 : 9,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: bold ? _teal : PdfColors.black,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label, style: style), pw.Text(value, style: style)],
      ),
    );
  }

  static pw.Widget _rincianBiaya(Pesanan p) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 210,
        child: pw.Column(
          children: [
            _biayaRow('Subtotal (${p.jumlahItem} item)', Formatter.rupiah(p.subtotal)),
            _biayaRow('Biaya layanan', Formatter.rupiah(p.biayaLayanan)),
            _biayaRow('Ongkos kirim', Formatter.rupiah(p.ongkir)),
            _biayaRow('Diskon', '- ${Formatter.rupiah(p.diskon)}'),
            pw.Divider(color: _line),
            _biayaRow('TOTAL BAYAR', Formatter.rupiah(p.total), bold: true),
          ],
        ),
      ),
    );
  }

  static pw.Widget _penutup(Pesanan p) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF1FAEC),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        children: [
          pw.Text('Terima kasih telah berbelanja di ${ApiConfig.namaToko}!',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _teal)),
          pw.SizedBox(height: 3),
          pw.Text(
            'Simpan struk ini sebagai bukti pembelian. Gunakan obat sesuai aturan pakai; '
            'bila sakit berlanjut, hubungi dokter.',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
          pw.SizedBox(height: 3),
          pw.Text('Dicetak: ${Formatter.tanggalJam(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 7, color: _muted)),
        ],
      ),
    );
  }

  /// Simpan PDF ke penyimpanan perangkat. Mengembalikan path file.
  /// Android: folder Download milik aplikasi (`Android/data/<package>/files/Download`),
  /// fallback ke folder dokumen aplikasi.
  static Future<String> simpanKePerangkat(Uint8List bytes, String fileName) async {
    Directory? dir;
    try {
      if (Platform.isAndroid) {
        final ext = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (ext != null && ext.isNotEmpty) dir = ext.first;
      } else {
        dir = await getDownloadsDirectory();
      }
    } catch (_) {
      dir = null;
    }
    dir ??= await getApplicationDocumentsDirectory();
    if (!await dir.exists()) await dir.create(recursive: true);

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
