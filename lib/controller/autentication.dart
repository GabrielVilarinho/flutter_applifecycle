import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart';
import 'package:flutter/foundation.dart';
import 'package:security/controller/file_manager.dart';
import 'package:security/controller/phrase_generator.dart';
import 'package:security/controller/account.dart';
import 'package:security/lib/utils.dart';
import 'package:convert/convert.dart';
import 'package:web3dart/credentials.dart';
import 'package:crypto/crypto.dart';

import '../lib/types.dart';

class Authentication
{
  static final _self = Authentication._internal();
  static bool walletExists = false;

  static Completer<bool> init = Completer();
  static const String _root = 'managed';
  static const String _file = 'secret';

  String? _secretPath;

  factory Authentication() => _self;

  Authentication._internal() {
    _init();
  }

  void _init () async {
    Object data = await FileManager.readFile(_root, _file);
    if(data is String)
    {
      walletExists = true;
    }
    init.complete(walletExists);

    Directory documents = await FileManager.documents();
    _secretPath = "${documents.path}/$_root/$_file";
    // if(data is bool && data == false)
    // {}
  }

  static Future<bool> createWallet(String password, Strenght strenght) async
  {
    if(walletExists) {
      return false;
    }
    String mnemonic = PhraseGenerator.generate(strenght);
    Utils.printApprove("Create Wallet Phrase [$password]: $mnemonic");

    AesCrypt aes = AesCrypt()
      ..setPassword(password);

    String enc = await aes.encryptTextToFile(mnemonic, _self._secretPath!, utf16: true);

    Utils.printWarning("Encrypted: $enc");
    if(enc.isEmpty) {
      throw "Error at Authentication.createWallet: Could not save the secret in \"Authentication.createWallet\"";
    }

    Uint8List seed = await compute(mnemonicToSeed, mnemonic);
    BIP32 node = BIP32.fromSeed(seed);

    Random secure = Random.secure();
    BIP32 derived = node.derivePath("m/44'/60'/0'/0/0");

    String accountPrivateKey = hex.encode(derived.privateKey!.toList());

    EthPrivateKey web3Credentials = EthPrivateKey.fromHex(accountPrivateKey);
    Wallet wallet = Wallet.createNew(web3Credentials, password, secure);
    Map entry = {
      "slot": 0,
      "title": "Default Account",
      "derived": 0,
      "data": jsonDecode(wallet.toJson())
    };

    bool didAddAccount = await Account.add(entry);

    if(didAddAccount)
    {
      walletExists = true;
    }
    return didAddAccount;
  }

  static Future<bool> auth(String password) async
  {
    String? secret = await compute(_self._computeValidate, [password, _self._secretPath!]);
    if(secret == null) {
      return false;
    }

    ///Initiate other processes
    ///...
    return true;
  }

  ///Args:
  ///0:<String> password
  ///1:<String> path

  Future<String?> _computeValidate(List args) async
  {
    String? ret;
    try
    {
      AesCrypt aes = AesCrypt()
        ..setPassword(args[0]);
      ret = await aes.decryptTextFromFile(args[1], utf16: true);
      // Utils.printWarning("Decoded: $ret");
    }
    catch(e){ return null; }
    return ret;
  }

  static Future<bool> deriveAccount(String password, int index, {String? title, String? mnemonic}) async
  {
    if(!Authentication.walletExists)
    {
      throw "Error at Authentication.deriveAccount: Trying to derive without an Wallet";
    }
    String? master = await compute(_self._computeValidate,[password, _self._secretPath!]);
    BIP32 node = await compute(_self._computeUnlockMnemonicFromFile, [mnemonic ?? master]);

    Random secure = Random.secure();
    BIP32 derived = node.derivePath("m/44'/60'/0'/0/$index");

    String accountPrivateKey = hex.encode(derived.privateKey!.toList());

    EthPrivateKey web3Credentials = EthPrivateKey.fromHex(accountPrivateKey);
    Wallet wallet = Wallet.createNew(web3Credentials, password, secure);
    Map entry = {
      "slot": index,
      "title": title ?? "Derived $index",
      "derived": index,
      "data": jsonDecode(wallet.toJson())
    };

    bool didAddAccount = await Account.add(entry);

    return didAddAccount;
  }
  
  Future<BIP32> _computeUnlockMnemonicFromFile(List args) async
  {
    String secret = args[0];
    ///Checking if a mnemonic was passed
    if (PhraseGenerator.isValid(secret) == false) {
      throw '''
Error at Authentication -> _computeUnlockMnemonicFromFile: Invalid mnemonic
Details:
String secret = $secret;
int secret.length = ${secret.length}''';
    }
    Uint8List seed = mnemonicToSeed(secret);
    return BIP32.fromSeed(seed);
  }
}