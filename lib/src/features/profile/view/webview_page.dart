import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/app_text_style.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import '../../../widgets/gradient_iems.dart';

class WebviewPage extends StatefulWidget {
  final WebViewModel webViewModel;

  const WebviewPage({super.key, required this.webViewModel,});

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => NavigationService.pop(),
          icon: const GradientItems(
            child: Icon(CupertinoIcons.back, color: Colors.white),
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.webViewModel.title,
          style: AppTextStyle().bodyLargeWebViewContent,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Markdown(
          data: widget.webViewModel.url,
          styleSheet: MarkdownStyleSheet(
            p: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 09.h,
              height: 1.5,
            ),
            h1: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            h2: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            h3: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            h4: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            h5: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            h6: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            listBullet: theme.textTheme.bodyMedium,
            textAlign: WrapAlignment.spaceBetween,
            h1Align: WrapAlignment.start,
            h2Align: WrapAlignment.start,
            h3Align: WrapAlignment.start,
            h4Align: WrapAlignment.start,
            h5Align: WrapAlignment.start,
            h6Align: WrapAlignment.start,
            unorderedListAlign: WrapAlignment.start,
            orderedListAlign: WrapAlignment.start,
            blockquoteAlign: WrapAlignment.spaceBetween,
          ),
        ),
      ),
    );
  }
}

class WebViewModel {
  final String url;
  final String title;

  WebViewModel({required this.title, required this.url,});
}