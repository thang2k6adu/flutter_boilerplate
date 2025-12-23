import 'package:flutter/material.dart';
import 'package:jt291_flutter_mobile/shared/widgets/common/svg-icon.dart';
import 'package:jt291_flutter_mobile/core/constants/app_icons.dart';

class NoMatchingResults extends StatelessWidget {
  final String? title;
  final String? message;

  const NoMatchingResults({super.key, this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgIconSimple.asset(AppIcons.searchOff, size: 160),
        Text(
          title ?? 'No matching results',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message ?? 'Sorry, there are no results for your search.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
