
import 'package:flutter/cupertino.dart';

import '../util/ui_helper.dart';

class CustomLoadingProgress extends StatelessWidget {
  const CustomLoadingProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(),
          horizontalSpaceSmall,
          Text('Loading...')
        ],
      ),
    );
  }
}
