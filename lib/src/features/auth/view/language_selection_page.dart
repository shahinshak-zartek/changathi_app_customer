import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/features/auth/controller/language_list_controller.dart';
import 'package:zartek_core/src/features/auth/model/language_model.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import 'package:zartek_core/src/util/alert.dart';
import '../../../app/app_text_style.dart';
import 'package:zartek_core/src/features/auth/controller/login_controller.dart';

import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_iems.dart';
import '../../../widgets/oops_error.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState
    extends ConsumerState<LanguageSelectionPage> {
  LanguageData? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    return Scaffold(

      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading:  GradientItems(
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios,color: Colors.white,),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Back button
             verticalSpaceSmall,
              /// Title
               Center(
                child: Text(
                  strings.t(AppStringKey.chooseYourLanguage),
                  style: AppTextStyle().titleLarge
                ),
              ),
             verticalSpaceMedium,
              /// Language List
              Consumer(builder: (context,ref,child) {
                var res=ref.watch(languageListControllerProvider);
               return  res.when(loading: () => Center(child: CupertinoActivityIndicator(),), success: (languageList) {
               return  ListView.builder(
                 shrinkWrap: true,
                 itemCount: (languageList?.data??[]).length,
                 itemBuilder: (context, index) {
                   // final isSelected = selectedLanguage == languageList?.data?[index];
                   return InkWell(
                     onTap: () {
                       setState(() => selectedLanguage = languageList?.data?[index]);
                     },
                     child: Padding(
                       padding:  EdgeInsets.symmetric(vertical: 2.h),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                               languageList?.data?[index].name??"",
                               style:AppTextStyle().bodyMedium.copyWith(fontSize: 16.sp
                               )
                           ),
                           GradientItems(
                             child: Radio<String>(
                               value: languageList?.data?[index].name??"",
                               groupValue: selectedLanguage?.name??"",
                               onChanged: (value) {
                                 setState(() => selectedLanguage = languageList?.data?[index]);
                               },
                               activeColor: Colors.white,
                             ),
                           ),
                         ],
                       ),
                     ),
                   );
                 },
               );
                }, error: (error) => OopsError(error: error),);
              },),



              verticalSpaceLarge,
              Consumer(
                builder: (context,ref,child) {
                  final state =
                  ref.watch(loginControllerProvider);
                  final isLoading = state is LoginStateLoading;
                  return Center(
                    child: CustomElevatedButton(isLoading: isLoading,
                      onPressed: () {
                      if(selectedLanguage!=null){

                        ref.read(loginControllerProvider.notifier).addUserLanguage(language: selectedLanguage?.code??"");

                      }
                      else{
                        Alert.showToast(strings.t(AppStringKey.selectLanguage));
                      }

                    },
                    label: strings.t(AppStringKey.save),),
                  );
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
