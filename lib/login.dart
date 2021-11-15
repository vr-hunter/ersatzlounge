import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'overview.dart';
import 'help.dart';
import 'vw_api.dart';
import 'about.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _storage = FlutterSecureStorage();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void getCredentials() async
  {
    String u = await _storage.read(key: "username") ?? "";
    String p = await _storage.read(key: "password") ?? "";
    setState(() {
      usernameController.text  = u;
      passwordController.text = p;
    });
  }

  void saveCredentials() async
  {
      await _storage.write(key: "username", value: usernameController.text);
      await _storage.write(key: "password", value: passwordController.text);


  }

  Widget aboutWidget = Text("about");
  setAbout(BuildContext context) async
  {
    Widget aw = await about(context);
    setState(() {
      aboutWidget = aw;
    });
  }

  @override
  initState() {
    super.initState();
    getCredentials();
  }



  @override
  Widget build(BuildContext context) {
    setAbout(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Log In"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("VW ID", style: Theme.of(context).textTheme.headline4,),
            Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: usernameController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'VW ID',
                  hintText: 'Enter valid mail such as abc@xyz.com'
              ),
            ),
          ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter your password'
                ),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  saveCredentials();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => OverviewPage(session: VWConnector(usernameController.text, passwordController.text),)));
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0,40,0,0),
              child: TextButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => HelpPage()));
              },
              child: Text("What is this?")
              ),
            ),

          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Ersatzlounge'),
              ),
              aboutWidget,



            ]
        ),
      ),
    );
  }
}