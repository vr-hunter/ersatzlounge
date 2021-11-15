import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'vw_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key, required this.session}) : super(key: key);

  final VWConnector session;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

enum Status {
  loading,
  error,
  done
}



class _OverviewPageState extends State<OverviewPage> {
  List<VWCar>? cars;
  Status status = Status.loading;
  String errorMessage  = "";
  String statusMessage  = "";
  String versionString = "";

  void loadData() async {
    setState(() {
      status = Status.loading;
    });

    try {
      cars = await widget.session.getCars();
    } catch(e) {
      errorMessage = e.toString();
      setState(() {
        status = Status.error;
      });
      return;
    }

    if (cars == null) {
      Navigator.pop(context);
    }

    setState(() {
      status = Status.done;
    });
  }

  statusCallback(String s){
    setState(() {
      statusMessage = s;
    });

  }

  @override
  initState() {
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        versionString = packageInfo.version;
      });
    });

    widget.session.statusCallback = statusCallback;
    loadData();
  }

  List<Widget> contents() {
    if (status == Status.loading) {
      return <Widget>[
        Text(
          "Loading...",
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(statusMessage)
      ];
    }else if (status == Status.error) {
      return <Widget>[
        Text(
          ":'(",
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(errorMessage)
      ];
    }
    else if(status == Status.done){
      List<Widget> widgets = [];

      bool first = true;

      for (VWCar car in cars ?? []) {
        if(!first){
          widgets.add(Divider());
        }
        first = false;
        widgets.add(Text(
          car.nickname,
          style: Theme.of(context).textTheme.headline4,
          textAlign: TextAlign.center,
        ));
        widgets.add(Text("Commissioning ID: ${car.commID}"));
        widgets.add(Text("VIN: ${car.vin}"));

        if(car.hasLoungeData){
          widgets.add(Text("Order status: ${car.orderStatus}"));
          widgets.add(Text("Delivery date type: ${car.deliveryDateType}"));
          widgets.add(Text("Delivery date value: ${car.deliveryDateValue}"));
        } else {
          widgets.add(Text("No lounge data"));
        }

      }
      return widgets;
    }
    return [];
  }

  Widget? actionButton() {
    if (status == Status.loading) {
      return null;
    }
    return FloatingActionButton(
      onPressed: loadData,
      tooltip: 'Reload',
      child: const Icon(Icons.refresh),
    );
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyText2!;
    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: "Ersatzlounge is a tool that queries the VW relations and lounge API. This app is open source under the \"3-Clause\" BSD Licence, check out the source code at:\n"),
            TextSpan(
                style: textStyle.copyWith(color: theme.colorScheme.primary),
                text: 'https://github.com/vr-hunter/ersatzlounge',
                recognizer: TapGestureRecognizer()
                  ..onTap = () { launch('https://github.com/vr-hunter/ersatzlounge');
                  },
            ),
            TextSpan(style: textStyle, text: '.'),
          ],
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text("Car overview"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: contents(),
          ),
        ),
      ),
      floatingActionButton: actionButton(),
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
            ListTile(

              title: const Text('Back to login'),
              leading: const Icon(Icons.arrow_back),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),

              AboutListTile(
                icon: const Icon(Icons.info),
                applicationIcon: const FlutterLogo(),
                applicationName: 'Ersatzlounge',
                applicationVersion: versionString,
                applicationLegalese: '\u{a9} 2021 vr-hunter',
                aboutBoxChildren: aboutBoxChildren,
              ),



          ]
        ),
      ),
    );
  }
}
