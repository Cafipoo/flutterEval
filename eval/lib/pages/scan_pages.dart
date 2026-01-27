import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // Flag pour éviter de scanner 50 fois le même code et faire crash l'app
  bool isScanFinished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scannez un produit')),
      body: MobileScanner(
        onDetect: (capture) {
          if (isScanFinished) return; // Si on a déjà détecté un code, on ne fait rien

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              isScanFinished = true; // On bloque les futurs scans
              
              // On attend un tout petit peu que le scanner se stabilise avant de quitter
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  Navigator.pop(context, code);
                }
              });
            }
          }
        },
      ),
    );
  }
}
