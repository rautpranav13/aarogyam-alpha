import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/core/services/vernacular_service.dart';
import '/l10n/l10n.dart';
import '/theme/app_colors.dart';
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
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top bar with language switcher
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AppLanguage>(
                          value: vernService.currentLanguage,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 20),
                          dropdownColor: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          items: const [
                            DropdownMenuItem(
                              value: AppLanguage.hindi,
                              child: Text('हिंदी', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                            DropdownMenuItem(
                              value: AppLanguage.marathi,
                              child: Text('मराठी', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ),
                            DropdownMenuItem(
                              value: AppLanguage.english,
                              child: Text('English', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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

              // Logo + name section
              Column(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryLight, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/Sanjivani.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    appName,
                    style: TextStyle(
                      fontFamily: vernService.currentLanguage == AppLanguage.english ? 'Samarkan' : 'KCS',
                      fontSize: vernService.currentLanguage == AppLanguage.english ? 42 : 38,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      tagline,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.pushNamed('auth_Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          loginText,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => context.pushNamed('auth_Create'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          createAccountText,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
    );
  }
}

