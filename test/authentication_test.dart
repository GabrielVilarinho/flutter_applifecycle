import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:security/controller/account.dart';
import 'package:security/controller/autentication.dart';
import 'package:security/controller/file_manager.dart';
import 'package:security/lib/types.dart';
import 'package:security/lib/utils.dart';
import 'package:web3dart/web3dart.dart';

class AuthenticationTest {
  static void main()
  {
    Account();
    Authentication();

    group("Authentication", () {
      Random random = Random.secure();
      ///128bit password
      List<int> byteList = List<int>.generate(32, (index) => random.nextInt(256));
      String password = base64Encode(byteList);
      test("Initialization Completer", () async {
        bool? init = await Authentication.init.future;
        expect(init, isNotNull);
        // Utils.printMark("Authentication.accountExists: ${Authentication.walletExists}");
      });

      test("Creating Wallet if not exists", () async {
        Utils.printWarning("[Password] \"$password\"");
        await Authentication.createWallet(password, Strenght.twelve);
        expect(Authentication.walletExists, true);
      });

      test("Display the account public key", () async {
        List<AccountData> accounts = await Account.accounts!.future;
        // EthereumAddress address = await accounts.first.address;
        EthereumAddress address = accounts.first.address!;
        Utils.printApprove("First account's address: \"${address.hex}\"");
        expect(accounts.length, greaterThan(0));
      });

      test("Unlocking file with password", () async {
        bool didAuth = await Authentication.auth(password);
        expect(didAuth, true);
      });

      test("Deriving account from master mnemonic", () async {
        bool didDerive = await Authentication.deriveAccount(password, 1);
        List<AccountData> accounts = await Account.accounts!.future;
        for(int i = 0; i < accounts.length; i++)
        {
          // EthereumAddress address = await accounts[i].address;
          EthereumAddress address = accounts[i].address!;
          Utils.printApprove("Master | ID #$i Account Address: \"${address.hex}\"");
        }
        expect(didDerive, true);
      });

      test("Deriving account from imported mnemonic", () async {
        bool didDerive = await Authentication.deriveAccount(
          password,
          0,
          title: "Imported from Testing",
          mnemonic: "hat salt toy seed check wise link execute pattern senior eyebrow melody"
        );
        List<AccountData> accounts = await Account.accounts!.future;
        // EthereumAddress address = await accounts.last.address;
        EthereumAddress address = accounts.last.address!;
        Utils.printApprove("Imported | ID #${accounts.length - 1} Account Address ${address.hex}");
        expect(didDerive, true);
      });
    });
  }

  static void dispose() {
    bool removeFiles = true;
    if(removeFiles) {
      test("Undoing created files", () async {
        bool didRemoveSecret = await FileManager.removeFile(AppRootFolder.managed.name, 'secret');
        bool didRemoveAccounts = await FileManager.removeFile(AppRootFolder.json.name, 'accounts.json');
        bool didRemoveAll = didRemoveSecret && didRemoveAccounts ? true : false;
        Utils.printMark("Did remove created files? $didRemoveAll");
        expect(didRemoveAll, true);
      });
    }
  }
}