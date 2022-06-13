import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextStyle label = const TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
    fontSize: 18
  );
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20)
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 280,
                            child: Column(
                              children: [
                                Text("Login", style: label,),
                                TextFormField(
                                  controller: password,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.security_rounded),
                                    hintText: '*********',
                                    labelText: 'Password',
                                  )
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top:8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/dashboard');
                                    },
                                    child: Text("VALIDATE")
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
