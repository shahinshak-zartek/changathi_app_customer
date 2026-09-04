import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../app/theme_x.dart';
import '../util/ui_helper.dart';

class OopsError extends ConsumerWidget {
  const OopsError(
      {super.key,
      required this.error,
      this.showDefault = true,
      this.onRefresh});

  final String error;
  final bool showDefault;
  final GestureTapCallback? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final environment = ref.watch(environmentProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: availableWidth * 0.7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  verticalSpaceSmall,

                  Text(
                    error,
                    textAlign: TextAlign.center,
                    // style: context.bodyMedium(textColor: Colors.red),
                  ),
                  verticalSpaceMedium,
                  if (onRefresh != null)
                    InkWell(
                      onTap: onRefresh,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: AppColors.orange,
                          ),
                          Text(
                            ' Reload',
                            textAlign: TextAlign.center,
                            style: context.titleMedium(
                              textColor: AppColors.orange,
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
      },
    );
  }
}
