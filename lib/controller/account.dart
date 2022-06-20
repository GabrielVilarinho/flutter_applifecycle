import 'dart:async';
import 'dart:convert';

import 'package:security/controller/file_manager.dart';
import 'package:security/lib/utils.dart';
import 'package:security/lib/types.dart';

class Account
{
  static final Account _self = Account._internal();

  factory Account() => _self;
  
  static Completer<List> accounts = Completer();
  
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
      accounts.complete([]);
      return;
    }
    Object source = await FileManager.readFile(folder, filename);
    if(source is String)
    {
      accounts.complete(jsonDecode(source));
    }
  }

  static Future<bool> add(Map entry) async {
    // List accounts = await _self.accounts.future;

    if(!validator(entry))
    {
      // throw "Error at Account.add: Malformed param key";
      Utils.printError("Error at Account.add: Malformed param key");
      return false;
    }

    List account = await accounts.future;
    account.add(entry);

    bool didSave = await FileManager.writeString(folder, filename, jsonEncode(account));

    if(!didSave) {
      // throw "Error at Account.add: Could not save the account's data";
      throw "Error at Account.add: Could not save the account's data";
    }
    accounts = Completer()
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

    List account = await accounts.future;

    bool didRemove = account.remove(entry);
    if(!didRemove) {
      throw "Error at Account.remove: Could not find account";
    }

    bool didSave = await FileManager.writeString(folder, filename, jsonEncode(account));

    if(!didSave) {
      throw "Error at Account.remove: Could not save the account's data";
    }
    accounts = Completer()
      ..complete(account);
    return true;
  }
}