import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

/// Accessible audio playback button conforming to ASD 64dp touch target guidelines.
class AudioButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isPlaying;
  final String? tooltip;
  final double size;

  const AudioButton({
    super.key,
    required this.onPressed,
    this.isPlaying = false,
    this.tooltip,
    this.size = AppConstants.preferredTouchTargetSize,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip ?? 'Play Audio Pronunciation',
      child: Tooltip(
        message: tooltip ?? 'Play Audio',
        child: Material(
          color: isPlaying ? AppColors.primaryLight : AppColors.surface,
          shape: const CircleBorder(
            side: BorderSide(
              color: AppColors.primaryBlue,
              width: 2.0,
            ),
          ),
          elevation: isPlaying ? 2 : 0,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Icon(
                  isPlaying
                      ? Icons.volume_up_rounded
                      : Icons.volume_up_outlined,
                  size: size * 0.52,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
