import 'dart:async';
import 'dart:convert';

import 'package:security/controller/file_manager.dart';
import 'package:security/lib/utils.dart';
import 'package:security/lib/types.dart';
import 'package:web3dart/web3dart.dart';

class AccountData {
  final Wallet _data;
  final String title;
  final int slot;
  final int derived;
  EthereumAddress? address;
  /// Anywhere in the app you can wait if the information is ready
  ///to be used...
  /// You can also use : doneInserting.future.asStream
  Completer<bool> doneInserting = Completer();
  AccountData(this._data, this.title, this.slot, this.derived) {
    insert(_data);
  }

  void insert(Wallet _data) async
  {
    address = await _data.privateKey.extractAddress();
    ///Some other useful data to know instantly

    ///...code
    ///...code
    ///...code

    ///Finishing the completer in case anywhere is waiting for the data
    ///to be ready

    doneInserting.complete(false);
  }

  // Future<EthereumAddress> get address => _data.privateKey.extractAddress();
}

class Account
{
  static final Account _self = Account._internal();

  factory Account() => _self;
  
  static Completer<List<AccountData>>? accounts;
  static Completer<List<Map>> rawAccounts = Completer();
  
  static const String filename = 'accounts.json';
  static final String folder = AppRootFolder.json.name;
  
  Account._internal() {
    _init();
  }
  
  void _init() async {
    bool exists = await FileManager.fileExists(folder, filename);
    // Utils.printWarning("$folder/$filename: $exists");
    if(!exists)
    {
      await FileManager.writeString(folder, filename, []/*jsonEncode([])*/);
      rawAccounts.complete([]);
      return;
    }
    Object source = await FileManager.readFile(folder, filename);
    if(source is String)
    {
      // rawAccounts = jsonDecode(source);
      rawAccounts = Completer()..complete(jsonDecode(source) as List<Map>);
    }
  }

  static Future<bool> add(Map entry, Wallet? wallet) async {
    // List accounts = await _self.accounts.future;

    if(!validator(entry))
    {
      Utils.printError("Error at Account.add: Malformed param key");
      return false;
    }

    List<Map> account = await rawAccounts.future;
    account.add(entry);

    bool didSave = await FileManager.writeString(folder, filename, jsonEncode(account));

    if(!didSave) {
      throw "Error at Account.add: Could not save the account's data";
    }

    /// Wallet can be null when testing the saving to file, otherwise
    ///is a full imported or created account with credentials
    ///besides that if Account.accounts is null the app has not been
    ///initialized, perhaps an App State could solve that... (please no!)

    if(wallet != null)
    {
      List<AccountData> _accounts = [];
      if(accounts != null)
      {
        _accounts = await accounts!.future;
      }
      _accounts.add(AccountData(wallet, entry["title"], entry["slot"], entry["derived"]));
      accounts = Completer()
        ..complete(_accounts);
    }

    rawAccounts = Completer()
      ..complete(account);
    return true;
  }

  static bool validator(Map entry) {
    List<String> keys = [
      "slot",
      "title",
      "derived",
      "data",
    ];
    int score = 0;
    for(String key in entry.keys)
    {
      if(keys.contains(key))
      {

        score++;
      }
    }
    if(score == (keys.length))
    {
      return true;
    }
    // Utils.printError("Score: $score, Total: ${keys.length}");
    return false;
  }

  static Future<bool> remove(Map entry) async
  {
    bool isValid = validator(entry);
    if(!isValid)
    {
      throw "Error at Account.remove: Invalid keys";
    }

    List<Map> account = await rawAccounts.future;
    bool didRemove = account.remove(entry);
    if(!didRemove) {
      throw "Error at Account.remove: Could not find account";
    }

    bool didSave = await FileManager.writeString(folder, filename, jsonEncode(account));

    if(!didSave) {
      throw "Error at Account.remove: Could not save the account's data";
    }
    // accounts = Completer()
    //   ..complete(account);
    rawAccounts = Completer()
      ..complete(account);
    return true;
  }
}