import '/widgets/user_info/user_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_user_info_model.dart';
export 'auth_user_info_model.dart';

class AuthUserInfoWidget extends StatefulWidget {
  const AuthUserInfoWidget({super.key});

  @override
  State<AuthUserInfoWidget> createState() => _AuthUserInfoWidgetState();
}

class _AuthUserInfoWidgetState extends State<AuthUserInfoWidget> {
  late AuthUserInfoModel _model;

  @override
  void initState() {
    super.initState();
    _model = AuthUserInfoModel();
    _model.init(context);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 30, 12, 12),
                  child: Row(
                    children: [
                      IconButton.filled(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          foregroundColor: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                // Heading
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Help us personalize your experience',
                      style: tt.bodyLarge?.copyWith(
                        fontFamily: GoogleFonts.raleway().fontFamily,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                // User info form card
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                    color: cs.surfaceContainerHighest,
                    child: const UserInfoWidget(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
