// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io'; // Import for file handling
import 'package:path_provider/path_provider.dart'; // Import for storage path access
import 'package:flutter_html/flutter_html.dart'; // Add this package to your pubspec.yaml

class HtmlContentWidget2 extends StatefulWidget {
  const HtmlContentWidget2({
    super.key,
    this.width,
    this.height,
    this.txtFileName,
  });

  final double? width;
  final double? height;
  final String? txtFileName;

  @override
  State<HtmlContentWidget2> createState() => _HtmlContentWidget2State();
}

class _HtmlContentWidget2State extends State<HtmlContentWidget2> {
  String? _htmlContent;

  @override
  void initState() {
    super.initState();
    // Read the file content if a file name is provided
    if (widget.txtFileName != null) {
      _loadFileContent(widget.txtFileName!);
    }
  }

  // Method to load content from the txt file
  Future<void> _loadFileContent(String fileName) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) return;

    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // Check if file exists and read its content
    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        _htmlContent = content;
      });
    } else {
      setState(() {
        _htmlContent = "<p>File not found at path: $filePath</p>";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: SingleChildScrollView(
        child: Html(
          data: _htmlContent ?? "<p>Loading...</p>", // Default loading message
          style: {
            "h2": Style(
              color: Colors.blue,
              fontSize: FontSize.large,
              fontWeight: FontWeight.bold,
            ),
            "ul": Style(
              margin: Margins.all(10),
            ),
            "li": Style(
              color: Colors.black87,
              fontSize: FontSize.medium,
            ),
            "p": Style(
              color: Colors.grey[800],
              fontSize: FontSize.small,
            ),
          },
        ),
      ),
    );
  }
}
