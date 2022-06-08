import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:security/controller/navigation_service.dart';
import 'package:security/lib/utils.dart';
import 'package:crypto/crypto.dart';

import '../screen/lock.dart';

class Session
{
  static final Session _self = Session._internal();

  String key = "";
  DateTime? oldDate;
  factory Session() => _self;

  Session._internal() {
    Utils.printApprove("Sessão Inicializada");
  }

  void inactiveApp()
  {
    oldDate = DateTime.now();
  }

  Future<void> requestCredentials() async {
    BuildContext? context = NavigationService.globalContext.currentContext;
    if(context == null) {
      throw "Error at Session.requestCredentials : Missing context";
    }
    Utils.printWarning("Previous key $key");
    DateTime currentDate = DateTime.now();
    int difference = currentDate.difference(oldDate!).inSeconds;
    Utils.printWarning("difference inSeconds: $difference");
    if(difference > 10)
    {
      String validationData = await Navigator.push(context, MaterialPageRoute(builder: (context) => const LockScreen()));
      key = hash(validationData);
    }

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: const Text("Please Authenticate"),
    //       content: Wrap(
    //         children: const [
    //           Text("Tap ok to authenticate!")
    //         ],
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: (){
    //             Navigator.pop(context);
    //           },
    //           child: const Text("Cancel")
    //         ),
    //         TextButton(
    //           onPressed: (){
    //             key = hash(null);
    //             Navigator.pop(context);
    //           },
    //           child: const Text("Ok")
    //         ),
    //       ],
    //     );
    //   }
    // );
  }

  String hash(String word)
  {
    Random random = Random();
    List<int> bytes = utf8.encode(word + random.nextInt(2555555).toString());
    return sha256.convert(bytes).toString();
  }
}