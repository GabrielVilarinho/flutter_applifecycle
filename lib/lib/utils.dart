class Utils {
  static void printOk(String text) {
    print('\x1B[34m$text\x1B[0m');
  }

  static void printWarning(String text) {
    print('\x1B[33m$text\x1B[0m');
  }

  static void printError(String text) {
    print('\x1B[31m$text\x1B[0m');
  }

  static void printApprove(String text)
  {
    print('\x1B[32m$text\x1B[0m');
  }

  static void printMark(String text)
  {
    print('\x1B[36m$text\x1B[0m');
  }
}
