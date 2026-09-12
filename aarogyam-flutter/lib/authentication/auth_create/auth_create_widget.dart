import '/auth/firebase_auth/auth_util.dart';
import '/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_create_model.dart';
export 'auth_create_model.dart';

class AuthCreateWidget extends StatefulWidget {
  const AuthCreateWidget({super.key});

  @override
  State<AuthCreateWidget> createState() => _AuthCreateWidgetState();
}

class _AuthCreateWidgetState extends State<AuthCreateWidget> {
  late AuthCreateModel _model;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _model = AuthCreateModel();
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
                            'Welcome to Aarogyam!',
                            style: tt.displayMedium?.copyWith(
                              fontFamily: GoogleFonts.outfit().fontFamily,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Text(
                            'Your health, your responsibility. Let\'s get started!',
                            style: tt.labelLarge?.copyWith(
                              fontFamily: GoogleFonts.manrope().fontFamily,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        // Display name
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: TextFormField(
                            controller: _model.displayNameTextController,
                            focusNode: _model.displayNameFocusNode,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Display Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Name required';
                              return null;
                            },
                          ),
                        ),
                        // Email
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
                        // Password
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
                        const SizedBox(height: 44),
                      ],
                    ),
                  ),
                ),
                // Create Account button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        GoRouter.of(context).prepareAuthEvent();
                        final user = await authManager.createAccountWithEmail(
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
                        'Create Account',
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
