// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart'; // Import the flutter_html_table package
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HtmlWidget3 extends StatefulWidget {
  const HtmlWidget3({
    super.key,
    this.width,
    this.height,
    this.txtFileName,
  });

  final double? width;
  final double? height;
  final String? txtFileName;

  @override
  State<HtmlWidget3> createState() => _HtmlWidget3State();
}

class _HtmlWidget3State extends State<HtmlWidget3> {
  String? _htmlContent;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    if (widget.txtFileName != null) {
      _loadFileContent(widget.txtFileName!);
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel(); // Cancel retry timer
    super.dispose();
  }

  Future<void> _loadFileContent(String fileName) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) return;

    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        _htmlContent = content;
      });
      _retryTimer?.cancel(); // Stop retrying once the file is found
    } else {
      setState(() {
        _htmlContent = "<p>File not found. Retrying...</p>";
      });

      if (_retryTimer == null || !_retryTimer!.isActive) {
        _retryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _loadFileContent(fileName); // Retry loading the file
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
      ),
      child: SingleChildScrollView(
        child: Html(
          data: _htmlContent ?? "<p>Loading...</p>",
          extensions: const [
            // Enable the table support extension
            TableHtmlExtension(),
          ],
          style: {
            "table": Style(
              backgroundColor: Colors.grey[200],
              border: Border.all(color: Colors.black),
              padding: HtmlPaddings.all(8.0),
              margin: Margins.symmetric(vertical: 10, horizontal: 5),
            ),
            "th": Style(
              backgroundColor: Colors.grey[300],
              fontWeight: FontWeight.bold,
              padding: HtmlPaddings.all(8.0),
              border: Border.all(color: Colors.black),
            ),
            "td": Style(
              padding: HtmlPaddings.all(8.0),
              border: Border.all(color: Colors.black),
            ),
          },
        ),
      ),
    );
  }
}
