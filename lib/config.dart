import 'package:flutter/material.dart';
import 'package:security/screen/dashboard.dart';
import 'package:security/screen/login.dart';

class Config {
  static String initRoute = '/login';
  static Map <String, WidgetBuilder> routes = {
    '/login' : (context) => const Login(),
    '/dashboard' : (context) => const Dashboard(),
  };
}