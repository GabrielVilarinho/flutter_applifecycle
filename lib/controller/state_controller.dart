import 'dart:async';

import 'package:flutter/material.dart';
import 'package:security/lib/utils.dart';

import 'Session.dart';

class StateController {
  static final StateController _stateController = StateController._internal();

  factory StateController() => _stateController;

  StreamController<AppLifecycleState> cycleStreamController = StreamController.broadcast();

  static Stream<AppLifecycleState> get appLifeCycle => _stateController.cycleStreamController.stream;

  Session session = Session();

  StateController._internal()  {
    Utils.printApprove("StateController Initialized");
  }

  static void updateState(AppLifecycleState state) {
    Utils.printMark("Received updateState $state");
    if(state == AppLifecycleState.inactive)
      _stateController.session.inactiveApp();
    if(state == AppLifecycleState.resumed)
    {
      _stateController.session.requestCredentials();
    }
    _stateController.cycleStreamController.add(state);
  }
}