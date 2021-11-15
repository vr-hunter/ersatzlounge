import 'package:flutter/material.dart';
import 'vw_api.dart';
import 'about.dart';
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
      return;
    }else if(cars!.length == 0){
      setState(() {
        status = Status.error;
        errorMessage = "There are no cars registered with this VW ID.";
      });
      return;
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
    setAbout(context);
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
            aboutWidget,



          ]
        ),
      ),
    );
  }
}
