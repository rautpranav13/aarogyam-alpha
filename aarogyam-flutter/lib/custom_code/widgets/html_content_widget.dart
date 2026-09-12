// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_html/flutter_html.dart'; // Add this package to your pubspec.yaml

class HtmlContentWidget extends StatefulWidget {
  const HtmlContentWidget({
    super.key,
    this.width,
    this.height,
    this.htmlContent,
  });

  final double? width;
  final double? height;
  final String? htmlContent;

  @override
  State<HtmlContentWidget> createState() => _HtmlContentWidgetState();
}

class _HtmlContentWidgetState extends State<HtmlContentWidget> {
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
          data: widget.htmlContent ?? "<p>No content available.</p>",
          style: {
            "h2": Style(
              color: Colors.blue,
              fontSize: FontSize.large,
              fontWeight: FontWeight.bold,
            ),
            "ul": Style(
              margin: Margins.all(10), // Correct usage of Margins
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
