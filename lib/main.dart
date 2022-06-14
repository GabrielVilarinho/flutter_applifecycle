import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:security/controller/navigation_service.dart';

import 'config.dart';
import 'controller/app.dart';
import 'controller/file_manager.dart';
import 'controller/state_controller.dart';

///It is what it is
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FileManager file = FileManager();
  file.generateStructure();
  ///Initializing App
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<App>(create:(_) => App()
      )
    ],
    child: const SecurityApp(),
  ));
}

class SecurityApp extends StatefulWidget {
  const SecurityApp({Key? key}) : super(key: key);

  @override
  State<SecurityApp> createState() => _SecurityAppState();
}

class _SecurityAppState extends State<SecurityApp> with WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    StateController.updateState(state);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.globalContext,
      initialRoute: Config.initRoute,
      routes: Config.routes,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}

