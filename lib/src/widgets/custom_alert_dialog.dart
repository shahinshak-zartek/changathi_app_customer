import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app/app_text_style.dart';
import '../app/palette.dart';
import '../app/theme.dart';
import '../app/theme_x.dart';
import '../constants/assets.dart';
import 'package:zartek_core/src/util/navigation_service.dart';
import '../util/ui_helper.dart';
import 'custom_elevated_button.dart';

void showExitAlert(BuildContext context, WidgetRef ref) {
  final dialogConfig = DialogConfig(

    context: context,
    title: 'Exit',
    description: 'Are you sure you want to exit from the app?',
    okTitle: 'Exit',
    cancelTitle: 'Cancel',
    isDestructive: true,
    okPressed: () =>
        SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
    cancelPressed: () => NavigationService.pop(),
  );
  showDialogue(dialogConfig);
}

void showInfoAlert(BuildContext context,
    {String? title,
    String? subTitle,
    String? cancelTitle,
    String? okTitle,
    VoidCallback? okPressed}) {
  final dialogConfig = DialogConfig(
    context: context,
    title: title ?? '',
    description: subTitle ?? '',
    okTitle: okTitle ?? 'Done',
    cancelTitle: cancelTitle,
    isDestructive: true,
    okPressed: okPressed ?? () => NavigationService.pop(),
    cancelPressed: () => NavigationService.pop(),
  );
  showDialogue(dialogConfig);
}

void showLogoutAlert(BuildContext context, WidgetRef ref,{isFromLogin=true}) {
 return showCustomAlertWithButton(context: context,

      title:'Déconnexion',
      content:"Êtes-vous sûr de vouloir vous déconnecter de l'application ?${isFromLogin?"\n\nRemarque: la déconnexion effacera vos informations d'inscription et vous devrez recommencer le processus depuis le début.":""}",
      buttonNegativeLabel: 'Oui',buttonPositiveLabel:'Non',onNegativeButtonPressed:() async {
        // ref.read(profileControllerProvider.notifier).logout();
      },onPositiveButtonPressed:  () => NavigationService.pop(),  );
}

class DialogConfig {
  const DialogConfig({
    required this.context,
    required this.title,
    required this.description,
    required this.okTitle,
    this.cancelTitle,
    required this.okPressed,
    required this.cancelPressed,
    this.isDestructive = false,
  });

  final BuildContext context;
  final String title;
  final String description;
  final String okTitle;
  final String? cancelTitle;
  final bool isDestructive;
  final VoidCallback okPressed;
  final VoidCallback cancelPressed;
}

