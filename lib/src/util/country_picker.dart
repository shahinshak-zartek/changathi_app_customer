import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app/app_text_style.dart';
void gotoCountryPicker(BuildContext context,void Function(Country) onSelect){
  showCountryPicker(
    context:context,
    showPhoneCode: true,
    favorite: ["IN"],
    countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(15),
        bottomSheetHeight: MediaQuery.of(context).size.height*0.6,
        textStyle: AppTextStyle().labelSmall,
        inputDecoration: InputDecoration(
            labelText: "Search",
            hintText: "Search",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color(0xFF8C98A8).withOpacity(0.2),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 3)
        )
    ),
    onSelect: onSelect
  );
}