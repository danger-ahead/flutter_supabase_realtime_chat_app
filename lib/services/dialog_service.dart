import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noobcode_flutter_chatapp/model/dialog_model.dart';

class DialogService {
  late Completer<DialogResponse>? _dialogCompleter;

  Completer<DialogResponse>? get dialogCompleter => _dialogCompleter;

  void _showInputBottomSheet(DialogRequest request) {
    TextEditingController textEditingController1 = TextEditingController();
    TextEditingController textEditingController2 = TextEditingController();
    final formKey = GlobalKey<FormState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      textEditingController1.text = request.field1Value ?? "";
      textEditingController2.text = request.field2Value ?? "";
      Get.dialog(
        AlertDialog(
          title: Text(request.title),
          content: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: textEditingController1,
                        keyboardType: request.field1KeyboardType,
                        decoration: InputDecoration(
                            prefixText: request.field1Prefix ?? "",
                            labelText: request.field1Description),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            if (request.field1Description != null) {
                              return 'Please ${request.field1Description!.substring(0, 1).toLowerCase()}${request.field1Description!.substring(1)}';
                            } else {
                              return 'Please enter a value';
                            }
                          }
                          if (request.field1Validator != null) {
                            return request.field1Validator!(value);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: textEditingController2,
                        keyboardType: request.field2KeyboardType,
                        decoration: InputDecoration(
                            prefixText: request.field2Prefix ?? "",
                            labelText: request.field2Description),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            if (request.field2Description != null) {
                              return 'Please ${request.field2Description!.substring(0, 1).toLowerCase()}${request.field2Description!.substring(1)}';
                            } else {
                              return 'Please enter a value';
                            }
                          }
                          // accept only numbers, regex
                          if (request.field2Validator != null) {
                            return request.field2Validator!(value);
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  dialogActionComplete(DialogResponse(
                    confirmed: true,
                    value1: textEditingController1.text,
                    value2: textEditingController2.text,
                  ));
                }
              },
              child: Text(request.buttonTitle!),
            ),
          ],
          scrollable: true,
        ),
        barrierDismissible: request.isDismissible!,
      );
    });
  }

  void _showConfirmationDialog(DialogRequest request) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.dialog(AlertDialog(
        title: Text(request.title),
        content: Text(
          request.description ?? "",
          textAlign: TextAlign.justify,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              dialogActionComplete(DialogResponse(confirmed: false));
            },
            child: Text(request.cancelTitle ?? "Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              dialogActionComplete(DialogResponse(confirmed: true));
            },
            child: Text(request.confirmTitle ?? "Proceed"),
          ),
        ],
      ));
    });
  }

  /// shows an input dialog
  Future<DialogResponse> showInputService({
    required String title,
    String? field1Value,
    String? field2Value,
  }) {
    _dialogCompleter = Completer<DialogResponse>();
    _showInputBottomSheet(
      DialogRequest(
        title: title,
        field1Description: "Enter a Username",
        field2Description: "Enter Chat ID",
        field1KeyboardType: TextInputType.text,
        field2KeyboardType: TextInputType.number,
        field1Value: field1Value,
        field2Value: field2Value,
        field1Validator: (string) {
          if (string.length > 20) {
            return 'Username < 20 characters';
          }
          return null;
        },
        field2Validator: (string) {
          if (!RegExp(r'^-?[0-9]+$').hasMatch(string)) {
            return 'Please enter a valid number';
          }
          if (string.length > 10) {
            return 'Chat ID <= 10 digits';
          }
          return null;
        },
        field1Prefix: "@",
        field2Prefix: "#",
        buttonTitle: "Continue",
        isDismissible: false,
      ),
    );
    return _dialogCompleter!.future;
  }

  /// shows a confirmation dialog
  Future<DialogResponse> showConfirmationDialog({
    required String title,
    String? description,
    String? confirmationTitle,
    String? cancelTitle,
  }) {
    _dialogCompleter = Completer<DialogResponse>();
    _showConfirmationDialog(
      DialogRequest(
        title: title,
        description: description,
        buttonTitle: confirmationTitle,
        cancelTitle: cancelTitle,
      ),
    );
    return _dialogCompleter!.future;
  }

  /// Completes the _dialogCompleter to resume the Future's execution call
  void dialogActionComplete(DialogResponse response) {
    Get.key.currentState?.pop();
    _dialogCompleter!.complete(response);
    _dialogCompleter = null;
  }

  void popDialog() {
    if (Get.key.currentState!.canPop()) {
      Get.key.currentState!.pop();
    }
  }
}
