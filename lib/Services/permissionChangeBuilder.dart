import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../Screens/loading.dart';
import 'appLifecycleObserver.dart';

typedef _PermisisonChangeBuilder = Widget Function(
  BuildContext context,
  PermissionStatus status,
);

/// Combines permission checking with background notifiers to maintain the
/// latest state of permissions whether the app is foregrounded or not
class PermisisonChangeBuilder extends StatelessWidget {
  final Permission permission;
  final _PermisisonChangeBuilder builder;

  const PermisisonChangeBuilder({
    required this.permission,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserving(
      builder: (context, stateStream) => StreamBuilder<AppLifecycleState>(
        stream: stateStream,
        builder: (context, snapshot) => FutureBuilder<PermissionStatus>(
          future: Permission.location.status,
          builder: (context, snapshot) =>
              snapshot.hasData ? builder(context, snapshot.data!) : Loading(),
        ),
      ),
    );
  }
}
