import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:security/controller/app.dart';

import '../controller/state_controller.dart';

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
                // Text(context.watch<App>().counter.toString()),
                TextButton(
                  onPressed: () {
                    // App.doWork();

                  },
                  child: const Text("Generate File",
                    style: TextStyle(
                        color: Colors.blue
                    ),
                  )
                ),
                TextButton(
                  onPressed: () {
                    App.doWork();
                  },
                  child: Text("Increment ${context.watch<App>().counter}",
                    style: const TextStyle(
                      color: Colors.blue
                    ),
                  )
                ),
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