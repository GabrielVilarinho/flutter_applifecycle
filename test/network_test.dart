import 'package:flutter_test/flutter_test.dart';
import 'package:security/controller/account.dart';
import 'package:security/controller/network.dart';
import 'package:security/lib/utils.dart';
import 'package:web3dart/web3dart.dart';

class NetworkTest {
  static void main() {
    group("Network Requests", () {

      String url = "https://www.google.com";
      List? response;

      test("Testing connection on \"url\"", () async {
        bool connectionOk = await Network.checkConnection(
          url: url
        );
        expect(connectionOk, true);
      });

      test("Request Balance from Faucet", () async {
        response = await Network.getBalance();
        expect(response!.length, greaterThan(0));
      });

      test("Converting to readable", () async {

        /// Request manually by public address
        /// 0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7
        String public = "0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7";
        List data =
          await Network.getBalanceAny(public, id: response!.length) as List;
        Utils.printWarning(data.toString());
        List _response = List.from(response!)
          ..add(data.first);
        Utils.printWarning(_response.toString());

        ///Relation of gathered data:

        List<AccountData> accounts = await Account.accounts!.future;
        Map<String, String> accountBalance = {};
        int i = 0;
        for(Map balance in _response)
        {
          if(balance["id"] != 3)
          {
            accountBalance[accounts[i].address!.hex] = Utils.decimalToReadable(balance["result"]);
          }
          else
          {
            accountBalance[public] = Utils.decimalToReadable(balance["result"]);
          }
          i++;
        }
        Utils.printApprove("$accountBalance");
      });
    });
  }
}