// import 'package:firebaseprofiletutorial/repository/auth_repo.dart';
import 'package:get_it/get_it.dart';

import 'Firebase_Repository/auth_repo.dart';
import 'Firebase_Repository/storage_repo.dart';
import 'Services/user_controller.dart';

// This is our global ServiceLocator
final locator = GetIt.instance;

void setupServices() {
  locator.registerSingleton<AuthRepo>(AuthRepo(), signalsReady: true);
  locator.registerSingleton<StorageRepo>(StorageRepo(), signalsReady: true);
  locator.registerSingleton<UserController>(UserController(),
      signalsReady: true);
}
