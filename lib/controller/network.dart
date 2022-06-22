import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:security/controller/account.dart';
import 'package:security/lib/utils.dart';
import 'package:web3dart/web3dart.dart';
class Network {
  static final Network _self = Network._internal();
  Network._internal();

  factory Network() => _self;

  String url = 'https://api.avax.network/ext/bc/C/rpc';
  String port = '43114';

  static Future<bool> checkConnection({String? url}) async
  {
    Uri uri = Uri.parse(url ?? _self.url);
    int repeat = 3;

    Duration timeoutTimer = const Duration(seconds: 3);
    Future pending = Future.wait(
      List.generate(repeat, (index) =>
        http.get(uri)..timeout(timeoutTimer, onTimeout: () => _self._timeout("checkConnection", timeoutTimer))
      ));
      // ..timeout(timeoutTimer, onTimeout: () => List.generate(repeat, (index) => _self._timeout("checkConnection", timeoutTimer)));
    List<http.Response> results = await pending;
    for (http.Response response in results)
    {
      // Utils.printApprove("Code: ${response.statusCode}");
      if(response.statusCode == 500) {
        return false;
      }
    }
    return true;
  }

  http.Response _timeout(String caller, Duration limit)
  {
    Utils.printError("Error at: Network.$caller: ${limit.inMilliseconds} passed with no returned data");
    return http.Response("", 500);
  }

  ///Requests every account's balance
  static Future<List> getBalance() async
  {
    Map body = {
      "id": "0",
      "jsonrpc": "2.0",
      "method": "eth_getBalance",
      "params": ["", "latest"]
    };

    List<AccountData> accounts = await Account.accounts!.future;
    List<Map> mapRequest = [];

    for(int i = 0; i < accounts.length; i++)
    {
      Map<String, dynamic> instance = Map.from(body);
      instance["id"] = "$i";
      instance["params"] = [accounts[i].address!.hex, "latest"];
      mapRequest.add(instance);
    }

    String response = await get(mapRequest);
    return jsonDecode(response);
  }

  ///Requests the balance of any address
  static Future<Object> getBalanceAny(String address, {int id = 0}) async
  {
    try {EthereumAddress.fromHex(address);} catch (e) {Utils.printWarning(e.toString());}

    Map body = {
      "id": id,
      "jsonrpc": "2.0",
      "method": "eth_getBalance",
      "params": [address, "latest"]
    };

    String response = await get([body]);
    return jsonDecode(response);
  }

  static Future<String> get(body, {String? url, Map<String, String>? headers, String method = "POST"}) async
  {
    headers = headers ?? {"Content-Type": "application/json"};
    Uri uri = Uri.parse(url ?? _self.url);
    http.Response? response;

    if(method.toUpperCase() == "POST") {
      response = await http.post(uri, body: json.encode(body), headers: headers);
    } else if(method.toUpperCase() == "GET") {
      response = await http.get(uri, headers: headers);
    }
    return response!.body;
  }
}