import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:aes_crypt/aes_crypt.dart';
import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart';
import 'package:flutter/foundation.dart';
import 'package:security/controller/file_manager.dart';
import 'package:security/controller/phrase_generator.dart';
import 'package:security/controller/account.dart';
import 'package:security/lib/utils.dart';
import 'package:convert/convert.dart';
import 'package:web3dart/credentials.dart';

class Authentication
{
  static final _self = Authentication._internal();
  static String? _words;
  static bool accountExists = false;

  factory Authentication() => _self;

  Authentication._internal() {
    _init();
  }

  void _init () async {
    Object data = await FileManager.readFile('managed', 'secret');
    if(data is String)
    {
      _words = data;
      accountExists = true;
    }
    // if(data is bool && data == false)
    // {}
  }

  static Future<bool> createWallet(String password) async
  {
    if(accountExists) {
      return false;
    }
    String mnemonic = PhraseGenerator.generate(Strenght.twentyFour);
    Utils.printApprove("Create Wallet Phrase: $mnemonic");

    AesCrypt aes = AesCrypt();
    List<int> bytePass = utf8.encode(password);
    aes.setPassword(password);
    Uint8List data = aes.aesEncrypt(Uint8List.fromList(bytePass));

    bool didSave = await FileManager.writeString('managed', 'secret', data);

    if(!didSave) {
      throw "Error at Authentication.createWallet: Could not save the secret in \"Authentication.createWallet\"";
    }

    Uint8List seed = await compute(mnemonicToSeed, mnemonic);
    BIP32 node = BIP32.fromSeed(seed);

    Random secure = Random.secure();
    BIP32 derived = node.derivePath("m/44'/60'/0'/0/0");

    //TODO: This may cause a bug
    String accountPrivateKey = hex.encode(derived.privateKey!.toList());

    EthPrivateKey web3Credentials = EthPrivateKey.fromHex(accountPrivateKey);
    Wallet wallet = Wallet.createNew(web3Credentials, password, secure);
    Map entry = {
      "slot": 0,
      "title": "Default Account",
      "derived": 0,
      "data": jsonDecode(wallet.toJson())
    };
    Account.add(entry);
    return true;
  }

  static bool createAccount(String password)
  {
    if(_words != null)
      ///Generate account by using node position
      String mnemonic = PhraseGenerator.generate(Strenght.twentyFour);
    return true;
  }
}