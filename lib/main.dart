import 'package:flutter/material.dart';
import 'package:security/controller/navigation_service.dart';

import 'controller/state_controller.dart';

void main() {
  StateController();
  runApp(const SecurityApp());
}

class SecurityApp extends StatefulWidget {
  const SecurityApp({Key? key}) : super(key: key);

  @override
  State<SecurityApp> createState() => _SecurityAppState();
}

class _SecurityAppState extends State<SecurityApp> with WidgetsBindingObserver {
  // StateController stateController = StateController();
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
      home: const Dashboard(),
      navigatorKey: NavigationService.globalContext,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin{

  TextStyle boldStyle = const TextStyle(
    fontWeight: FontWeight.bold
  );
  
  List<AppLifecycleState> previousStates = [];

  @override
  void initState() {
    super.initState();
    StateController.appLifeCycle.listen((changedState) {
      setState(() {
        previousStates.add(changedState);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            // flex: 8,
            child: Center(
              child: StreamBuilder<AppLifecycleState>(
                stream: StateController.appLifeCycle,
                builder: (context, snapshot) {
                  if(snapshot.data != null) {
                    AppLifecycleState changedState = snapshot.data!;
                    if(changedState == AppLifecycleState.resumed) {
                      return Text("Received last State \"$changedState\"");
                    }
                  }
                  return Text(
                    "Welcome, please minimize the app!",
                    style: boldStyle,
                  );
                }
              )
            ),
          ),
          Expanded(
            flex: 8,
            child: ListView.builder(
              itemCount: previousStates.length,
              itemBuilder: (BuildContext context, int index)
              {
                return ListTile(
                  leading: Text("#$index", style: boldStyle,),
                  title: Text("${previousStates.reversed.toList()[index]}"),
                );
              }
            )
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed:
                    previousStates.isNotEmpty
                        ? (){
                      setState(() {
                        previousStates.clear();
                      });
                    }
                        : null,
                    child: Text("Clear",
                      style: TextStyle(
                          color: previousStates.isNotEmpty ? Colors.blue : Colors.grey
                      ),
                    )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

