import '/backend/api_requests/api_calls.dart';
import '/core/base_model.dart';
import '/core/types/uploaded_file.dart';
import 'chat_bot_widget.dart' show ChatBotWidget;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

class ChatBotModel extends BaseModel<ChatBotWidget> {
  // TTS action outputs
  String? ragResponseWithoutHtml;
  String? ttsaudioPath;
  String? ragresponsewithouthtml2;
  String? ttsaudioPath2;

  // Text input
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;

  // RAG API response
  ApiCallResponse? ragAPIresponse;

  // Voice recording
  AudioRecorder? audioRecorder;
  String? recordedAudio;
  FFUploadedFile recordedFileBytes = FFUploadedFile(bytes: Uint8List(0));
  String? recordedFilePath;
  String? rspeechText;

  @override
  void initState(BuildContext context) {
    textController ??= TextEditingController();
    textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
    audioRecorder?.dispose();
    super.dispose();
  }
}
