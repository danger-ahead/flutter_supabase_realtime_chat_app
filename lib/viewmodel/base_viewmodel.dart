import 'package:flutter/foundation.dart';
import 'package:noobcode_flutter_chatapp/enums/view_state.dart';

class BaseModel extends ChangeNotifier {
  final Map<String, ViewState> _viewStates = <String, ViewState>{};
  final Map<String, String> _errorMessages = <String, String>{};

  ViewState stateFor(String key) => _viewStates[key] ?? ViewState.idle;

  void setStateFor(String key, ViewState viewState) {
    _viewStates[key] = viewState;
    notifyListeners();
  }

  String errorMessageFor(String key) => _errorMessages[key] ?? '';

  void setErrorMessageFor(String key, String error) {
    _errorMessages[key] = error;
    notifyListeners();
  }

  bool isIdle(String key) => _viewStates[key] == ViewState.idle;

  bool isBusy(String key) => _viewStates[key] == ViewState.busy;

  bool isError(String key) => _viewStates[key] == ViewState.error;

  bool isUpdate(String key) => _viewStates[key] == ViewState.update;

  bool isSuccess(String? key) {
    if (key == null) return false;
    return _viewStates[key] == ViewState.success;
  }
}
