import 'package:flutter/foundation.dart';
import 'package:security/controller/state_controller.dart';
import 'package:security/lib/utils.dart';

import 'file_manager.dart';
import 'operation.dart';

class App extends ChangeNotifier {

  static final _self = App._internal();

  Operation? operation;
  int counter = 0;

  App._internal() {
    Utils.printMark("App Started");
    StateController();
    operation = Operation();

    // operation!.doWork();
  }

  factory App() => _self;

  static void increment()
  {
    _self.counter++;
    _self.notifyListeners();
  }

  static void doWork()
  {
    _self.operation!.doWork();
  }

  static void generateFile()
  {
    _self.operation!.generateFile();
  }
}