void showDialogue(DialogConfig config) {
  //final isDark = ref.read(darkAppThemeModeProvider);
  // final textStyle = const TextStyle(color: Palette.fontWhite);
  List<Widget> actionsList = [];

  if (config.cancelTitle != null) {
    actionsList.add(PlatformDialogAction(

      onPressed: config.cancelPressed,
      child: PlatformText(
        config.cancelTitle ?? '',
        style: const TextStyle(color: Palette.fontWhite),
      ),
    ));
  }
  actionsList.add(PlatformDialogAction(
    material: (_, __) => MaterialDialogActionData(),
    cupertino: (_, __) => CupertinoDialogActionData(
      isDestructiveAction: config.isDestructive,
    ),
    onPressed: config.okPressed,
    child: PlatformText(
      config.okTitle,
      style: const TextStyle(color: Palette.fontWhite,),
    ),
  ));

  showPlatformDialog(

    context: config.context,
    builder: (_) => PlatformAlertDialog(

      material: (_, __) =>
          MaterialAlertDialogData(backgroundColor: Palette.primary2,),
      title: Text(config.title, style: AppTextStyle().titleLarge.copyWith(color: Palette.white)),
      content: Text(config.description, style: AppTextStyle().bodyMedium.copyWith(color: Palette.white,fontSize: 13.sp)),
      actions: actionsList,
    ),
  );
}
void  showDeleteAlert({required  VoidCallback deletePressed,required BuildContext context,required bool isLoading,required bool language}){
   showDialog(
    context: context,
     // barrierColor: Colors.black.withOpacity(0.8),
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: AlertDialog(
          backgroundColor: AppColors.transparent,
          content: Container(
            padding: EdgeInsets.symmetric(horizontal:8.sp ,vertical: 20.sp),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xffFF5E5E),
                  Color(0xffFF7756),
                  Color(0xffFF914D),
                ],
              ),
              borderRadius: BorderRadius.circular(15)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Image.asset(
                         // tabIndex == 1 ? Assets.tradingToolsFilled :
                         Assets.appIcon,
                         fit: BoxFit.cover,
                         height: 35.h,
                       ),
                       horizontalSpaceLarge,
                       Text(
                        language?'IS THIS REALLY \nWHAT YOU WANT?' :"EST CE QUE C'EST\nVRAIMENT CE QUE\nTU SOUHAITES ?",
                         textAlign: TextAlign.center,
                         style:
                         context.bodyMedium().copyWith(color: Palette.white),
                       ),
                     ],
                   ),
                  verticalSpaceSmall,
                  CustomElevatedButton(
                    color: Palette.red,

                    isLoading: isLoading,
                    height: 42.h,
                    width: 180.w,
                    label: language?'I WANT TO DELETE MY ACCOUNT':'JE VEUX SUPPRIMER\nMON COMPTE',
                    onPressed: deletePressed,
                  ),
                  verticalSpaceMedium,
                  Text(
                    language?"(IT'S TOO BAD)":"(C'EST TROP DOMMAGE)",
                    textAlign: TextAlign.center,
                    style:
                    context.bodySmall().copyWith(color: Palette.white,fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
void  showCustomAlert({  VoidCallback? onButtonPressed,String? buttonLabel,required BuildContext context,required String title,required String content, bool image=false,bool close=false}){
   showDialog(
     barrierDismissible: false,
    context: context,
     // barrierColor: Colors.black.withOpacity(0.8),
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            contentPadding: EdgeInsets.all(4.sp),

            backgroundColor: AppColors.white,
            content: Container(
              padding: EdgeInsets.symmetric(horizontal:8.sp ,vertical: 20.sp),
              width: getWidth(context: context)*0.95,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(close)
                   Column(
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.end,
                         children: [
                           Padding(
                             padding: const EdgeInsets.all(4.0),
                             child: GestureDetector(
                               onTap: () =>NavigationService.pop() ,
                               child: Container(
                                 padding: EdgeInsets.all(2.sp),
                                 decoration: BoxDecoration(
                                     shape: BoxShape.circle,
                                     boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 0.25),BoxShadow(color: Colors.grey,blurRadius: 0.25)],
                                     gradient: LinearGradient(colors: [
                                       Color(0xff309CEA),
                                       Color(0xff5944EC),
                                     ])
                                 ),
                                 child: Icon(Icons.close,color: Palette.white,size: 16.sp,),
                               ),
                             ),
                           )
                         ],
                       ),
                     ],
                   ),
                  Text(title,style: AppTextStyle().titleMedium,),
                  verticalSpaceSmall,
                  SizedBox(
                    width: getWidth(context: context)*0.93,
                      child: Text(textAlign: TextAlign.center,content,style: AppTextStyle().bodySmall,)),
                  if(image)
                    Column(
                      children: [
                        verticalSpaceSmall,
                        SizedBox(
                          width: getWidth(context: context)*0.5,
                            child: Image.asset(Assets.appIcon,)),
                        verticalSpaceSmall,
                      ],
                    ),
                  if(buttonLabel!=null)


                  Column(
                    children: [
                      verticalSpaceSmall,
                      CustomElevatedButton(
                        height: 42.h,
                        width: 180.w,
                        label: buttonLabel,
                        onPressed: onButtonPressed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
void  showCustomAlertWithButton({  VoidCallback? onPositiveButtonPressed,VoidCallback? onNegativeButtonPressed,String? buttonPositiveLabel,String? buttonNegativeLabel,required BuildContext context,required String title,required String content,bool isRedColored=false}){
   showDialog(
     barrierDismissible: false,
    context: context,
     // barrierColor: Colors.black.withOpacity(0.8),
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(elevation: 10,
            shadowColor: Colors.black,

            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            contentPadding: EdgeInsets.all(4.sp),

            backgroundColor: AppColors.white,
            content: Container(
              padding: EdgeInsets.symmetric(horizontal:8.sp ,vertical: 20.sp),
              width: getWidth(context: context)*0.95,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [

                  Text(textAlign: TextAlign.center,title,style: AppTextStyle().titleMedium,),
                  verticalSpaceSmall,
                  SizedBox(
                    width: getWidth(context: context)*0.93,
                      child: Text(textAlign: TextAlign.center,content,style: AppTextStyle().bodySmall,)),
                  Column(
                    children: [
                      verticalSpaceMedium,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if(buttonPositiveLabel!=null)
                          CustomElevatedButton(
                            color: isRedColored?Color(0xffE66D71):null,
                            labelTextStyle: AppTextStyle().bodyMedium.copyWith(color: Colors.white),
                            label: buttonPositiveLabel,
                            onPressed: onPositiveButtonPressed),
                          verticalSpaceSmall,
                          if(buttonNegativeLabel!=null)
                          CustomElevatedButton(
                            nosShadow: true,

                            color: Colors.white,
                            label: buttonNegativeLabel,
                            labelTextStyle: AppTextStyle().bodyMedium.copyWith(color: Palette.black),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            onPressed: onNegativeButtonPressed),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
