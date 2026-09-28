import '/auth/firebase_auth/auth_util.dart';
import '/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/core/services/vernacular_service.dart';
import '/l10n/l10n.dart';
import 'auth_login_model.dart';
export 'auth_login_model.dart';

class AuthLoginWidget extends StatefulWidget {
  const AuthLoginWidget({super.key});

  @override
  State<AuthLoginWidget> createState() => _AuthLoginWidgetState();
}

class _AuthLoginWidgetState extends State<AuthLoginWidget> {
  late AuthLoginModel _model;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _model = AuthLoginModel();
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

    final title = l10n?.loginTitle ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'मेरे खाते पर जाएं'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'माझ्या खात्यावर जा'
                : 'Get to my account'));

    final subtitle = l10n?.loginSubtitle ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'लॉग इन करके अपने स्वास्थ्य उपकरणों तक पहुंचें।'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'लॉगिन करून आपल्या आरोग्य साधनांमध्ये प्रवेश करा.'
                : 'Access your health tools by logging in.'));

    final emailLabel = l10n?.loginEmail ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'ईमेल पता'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'ईमेल पत्ता'
                : 'Email Address'));

    final passwordLabel = l10n?.loginPassword ??
        (vernService.currentLanguage == AppLanguage.english ? 'Password' : 'पासवर्ड');

    final forgotPasswordText = l10n?.loginForgotPassword ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'पासवर्ड भूल गए?'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'पासवर्ड विसरलात?'
                : 'Forgot Password?'));

    final loginButtonText = l10n?.loginButton ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'लॉग इन करें'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'लॉगिन करा'
                : 'Login'));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar: Back button + Language Switcher
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 12),
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
                        // Title
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 16, 0, 8),
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
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email required';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                        ),
                        // Password field
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: TextFormField(
                            controller: _model.passwordTextController,
                            focusNode: _model.passwordFocusNode,
                            obscureText: !_model.passwordVisibility,
                            decoration: InputDecoration(
                              labelText: passwordLabel,
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _model.passwordVisibility
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _model.passwordVisibility =
                                      !_model.passwordVisibility,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password required';
                              if (v.length < 6) return 'Min 6 characters';
                              return null;
                            },
                          ),
                        ),
                        // Forgot password
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  context.pushNamed('auth_ForgotPassword'),
                              child: Text(
                                forgotPasswordText,
                                style: tt.titleMedium?.copyWith(
                                  fontFamily: GoogleFonts.outfit().fontFamily,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),
                      ],
                    ),
                  ),
                ),
                // Login button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        GoRouter.of(context).prepareAuthEvent();
                        final user = await authManager.signInWithEmail(
                          context,
                          _model.emailAddressTextController!.text,
                          _model.passwordTextController!.text,
                        );
                        if (user == null) return;
                        if (context.mounted) {
                          context.goNamedAuth('HomePage', context.mounted);
                        }
                      },
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                        elevation: 4,
                      ),
                      child: Text(
                        loginButtonText,
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
      ),
    );
  }
}
