import 'dart:io';
import 'package:expensy/utils/currencies.dart';
import 'package:expensy/utils/excelDataHandler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../entities/expense.dart';
import '../../utils/isar_service.dart';
import '../buttons/switchThemeButton.dart';

class SettingPage extends StatelessWidget {
  final IsarService isarService;
  const SettingPage({super.key, required this.isarService});

  Future<String?> getDefaultCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('currency');
  }

  Future<void> saveDefaultCurrency(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text( AppLocalizations.of(context)!.changeTheme, style: const TextStyle(fontSize: 18)),
                  const Row(
                    children: [
                      Icon(
                        Icons.light_mode_outlined,
                        size: 15,
                      ),
                      SwitchThemeButton(),
                      Icon(
                        Icons.dark_mode_outlined,
                        size: 15,
                      )
                    ],
                  )
                ],
              ),
              const Divider(),
              FutureBuilder(
                future: getDefaultCurrency(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.done) {
                    final defaultCurrency = snapshot.data;
                    return  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          // flex: 2,
                          child: Text(AppLocalizations.of(context)!.defaultCurrencyLabel, style: const TextStyle(fontSize: 18)),
                        ),
                        SizedBox(
                          width: 80,
                          child: FormBuilderDropdown(
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.currencyLabel,
                                border: InputBorder.none
                            ),
                            initialValue: defaultCurrency,
                            onChanged: (value) {
                              if(value != null) {
                                saveDefaultCurrency(value);
                              }
                            },
                            name: 'DefaultCurrency',
                            items: currenciesList.map((currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency, textAlign: TextAlign.end,),
                            )).toList()
                          )
                        )
                      ],
                    );
                  }
                  else if(snapshot.hasError) {
                    return const Text("Error");
                  }
                  else{
                    return const SizedBox(
                      height: 56,
                      child: SpinKitDoubleBounce(
                        color: Colors.blueGrey,
                        size: 20,
                      ),
                    );
                  }
                }
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.backupData,
                        style: const TextStyle(fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 70,
                      height: 42,
                      child: IconButton.filled(
                        onPressed: () async {
                          String? path = await FilePicker.platform.getDirectoryPath();
                          // var status = await Permission.storage.request();
                          var status = await Permission.manageExternalStorage.request();

                          if (status.isGranted) {
                            if (path != null) {
                              bool result = await isarService.exportDB(path);

                              if(!context.mounted) return;

                              if(result) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.fileSavedSnackBar), backgroundColor: Colors.green,)
                                );
                              }
                              else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(AppLocalizations.of(context)!.errorSnackBar), backgroundColor: Colors.red,)
                                );
                              }
                            }
                          }
                        },
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.file_download_outlined,),
                        iconSize: 34,
                      ),
                    )
                  ),
                ],
              ),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.exportExcel,
                        style: const TextStyle(fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 70,
                      height: 42,
                      child: IconButton.filled(
                        iconSize: 20,
                        onPressed: () async {
                          String? path = await FilePicker.platform.getDirectoryPath();
                          // var status = await Permission.storage.request();
                          var status = await Permission.manageExternalStorage.request();
                          if (status.isGranted && path != null) {
                            // isarService.exportDB(path);
                            List<Expense> expenses = await isarService.getExpenses();
                            bool result = exportToExcel(expenses, path);

                            if(!context.mounted) return;

                            if(result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.fileSavedSnackBar), backgroundColor: Colors.green,)
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocalizations.of(context)!.errorSnackBar), backgroundColor: Colors.red,)
                              );
                            }
                          }
                        },
                        icon: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.arrowRight,),
                            SizedBox(width: 2,),
                            FaIcon(FontAwesomeIcons.fileExcel, color: Colors.green, size: 25,),
                          ],
                        ) ,
                      ),
                    )


                  )
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.restoreData, style: const TextStyle(fontSize: 18)),
                        Text(AppLocalizations.of(context)!.restoreDataNote, style: const TextStyle(fontSize: 9),),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 70,
                      height: 42,
                      child: IconButton.filled(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if(result == null) {
                            return ;
                          }
                          else if (result.files.single.name.endsWith('.isar')) {
                            File file = File(result.files.single.path!);
                            isarService.importDb(file).then((_) {
                              Restart.restartApp();
                            });

                          } else {
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.invalidFile),
                                    content: Text(AppLocalizations.of(context)!.invalidFileNote),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(AppLocalizations.of(context)!.close))
                                    ],
                                  );
                                }
                              );
                            }
                          }
                        },
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.file_upload_outlined),
                        iconSize: 34,
                      ),
                    )
                  ),
                ],
              ),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.importFromExcel, style: const TextStyle(fontSize: 18)),
                        Text(AppLocalizations.of(context)!.importFromExcelNote, style: const TextStyle(fontSize: 9),),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 70,
                      height: 42,
                      child: IconButton.filled(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(allowedExtensions: ['xls', 'xlsx'], type: FileType.custom);
                          if(result == null) {
                            return ;
                          }
                          else if (result.files.single.name.endsWith('.xls') || result.files.single.name.endsWith('.xlsx')) {
                            File file = File(result.files.single.path!);
                            if(!context.mounted) return;

                            var (state, message) = await importFromExcel(file, context, isarService);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message!), backgroundColor: state ? Colors.green : Colors.red,)
                            );
                          } else {
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(AppLocalizations.of(context)!.invalidFile),
                                    content: Text(AppLocalizations.of(context)!.invalidFileNote),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(AppLocalizations.of(context)!.close))
                                    ],
                                  );
                                }
                              );
                            }
                          }
                        },
                        iconSize: 20,
                        icon: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.arrowLeft,),
                            SizedBox(width: 5,),
                            FaIcon(FontAwesomeIcons.fileExcel, color: Colors.green, size: 25,),
                          ],
                        )
                      )
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text( AppLocalizations.of(context)!.deleteAllExpenses,
                        style: const TextStyle(fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 70,
                      height: 42,
                      child: IconButton.filled(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(AppLocalizations.of(context)!.warning),
                              content: Text(AppLocalizations.of(context)!.deleteAllExpensesQuestion),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      isarService.deleteDb().then((_) {
                                        Restart.restartApp();
                                      });
                                    },
                                    child: Text(AppLocalizations.of(context)!.yesLabel)
                                ),
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(AppLocalizations.of(context)!.noLabel)
                                )
                              ],
                            )
                          );
                        },
                        icon: const Icon(Icons.delete_forever_outlined, color: Colors.red,),
                        iconSize: 30,
                        padding: EdgeInsets.zero,
                      ),
                    )

                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      )
    );
  }
}
