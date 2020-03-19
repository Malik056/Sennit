import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';

class PDFViewerRoute extends StatelessWidget {
  Future<String> prepareTestPdf(context) async {
    final _documentPath = 'assets/docs/privacy_policy.pdf';
    final ByteData bytes =
        await DefaultAssetBundle.of(context).load(_documentPath);
    final Uint8List list = bytes.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$_documentPath';

    final file = await File(tempDocumentPath).create(recursive: true);
    file.writeAsBytesSync(list);
    return tempDocumentPath;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: prepareTestPdf(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Center(
            child: PDFViewerScaffold(
              appBar: AppBar(
                title: Text("Privacy Policy"),
                centerTitle: true,
              ),
              path: snapshot.data,
            ),
          );
        }
      },
    );
  }
}
