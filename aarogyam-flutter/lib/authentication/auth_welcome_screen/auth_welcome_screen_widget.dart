import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/core/services/vernacular_service.dart';
import '/l10n/l10n.dart';
import 'auth_welcome_screen_model.dart';
export 'auth_welcome_screen_model.dart';

class AuthWelcomeScreenWidget extends StatefulWidget {
  const AuthWelcomeScreenWidget({super.key});

  @override
  State<AuthWelcomeScreenWidget> createState() =>
      _AuthWelcomeScreenWidgetState();
}

class _AuthWelcomeScreenWidgetState extends State<AuthWelcomeScreenWidget> {
  late AuthWelcomeScreenModel _model;

  @override
  void initState() {
    super.initState();
    _model = AuthWelcomeScreenModel();
    _model.init(context);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vernService = Provider.of<VernacularService>(context);
    final l10n = AppLocalizations.of(context);

    final tagline = l10n?.welcomeTagline ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'स्वास्थ्य को आसान बनाएं\nक्योंकि आपको जानने का हक है!'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'आरोग्य सोपे केले\nकारण तुम्ही जाणून घेण्यास पात्र आहात!'
                : 'Health Made Easy\nBecause You Matter'));

    final appName = l10n?.welcomeAppName ??
        (vernService.currentLanguage == AppLanguage.english ? 'aarogyam' : 'आरोग्यम्');

    final subtitle = l10n?.welcomeSubtitle ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'आपका स्वागत है!'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'आपले स्वागत आहे!'
                : 'Welcomes You!'));

    final loginText = l10n?.welcomeLogin ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'लॉगिन करें'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'लॉगिन करा'
                : 'Login'));

    final createAccountText = l10n?.welcomeCreateAccount ??
        (vernService.currentLanguage == AppLanguage.hindi
            ? 'खाता बनाएं'
            : (vernService.currentLanguage == AppLanguage.marathi
                ? 'खाते तयार करा'
                : 'Create an Account'));

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00897B), // teal 600
                Color(0xFF3949AB), // indigo 600
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top bar with language switcher
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<AppLanguage>(
                            value: vernService.currentLanguage,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                            dropdownColor: const Color(0xFF00897B),
                            borderRadius: BorderRadius.circular(16),
                            items: const [
                              DropdownMenuItem(
                                value: AppLanguage.hindi,
                                child: Text('हिंदी', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                              DropdownMenuItem(
                                value: AppLanguage.marathi,
                                child: Text('मराठी', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                              DropdownMenuItem(
                                value: AppLanguage.english,
                                child: Text('English', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
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
                Text(
                  tagline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.3,
                  ),
                ),
                // Logo + name section
                Column(
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(
                        'assets/images/Sanjivani.jpg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      appName,
                      style: TextStyle(
                        fontFamily: vernService.currentLanguage == AppLanguage.english ? 'Samarkan' : 'KCS',
                        fontSize: vernService.currentLanguage == AppLanguage.english ? 40 : 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                // Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 44),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () => context.pushNamed('auth_Login'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF00897B),
                            shape: const StadiumBorder(),
                            elevation: 4,
                          ),
                          child: Text(
                            loginText,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => context.pushNamed('auth_Create'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            createAccountText,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
