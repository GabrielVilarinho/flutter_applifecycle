import 'package:security/lib/utils.dart';

import 'app.dart';

class Operation {
  void doWork()
  {
    Utils.printWarning("Executed doWork");
    App.increment();
  }

  void generateFile()
  {
    String password = "abacaxi";

  }
}