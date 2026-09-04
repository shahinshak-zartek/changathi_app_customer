import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zartek_core/src/core/localization/app_strings.dart';
import '../../../app/app_text_style.dart';
import '../../../util/ui_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/gradient_iems.dart';
import '../../../widgets/oops_error.dart';
import 'package:zartek_core/src/features/auth/controller/language_list_controller.dart';
import 'package:zartek_core/src/features/auth/model/language_model.dart';
import 'package:zartek_core/src/features/profile/controller/profile_controller.dart';

class LanguageEdit extends ConsumerStatefulWidget {
  final LanguageData? currentLanguage;
  const LanguageEdit({super.key,required this.currentLanguage});

  @override
  ConsumerState<LanguageEdit> createState() => _LanguageEditState();
}

class _LanguageEditState extends ConsumerState<LanguageEdit> {
  LanguageData? selectedLanguage;
@override
  void initState() {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    selectedLanguage=widget.currentLanguage;
    if(mounted){
      setState(() {

      });
    }
  },);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    return Scaffold(

      appBar: AppBar(
        surfaceTintColor: Colors.white,
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
                    },);

                }, error: (error) => OopsError(error: error),);

              },),


              verticalSpaceMassive,
              Center(
                child: Consumer(
                  builder: (context,ref,child) {
                    final state =
                    ref.watch(profileControllerProvider);
                    final isLoading = state is ProfileStateLoading;
                    return CustomElevatedButton(
                      isLoading: isLoading,
                      onPressed: selectedLanguage==null?null:() {
                        ref.read(profileControllerProvider.notifier).updateUserLanguage(language: selectedLanguage?.code??"");
                    },
                      label: strings.t(AppStringKey.save),);
                  }
                ),
              )

              /// Continue Button
            ],
          ),
        ),
      ),
    );
  }
}
