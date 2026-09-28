import '/auth/firebase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/core/services/vernacular_service.dart';
import '/l10n/l10n.dart';
import 'auth_forgot_password_model.dart';
export 'auth_forgot_password_model.dart';

class AuthForgotPasswordWidget extends StatefulWidget {
  const AuthForgotPasswordWidget({super.key});

  @override
  State<AuthForgotPasswordWidget> createState() =>
      _AuthForgotPasswordWidgetState();
}

class _AuthForgotPasswordWidgetState extends State<AuthForgotPasswordWidget> {
  late AuthForgotPasswordModel _model;

  @override
  void initState() {
    super.initState();
    _model = AuthForgotPasswordModel();
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
    final vernService = Provider.of<VernacularService>(context);
    final l10n = AppLocalizations.of(context);

    final title = l10n?.forgotPasswordTitle ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'पासवर्ड भूल गए'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'पासवर्ड विसरलात'
                : 'Forgot Password'));

    final subtitle = l10n?.forgotPasswordSubtitle ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'हम आपको एक रीसेट लिंक भेजेंगे।'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'आम्ही तुम्हाला रीसेट लिंक पाठवू.'
                : 'We will send you a reset link.'));

    final emailLabel = l10n?.forgotPasswordEmail ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'ईमेल पता'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'ईमेल पत्ता'
                : 'Email Address'));

    final sendLinkText = l10n?.forgotPasswordButton ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'लिंक भेजें'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'लिंक पाठवा'
                : 'Send Link'));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 12),
                        child: IconButton.filled(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                          style: IconButton.styleFrom(
                            backgroundColor: cs.surfaceContainerHighest,
                            foregroundColor: cs.onSurface,
                          ),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 32, 0, 8),
                        child: Text(
                          title,
                          style: tt.displayMedium?.copyWith(
                            fontFamily: GoogleFonts.outfit().fontFamily,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Text(
                          subtitle,
                          style: tt.labelLarge?.copyWith(
                            fontFamily: GoogleFonts.manrope().fontFamily,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      // Email field
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: TextFormField(
                          controller: _model.emailAddressTextController,
                          focusNode: _model.emailAddressFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: emailLabel,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Send Link button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () async {
                      final email =
                          _model.emailAddressTextController?.text ?? '';
                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(vernService.currentLanguage == AppLanguage.english ? 'Email required!' : 'कृपया ईमेल दर्ज करें!')),
                        );
                        return;
                      }
                      await authManager.resetPassword(
                        email: email,
                        context: context,
                      );
                    },
                    style: FilledButton.styleFrom(
                      shape: const StadiumBorder(),
                      elevation: 4,
                    ),
                    child: Text(
                      sendLinkText,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
