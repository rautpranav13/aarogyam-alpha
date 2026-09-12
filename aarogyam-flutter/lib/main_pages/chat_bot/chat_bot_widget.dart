import '/app_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'chat_bot_model.dart';
export 'chat_bot_model.dart';

class ChatBotWidget extends StatefulWidget {
  const ChatBotWidget({super.key});

  @override
  State<ChatBotWidget> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget>
    with TickerProviderStateMixin {
  late ChatBotModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = ChatBotModel();
    _model.init(context);
    // Microphone permission request deferred — handled lazily on long-press.
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // ---- helpers ----

  Future<void> _sendText() async {
    final query = _model.textController?.text.trim() ?? '';
    if (query.isEmpty) return;

    context.read<AppState>().update(() {
      context.read<AppState>().typedMessage = query;
      context.read<AppState>().isTranslate = false;
    });
    _model.textController?.clear();
    setState(() => _isLoading = true);

    try {
      _model.ragAPIresponse = await RagAPICall.call(query: query);
      if (mounted && (_model.ragAPIresponse?.succeeded ?? false)) {
        await actions.saveTXT(
          RagAPICall.ragResponsePath(_model.ragAPIresponse!.jsonBody).toString(),
          'ragresponse.txt',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startRecording() async {
    _model.audioRecorder ??= AudioRecorder();
    final hasPermission = await _model.audioRecorder!.hasPermission();
    if (!hasPermission) return;
    await _model.audioRecorder!.start(
      const RecordConfig(encoder: AudioEncoder.wav),
      path: '', // record to temp file
    );
    if (mounted) {
      setState(() {
        _model.textController?.text = 'RECORDING...';
        context.read<AppState>().isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _model.audioRecorder?.stop();
    if (mounted) {
      context.read<AppState>().update(() {
        context.read<AppState>().isRecording = false;
      });
      _model.textController?.clear();
    }
    if (path != null) {
      _model.recordedFilePath = path;
      final text = await actions.transcribeAudio(
        dotenv.env['WATSON_STT_API_KEY'] ?? '',
        dotenv.env['WATSON_STT_ENDPOINT'] ?? '',
        _model.recordedFilePath,
      );
      if (mounted) setState(() => _model.rspeechText = text);
    }
  }

  Widget _buildUserBubble(String text) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40, maxWidth: 300),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(0),
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIResponse(String txtFileName, {bool animate = false}) {
    final cs = Theme.of(context).colorScheme;
    Widget content = Container(
      width: 287,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 300,
            child: custom_widgets.HtmlWidget3(
              width: double.infinity,
              height: 300,
              txtFileName: txtFileName,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  _model.ragResponseWithoutHtml =
                      await actions.extractTextFromHTMLFile('ragresponse.txt');
                  if (_model.ragResponseWithoutHtml != null) {
                    _model.ttsaudioPath = await actions.textAudio(
                      dotenv.env['WATSON_TTS_API_KEY'] ?? '',
                      dotenv.env['WATSON_TTS_ENDPOINT'] ?? '',
                      _model.ragResponseWithoutHtml!,
                      'speech.mp3',
                    );
                    if (_model.ttsaudioPath != null) {
                      await actions.playMusic(_model.ttsaudioPath!);
                    }
                  }
                  if (mounted) setState(() {});
                },
                icon: const Icon(Icons.volume_up, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: cs.onSurface,
                  foregroundColor: cs.surface,
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () async {
                  await actions.translateHtmlFile(
                      'ragresponse.txt', 'ragtranslate.txt');
                  if (mounted) {
                    context.read<AppState>().update(
                        () => context.read<AppState>().isTranslate = true);
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.translate_rounded, size: 16),
                style: IconButton.styleFrom(
                  backgroundColor: cs.onSurface,
                  foregroundColor: cs.surface,
                  minimumSize: const Size(32, 32),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (animate) {
      content = content
          .animate()
          .shimmer(duration: 1130.ms, color: Theme.of(context).colorScheme.primary);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/Apple-iOS11-Siri-visual-effect-unscreen.gif',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
          child: content,
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/Apple-iOS11-Siri-visual-effect-unscreen.gif',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(delay: (200 * i).ms, duration: 400.ms)
                .then()
                .fadeOut(duration: 400.ms),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final txtFileName =
        appState.isTranslate ? 'ragtranslate.txt' : 'ragresponse.txt';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // App bar row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 30, 12, 12),
                child: Row(
                  children: [
                    IconButton.filled(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: cs.surfaceContainerHighest,
                        foregroundColor: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'संजीवनी',
                      style: tt.bodyMedium?.copyWith(
                        fontFamily: 'KCS',
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              // Chat messages
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (appState.typedMessage.isNotEmpty) ...[
                        _buildUserBubble(appState.typedMessage),
                        if (_isLoading)
                          _buildTypingIndicator()
                        else
                          _buildAIResponse(txtFileName, animate: false),
                      ],
                      if (_model.rspeechText != null &&
                          _model.rspeechText!.isNotEmpty) ...[
                        _buildUserBubble(_model.rspeechText!),
                        if (_isLoading)
                          _buildTypingIndicator()
                        else
                          _buildAIResponse(txtFileName, animate: true),
                      ],
                    ],
                  ),
                ),
              ),
              // Input row
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: TextFormField(
                                        controller: _model.textController,
                                        focusNode: _model.textFieldFocusNode,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        textInputAction: TextInputAction.done,
                                        maxLines: 10,
                                        maxLength: 100,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: 'Ask Sanjeevani...',
                                          hintStyle: tt.labelMedium?.copyWith(
                                            fontFamily:
                                                GoogleFonts.manrope().fontFamily,
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                          filled: true,
                                          fillColor: cs.surfaceContainerHighest,
                                          counterText: '',
                                        ),
                                        style: tt.bodyMedium?.copyWith(
                                          fontFamily:
                                              GoogleFonts.manrope().fontFamily,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: IconButton(
                                        onPressed: _sendText,
                                        icon: Icon(Icons.send_rounded,
                                            color: cs.onSurface, size: 24),
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              cs.surfaceContainerHighest,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Voice button — hold to record
                          GestureDetector(
                            onLongPressStart: (_) => _startRecording(),
                            onLongPressEnd: (_) => _stopRecording(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: appState.isRecording ? 60 : 50,
                              height: appState.isRecording ? 70 : 60,
                              decoration: BoxDecoration(
                                color: appState.isRecording
                                    ? cs.error
                                    : cs.onSurface,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                appState.isRecording ? Icons.mic : Icons.mic,
                                color: cs.surface,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Recording wave overlay
                      if (appState.isRecording)
                        Align(
                          alignment: const Alignment(-1.02, 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              'assets/images/voice_wave_(1).gif',
                              width: 313,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
