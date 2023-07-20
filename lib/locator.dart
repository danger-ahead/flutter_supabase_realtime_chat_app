import 'package:get_it/get_it.dart';
import 'package:noobcode_flutter_chatapp/services/dialog_service.dart';
import 'package:noobcode_flutter_chatapp/services/local_storage_service.dart';
import 'package:noobcode_flutter_chatapp/viewmodel/home_viewmodel.dart';

GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerLazySingleton(() => DialogService());
  var localStorageService = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(localStorageService);

  locator.registerFactory(() => HomeViewModel());
}
