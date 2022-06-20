import 'package:flutter_test/flutter_test.dart';
import 'package:security/controller/network.dart';

class NetworkTest {
  static void main() {
    group("Connection Status", () {
      String url = "https://www.google.com";
      test("Testing connection on \"url\"", () async {
        bool connectionOk = await Network.checkConnection(
          url: url
        );
        expect(connectionOk, true);
      });

      test("Requesting balance", () async {
        Network.getBalance();
      });
    });
  }
}