import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.size = 40,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.goldPrimary : AppColors.goldPrimaryLight,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}