import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:security/controller/account.dart';
import 'package:security/controller/network.dart';
import 'package:security/lib/utils.dart';

class NetworkTest {
  static void main() {
    group("Network Requests", () {

      String url = "https://www.google.com";
      List decimalHexResponse = [];
      Map<String, String> decimalToReadable = {};

      test("Testing connection on \"url\"", () async {
        bool connectionOk = await Network.checkConnection(
          url: url
        );
        expect(connectionOk, true);
      });

      test("Request Balance from Faucet", () async {
        decimalHexResponse = await Network.getBalance();
        expect(decimalHexResponse.length, greaterThan(0));
      });

      test("Converting to readable", () async {

        /// Request manually by public address
        /// 0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7
        String public = "0xb31f66aa3c1e785363f0875a1b74e27b85fd66c7";
        List data =
          await Network.getBalanceAny(public, id: decimalHexResponse.length) as List;
        Utils.printWarning(data.toString());
        List _response = List.from(decimalHexResponse)
          ..add(data.first);
        Utils.printWarning(_response.toString());

        ///Relation of gathered data:

        List<AccountData> accounts = await Account.accounts!.future;
        int i = 0;
        for(Map balance in _response)
        {
          if(balance["id"] != 3)
          {
            decimalToReadable[accounts[i].address!.hex] = Utils.decimalToReadable(balance["result"]);
          }
          else
          {
            decimalToReadable[public] = Utils.decimalToReadable(balance["result"]);
          }
          i++;
        }
        Utils.printApprove("$decimalToReadable");
      });
      
      test("Test balance and conversion token to USD", () async {
        double value = await Network.getPrice();
        Utils.printWarning("Platform token value: $value");
        List keys = decimalToReadable.keys.toList();
        List kValue = decimalToReadable.values.toList();

        for(int i = 0; i < decimalToReadable.length; i++)
        {
          Decimal tokenQtd = Decimal.parse(kValue[i]);
          Decimal decimalValue = Decimal.parse(value.toStringAsFixed(6));
          Decimal usdValue = tokenQtd * decimalValue;
          Utils.printMark("${keys[i]}: Platform Token: ${kValue[i]} | \$: ${usdValue.toDouble().toStringAsFixed(2)}");
        }

        expect(value, greaterThan(0));
      });

      test("Platform History 30 day history", () async {
        List<Map> date = await Network.getPlatformHistory();
        expect(date.length, greaterThan(0));
        // for(Map day in date)
        // {
        //   Utils.printMark("$day");
        // }
      });

      test("Contract Address 30 day history", () async {

        List<Map> date = await Network.getTokenHistory("0x1ecd47ff4d9598f89721a2866bfeb99505a413ed");
        expect(date.length, greaterThan(0));
        // for(Map day in date)
        // {
        //   Utils.printMark("$day");
        // }
      });
    });
  }
}