import 'package:flutter/services.dart';

class DialogRequest {
  DialogRequest({
    required this.title,
    this.confirmTitle,
    this.cancelTitle,
    this.description,
    this.field1Description,
    this.field2Description,
    this.field1Validator,
    this.field2Validator,
    this.buttonTitle,
    this.isDismissible = true,
    this.field1Prefix,
    this.field2Prefix,
    this.field1KeyboardType,
    this.field2KeyboardType,
    this.field1Value,
    this.field2Value,
  });

  final String title;
  final String? field1Description,
      field2Description,
      description,
      cancelTitle,
      confirmTitle;
  final String? field1Prefix,
      field2Prefix,
      buttonTitle,
      field1Value,
      field2Value;
  final TextInputType? field1KeyboardType, field2KeyboardType;
  // validators for both fields
  final String? Function(String)? field1Validator, field2Validator;

  final bool? isDismissible;
}

class DialogResponse {
  DialogResponse({
    required this.confirmed,
    this.value1,
    this.value2,
  });

  final bool confirmed;
  final String? value1, value2;
}
