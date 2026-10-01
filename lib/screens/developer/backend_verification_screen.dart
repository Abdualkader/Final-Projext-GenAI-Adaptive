import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/responsive_layout.dart';
import '../../services/firebase_service.dart';
import '../../widgets/large_icon_button.dart';

/// Preserved Week 2 verification dashboard for Firebase and Cloud Functions connectivity.
class BackendVerificationScreen extends StatefulWidget {
  const BackendVerificationScreen({super.key});

  @override
  State<BackendVerificationScreen> createState() =>
      _BackendVerificationScreenState();
}

class _BackendVerificationScreenState extends State<BackendVerificationScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final Map<String, ServiceCheckResult> _results = {};
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _testing = true;
    });

    final checks = await _firebaseService.runAllDiagnostics();

    if (mounted) {
      setState(() {
        _results.addAll(checks);
        _testing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Backend Verification (Week 2)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
            tooltip: 'Rerun Tests',
            onPressed: _testing ? null : _runTests,
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          child: _testing && _results.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Pinging Firebase Web Services...'),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spaceM),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppDimensions.cardBorderRadius,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue),
                          SizedBox(width: AppDimensions.spaceM),
                          Expanded(
                            child: Text(
                              'Verified for Flutter Web: Firebase Core, Auth, Firestore, Storage, and Cloud Functions.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),
                    ..._results.entries.map((entry) {
                      final item = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.spaceL),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: item.success
                                      ? AppColors.successLight
                                      : const Color(0xFFFEE2E2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.success
                                      ? Icons.check_circle_rounded
                                      : Icons.warning_rounded,
                                  color: item.success
                                      ? AppColors.success
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spaceM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.serviceName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.details,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        ),
      ),
    );
  }
}
