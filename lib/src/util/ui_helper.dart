import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../app/theme.dart';

 Widget horizontalSpaceTiny = SizedBox(width: 5.0.w);
 Widget horizontalSpaceSmall = SizedBox(width: 10.0.w);
 Widget horizontalSpaceSX = SizedBox(width: 15.0.w);
 Widget horizontalSpaceMedium = SizedBox(width: 18.0.w);
 Widget horizontalSpaceLarge = SizedBox(width: 18.0.w);
 Widget horizontalSpaceExtraLarge = SizedBox(width: 50.0.w);

 Widget verticalSpaceTinyS = SizedBox(height: 2.0.h);
 Widget verticalSpaceTiny = SizedBox(height: 5.0.h);
 Widget verticalSpaceSmall = SizedBox(height: 10.0.h);
 Widget verticalSpaceSX = SizedBox(height: 15.0.h);
 Widget verticalSpaceMedium = SizedBox(height: 25.0.h);
 Widget verticalSpaceLarge = SizedBox(height: 50.0.h);
 Widget verticalSpaceMassive = SizedBox(height: 120.0.h);

///
const Widget horizontalDivider = Divider(
  color: AppColors.gray1,
  thickness: 1,
);
const Widget verticalDivider = VerticalDivider(
  color: AppColors.gray3,
  thickness: 1,
);

///
double getHeight({@required context}) => MediaQuery.of(context).size.height;

double getWidth({@required context}) => MediaQuery.of(context).size.width;
