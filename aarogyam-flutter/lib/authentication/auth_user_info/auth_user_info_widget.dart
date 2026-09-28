import '/core/services/vernacular_service.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/user_info/user_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    final vernService = context.watch<VernacularService>();
    final loc = FFLocalizations.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top bar: Back button + Language Switcher
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filled(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHighest,
                          foregroundColor: cs.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<AppLanguage>(
                            value: vernService.currentLanguage,
                            icon: Icon(Icons.arrow_drop_down, color: cs.primary, size: 20),
                            dropdownColor: cs.surface,
                            borderRadius: BorderRadius.circular(16),
                            items: const [
                              DropdownMenuItem(
                                value: AppLanguage.hindi,
                                child: Text('हिंदी', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                              DropdownMenuItem(
                                value: AppLanguage.marathi,
                                child: Text('मराठी', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                              DropdownMenuItem(
                                value: AppLanguage.english,
                                child: Text('English', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ],
                            onChanged: (newLang) {
                              if (newLang != null) {
                                vernService.setLanguage(newLang);
                              }
                            },
                          ),
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
                      loc.getText('authUserInfoSubtitle'),
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

