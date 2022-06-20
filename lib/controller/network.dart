import 'package:http/http.dart';
import 'package:security/controller/account.dart';
import 'package:security/lib/utils.dart';
import 'package:web3dart/web3dart.dart';
class Network {
  static final Network _self = Network._internal();
  Network._internal();

  factory Network() => _self;

  String url = 'https://www.google.com.br';
  String port = '';

  static Future<bool> checkConnection({String? url}) async
  {
    Uri uri = Uri.parse(url ?? _self.url);
    int repeat = 3;

    Duration timeoutTimer = const Duration(seconds: 3);
    Future pending = Future.wait(
      List.generate(repeat, (index) =>
        get(uri)..timeout(timeoutTimer, onTimeout: () => _self._timeout("checkConnection", timeoutTimer))
      ));
      // ..timeout(timeoutTimer, onTimeout: () => List.generate(repeat, (index) => _self._timeout("checkConnection", timeoutTimer)));
    List<Response> results = await pending;
    for (Response response in results)
    {
      Utils.printApprove("Code: ${response.statusCode}");
      if(response.statusCode == 500) {
        return false;
      }
    }
    return true;
  }

  Response _timeout(String caller, Duration limit)
  {
    Utils.printError("Error at: Network.$caller: ${limit.inMilliseconds} passed with no returned data");
    return Response("", 500);
  }

  static void getBalance() async
  {
    List accounts = await Account.accounts.future;
    for(Map account in accounts)
    {

    }
  }
}