import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart' as wb;
import 'package:workmanager/workmanager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

FlutterSecureStorage? storage;
const simplePeriodicTask = "bitswifiautologin";
const bitsurl = "https://fw.bits-pilani.ac.in:8090/httpclient.html";
const myuser = "MyUserNameBitsWifi";
const mypass = "MyPasswordBitsWifi";
Future<void> chk() async {
  String? myusername = await storage?.read(key: myuser);
  String? mypassword = await storage?.read(key: mypass);
  print("Start1");
  HeadlessInAppWebView m = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(bitsurl)),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          incognito: true,
        ),
      ),
      onWebViewCreated: (InAppWebViewController controller) {
        print("WebviewCreated");
      },
      onLoadStart: (InAppWebViewController controller, Uri? url) {
        print("WebviewLoading");
      },
      onConsoleMessage: ((controller, consoleMessage) {
        print(consoleMessage);
      }),
      onLoadError:
          (InAppWebViewController controller, Uri? url, int x, String error) {
        print(error + " Hello");
      },
      onLoadStop: (InAppWebViewController controller, Uri? url) async {
        print("SiteLoadedSuccesfully");
        await controller.evaluateJavascript(source: """
                      input1 = document.getElementById('username');
                      input2 = document.getElementById('password');
                      input1.setAttribute("value", "${myusername.toString()}");
                      input2.setAttribute("value", "${mypassword.toString()}");
                      input3 = document.getElementById("loginbtn").click();
                      console.log(document.URL);
                      """);
      });
  await m.run();
  await Future.delayed(const Duration(milliseconds: 5000), () {});
  await m.dispose();
}

void callbackDispatcher() async {
  String? myusername = await storage?.read(key: myuser);
  String? mypassword = await storage?.read(key: mypass);
  Workmanager().executeTask((task, inputData) async {
    if (task == simplePeriodicTask) {
      if (myusername != null && mypassword != null) {
        print("This is Working");
        HeadlessInAppWebView m = HeadlessInAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(bitsurl)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                incognito: true,
              ),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              print("WebviewCreated");
            },
            onLoadStart: (InAppWebViewController controller, Uri? url) {
              print("WebviewLoading");
            },
            onConsoleMessage: ((controller, consoleMessage) {
              print(consoleMessage);
            }),
            onLoadError: (InAppWebViewController controller, Uri? url, int x,
                String error) {
              print(error + " Hello");
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) async {
              print("SiteLoadedSuccesfully");
              await controller.evaluateJavascript(source: """
                      input1 = document.getElementById('username');
                      input2 = document.getElementById('password');
                      input1.setAttribute("value", "${myusername.toString()}");
                      input2.setAttribute("value", "${mypassword.toString()}");
                      input3 = document.getElementById("loginbtn").click();
                      console.log(document.URL);
                      """);
            });
        await m.run();
        await Future.delayed(const Duration(milliseconds: 5000), () {});
        await m.dispose();
      }
    }
    // print("Native called background task: $backgroundTask"); //simpleTask will be emitted here.
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  storage = const FlutterSecureStorage();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager().registerPeriodicTask(
    simplePeriodicTask,
    simplePeriodicTask,
    frequency: const Duration(minutes: 15),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool button = false;
  final TextEditingController _myusername = TextEditingController();
  final TextEditingController _mypassword = TextEditingController();

  //

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BITS Wifi Auto Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Please Enter Your BITS Wifi Login Details Below"),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.2,
              child: TextFormField(
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(5), labelText: "Username"),
                controller: _myusername,
                autocorrect: false,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.2,
              child: TextFormField(
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(5), labelText: "Password"),
                controller: _mypassword,
                autocorrect: false,
                obscureText: true,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: button
                    ? null
                    : () async {
                        setState(() {
                          button = true;
                        });
                        await storage?.write(
                            key: myuser, value: _myusername.text);
                        await storage?.write(
                            key: mypass, value: _mypassword.text);
                        setState(() {
                          button = false;
                        });
                      },
                child: Text("Save")),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: button
                    ? null
                    : () async {
                        setState(() {
                          button = true;
                        });
                        print("Start");
                        await chk();
                        setState(() {
                          button = false;
                        });
                      },
                child: Text("Load")),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
