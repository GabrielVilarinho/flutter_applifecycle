import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:security/lib/utils.dart';

import 'account_test.dart';
import 'authentication_test.dart';
import 'filemanager_test.dart';
import 'network_test.dart';

void main()
{
  FileManagerTest.main();
  AccountTest.main();
  AuthenticationTest.main();
  NetworkTest.main();
  AuthenticationTest.dispose();
}