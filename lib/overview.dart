import 'package:flutter/material.dart';
import 'vw_api.dart';

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
      for (VWCar car in cars ?? []) {
        widgets.add(Text(
          car.nickname,
          style: Theme.of(context).textTheme.headline4,
        ));
        widgets.add(Text("Commissioning ID: ${car.commID}"));
        widgets.add(Text("VIN: ${car.vin}"));
        widgets.add(Text("Order status: ${car.orderStatus}"));
        widgets.add(Text("Delivery date type: ${car.deliveryDateType}"));
        widgets.add(Text("Delivery date value: ${car.deliveryDateValue}"));
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
                text: "Ersatzlounge is a tool that queries the VW relations and lounge API."),
            TextSpan(
                style: textStyle.copyWith(color: theme.colorScheme.primary),
                text: 'https://github.com/vrhunter'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: contents(),
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
                applicationVersion: '1.0',
                applicationLegalese: '\u{a9} 2021 vr-hunter',
                aboutBoxChildren: aboutBoxChildren,
              ),



          ]
        ),
      ),
    );
  }
}