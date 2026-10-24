import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sra_346_movil/src/models/qr.dart';
import 'package:sra_346_movil/src/screens/ConfirmationAttendance.dart';
import 'package:sra_346_movil/src/services/loginService.dart';

class QrScan extends StatefulWidget {
  const QrScan({super.key});
  @override
  State<QrScan> createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> {
  bool _busy = false;

  Future<void> _scan() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final value = await Navigator.of(
        context,
      ).push<String>(MaterialPageRoute(builder: (_) => const QrScannerPage()));
      if (value == null || !mounted) return;
      final qr = QR.fromScan(value);
      final matricula = await LoginService().getMatricula(qr.asignaturaId);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConfirmationAttendance(
            codQr: qr.toJson(),
            username: matricula.toString(),
          ),
        ),
      );
    } on FormatException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo consultar la matrícula. Revisa tu conexión y sesión.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.add_a_photo),
    title: Text(_busy ? 'Consultando clase…' : 'Ingresar a clase'),
    onTap: _busy ? null : _scan,
  );
}

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});
  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final _controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  bool _completed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Escanear código de la clase')),
    body: MobileScanner(
      controller: _controller,
      onDetect: (capture) {
        if (_completed || !mounted) return;
        for (final barcode in capture.barcodes) {
          final value = barcode.rawValue;
          if (value != null && value.isNotEmpty) {
            _completed = true;
            Navigator.of(context).pop(value);
            return;
          }
        }
      },
      errorBuilder: (context, error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error.errorCode == MobileScannerErrorCode.permissionDenied
                ? 'Permite el acceso a la cámara en Ajustes para escanear el código QR.'
                : 'No se pudo iniciar la cámara. Vuelve a intentarlo.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
