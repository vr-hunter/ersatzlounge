import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {

  String readme_md = "";

  loadReadme() async {
    String x = await rootBundle.loadString('USAGE.md');
    setState(() {
      readme_md = x;
    });

  }

  @override
  Widget build(BuildContext context) {
    loadReadme();
    return Scaffold(
        appBar: AppBar(
          title: Text('Help'),
        ),
        body: Markdown(
            data: readme_md,
            onTapLink: (text, url, title){
              if(url != null) {
                launch(url);
              }
            },
        )
    );
  }
}