import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<Widget> about(BuildContext context) async
{

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String versionString = packageInfo.version;


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

  return AboutListTile(
    icon: const Icon(Icons.info),
    applicationIcon: Image.asset('assets/icons/android.png', width: 100, height: 100,),
    applicationName: 'Ersatzlounge',
    applicationVersion: versionString,
    applicationLegalese: '\u{a9} 2021 vr-hunter',
    aboutBoxChildren: aboutBoxChildren,
  );
}

