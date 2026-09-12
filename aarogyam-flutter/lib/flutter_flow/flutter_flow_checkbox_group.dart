// flutter_flow_checkbox_group.dart — compatibility shim.
// FlutterFlowCheckboxGroup maps to a column of CheckboxListTiles.

import 'package:flutter/material.dart';

class FlutterFlowCheckboxGroup extends StatefulWidget {
  const FlutterFlowCheckboxGroup({
    super.key,
    required this.options,
    required this.onChanged,
    this.controller,
    this.labelStyle,
    this.textStyle,
    this.labelPadding,
    this.activeColor,
    this.checkColor,
    this.checkboxBorderColor,
    this.checkboxBorderRadius,
    this.initialized = false,
    this.itemPadding,
    this.unselectedTextStyle,
    this.selectedTextStyle,
  });

  final List<String> options;
  final void Function(List<String>)? onChanged;
  final dynamic controller;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? labelPadding;
  final Color? activeColor;
  final Color? checkColor;
  final Color? checkboxBorderColor;
  final BorderRadius? checkboxBorderRadius;
  final bool initialized;
  final EdgeInsetsGeometry? itemPadding;
  final TextStyle? unselectedTextStyle;
  final TextStyle? selectedTextStyle;

  @override
  State<FlutterFlowCheckboxGroup> createState() =>
      _FlutterFlowCheckboxGroupState();
}

class _FlutterFlowCheckboxGroupState extends State<FlutterFlowCheckboxGroup> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(
      (widget.controller?.value as List<String>?) ?? <String>[],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.options.map((option) {
        final isSelected = _selected.contains(option);
        return CheckboxListTile(
          value: isSelected,
          title: Text(
            option,
            style: isSelected
                ? (widget.selectedTextStyle ?? widget.labelStyle)
                : (widget.unselectedTextStyle ?? widget.labelStyle),
          ),
          activeColor:
              widget.activeColor ?? Theme.of(context).colorScheme.primary,
          checkColor: widget.checkColor,
          contentPadding: widget.itemPadding ?? EdgeInsets.zero,
          shape: widget.checkboxBorderRadius != null
              ? RoundedRectangleBorder(
                  borderRadius: widget.checkboxBorderRadius!)
              : null,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _selected.add(option);
              } else {
                _selected.remove(option);
              }
            });
            widget.onChanged?.call(List.from(_selected));
          },
        );
      }).toList(),
    );
  }
}
