import 'package:flutter/material.dart';

import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:rabbit_flutter/src/data/api/ApiKeyGoogle.dart';

class GooglePlacesAutoComplete extends StatelessWidget {

 TextEditingController controller;
  String hintText;
  Function(Prediction prediction) onPlaceSelected;

  GooglePlacesAutoComplete(this.controller, this.hintText, this.onPlaceSelected);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: controller,
        boxDecoration: const BoxDecoration(
          color: Colors.white,
        ),
        inputDecoration: InputDecoration(
          hintText: hintText,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          hintStyle: const TextStyle(fontSize: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        debounceTime: 400,
        countries: const ["ve"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: onPlaceSelected,
        itemClick: (Prediction prediction) {
          controller.text = prediction.description ?? "";
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description?.length ?? 0));
        },
        seperatedBuilder: const Divider(height: 1),
        containerHorizontalPadding: 0,
        googleAPIKey: API_KEY_GOOGLE,
        itemBuilder: (context, index, Prediction prediction) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prediction.description ?? "",
                    style: const TextStyle(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
        isCrossBtnShown: true,
      ),
    );
  }

  
}