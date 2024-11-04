import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutPage extends StatelessWidget {
  const AboutPage({super.key});


  Future<String?> getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.about),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('assets/icon/icon.png', height: 60,)
            ),
            const SizedBox(height: 20),
            Center(
             child: Text(
               AppLocalizations.of(context)!.appTitle,
               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
             ),
            ),
            const SizedBox(height: 10),
            FutureBuilder(
                future: getVersion(),
                builder:(context, snapshot) {
                  if(snapshot.hasData) {
                    return Text("${AppLocalizations.of(context)!.appVersion}${snapshot.data}");
                  } else if (snapshot.hasError) {
                    return Text(AppLocalizations.of(context)!.genericError);
                  } else  {
                    return const SpinKitDoubleBounce(
                      color: Colors.blueGrey,
                      size: 20,
                    );
                  }
                }
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.descriptionLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text( AppLocalizations.of(context)!.aboutAppDescription),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.developedBy,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Fabranx'),
            const SizedBox(height: 20),
            const Text(
              'Link',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: () async {
                  final Uri url = Uri.parse('https://github.com/fabranx/Expensy');
                  if(!await launchUrl(url)) {
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.genericError), backgroundColor: Colors.red,)
                      );
                    }
                  }
                },
              // onPressed: _launchUrl,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('GitHub'),
                    SizedBox(width: 10,),
                    FaIcon(FontAwesomeIcons.github)
                  ],
                )
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Privacy Policy'),
                      content: SingleChildScrollView(
                        child: Text(AppLocalizations.of(context)!.privacyPolicy),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}
