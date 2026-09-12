import '/auth/firebase_auth/auth_util.dart';
import '/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                            'Get to my account',
                            style: tt.displayMedium?.copyWith(
                              fontFamily: GoogleFonts.outfit().fontFamily,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Text(
                            'Access your health tools by logging in.',
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
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder(),
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
                              labelText: 'Password',
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
                                'Forgot Password?',
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
                        'Login',
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
