import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AppLifecycleObserving extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    Stream<AppLifecycleState> stateStream,
  ) builder;

  AppLifecycleObserving({
    required this.builder,
  });

  @override
  _AppLifecycleObservingState createState() => _AppLifecycleObservingState();
}

class _AppLifecycleObservingState extends State<AppLifecycleObserving>
    with WidgetsBindingObserver {
  final _subject = BehaviorSubject<AppLifecycleState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    _subject.add(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _subject.stream);
  }
}
