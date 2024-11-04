import 'package:expensy/components/pages/about_page.dart';
import 'package:expensy/components/pages/chart_page.dart';
import 'package:expensy/components/pages/payment_accounts_page.dart';
import 'package:expensy/components/pages/settings_page.dart';
import 'package:expensy/components/pages/tags_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/isar_service.dart';

class AppDrawer extends StatelessWidget {
  final IsarService isarService;
  const AppDrawer({super.key, required this.isarService});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        addRepaintBoundaries: true,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Image.asset('assets/icon/icon.png', height: 50,)
                ),
                const SizedBox(height: 20,),
                Center(
                  child: Text(AppLocalizations.of(context)!.appTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                )
              ],
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.paymentAccounts),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PaymentAccountsPage(isarService: isarService)
                )
              );
            },
          ),
          ListTile(
            title: const Text("Tags"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TagsPage(isarService: isarService)
                  )
              );
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.chart),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChartPage(isarService: isarService)
                )
              );
              // Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingPage(isarService: isarService)
                )
              );
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.about),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AboutPage()
                  )
              );
            },
          )
        ],
      )
    );
  }
}