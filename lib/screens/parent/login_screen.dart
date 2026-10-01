import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_routes.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../widgets/app_button.dart';
import '../../widgets/large_icon_button.dart';

/// Parent & Educator Portal Login Screen matching Task 6:
/// Provides email/password fields, input validation message area, language switch,
/// and child guest bypass.
class LoginScreen extends StatefulWidget {
  final VoidCallback? onToggleLocale;

  const LoginScreen({
    super.key,
    this.onToggleLocale,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _validationError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(AppLocalizations l10n) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _validationError = l10n.text('email_required');
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _validationError = l10n.text('invalid_email');
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _validationError = l10n.text('password_required');
      });
      return;
    }

    setState(() {
      _validationError = null;
    });

    // Valid mock login -> Navigate to Child Selection
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.parentChildSelection,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceS),
          child: LargeIconButton(
            icon: Icons.arrow_back_rounded,
            size: 44,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(l10n.text('parent_portal')),
        actions: [
          if (widget.onToggleLocale != null)
            IconButton(
              icon: const Icon(Icons.language_rounded, color: AppColors.primaryBlue),
              tooltip: l10n.text('language'),
              onPressed: widget.onToggleLocale,
            ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spaceXL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppDimensions.largeCardBorderRadius,
                  border: Border.all(color: AppColors.borderLight, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon and Title
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.supervisor_account_rounded,
                          size: 36,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    Text(
                      l10n.text('parent_portal'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spaceL),

                    // Inline Validation Message Area
                    if (_validationError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.spaceM),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            const SizedBox(width: AppDimensions.spaceS),
                            Expanded(
                              child: Text(
                                _validationError!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceM),
                    ],

                    // Email Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.text('email'),
                        hintText: 'educator@school.edu',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.text('password'),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceL),
                    // Login Button
                    AppButton(
                      label: l10n.text('login_btn'),
                      onPressed: () => _handleLogin(l10n),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    // Child Guest Button
                    AppButton(
                      label: l10n.text('guest_child_btn'),
                      isOutlined: true,
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.childHome,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
