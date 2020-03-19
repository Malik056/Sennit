import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';

class PDFViewerRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.all(8),
        child: FutureBuilder<PDFDocument>(
          future: PDFDocument.fromAsset('assets/docs/privacy_policy.pdf'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Center(
                child: PDFViewer(document: snapshot.data),
              );
            }
          },
        ),
      ),
    );
  }
}
