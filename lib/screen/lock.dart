import 'package:flutter/material.dart';
import 'package:security/screen/widgets/apphint.dart';

import '../lib/utils.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: WillPopScope(
        onWillPop: () async {
          AppHint.show("Please authenticate yourself!");
          return false;
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text("Please Authenticate yourself",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 32
                        )
                      ),
                    )
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      children: const [
                        Text("I the Developer Gabriel Vilarinho really \nvalue the security of your data, please authenticate \nyourself to access the app!"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: const [
                            Text("ACCESS",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, "Dummy data");
                        Utils.printMark("tapped \"ACCESS\"");
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
