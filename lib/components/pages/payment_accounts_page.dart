import 'package:expensy/components/forms/form_addPayAccount.dart';
import 'package:expensy/components/pages/payment_account_expenses_page.dart';
import 'package:expensy/utils/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PaymentAccountsPage extends StatelessWidget {
  final IsarService isarService;
  const PaymentAccountsPage({super.key, required this.isarService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: isarService.streamPaymentAccount(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final paymentAccounts = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.paymentAccounts),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    itemCount: paymentAccounts?.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 0),
                    itemBuilder: (BuildContext context, int accountIndex) {
                      return Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                "${paymentAccounts?[accountIndex].name}",
                                style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w600)
                              ),
                              contentPadding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 0),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return PaymentAccountExpensesPage(isarService: isarService, paymentAccount: paymentAccounts![accountIndex]);
                                      // return Scaffold(
                                      //   appBar: AppBar(
                                      //     title: Text(paymentAccounts![accountIndex].name),
                                      //   ),
                                      //   body: PaymentAccountExpenses(isarService: isarService, paymentAccount: paymentAccounts![accountIndex],),
                                      // );
                                    }
                                  )
                                );
                              },
                              trailing: PopupMenuButton<String>(
                                onSelected: (String value) {
                                  switch (value) {
                                    case 'Delete':
                                      isarService.deletePaymentAccount(paymentAccounts![accountIndex]);
                                    case 'Edit':
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SimpleDialog(
                                            children: [AddPayAccountForm(isarService: isarService, prevAccount: paymentAccounts![accountIndex],)],
                                          );
                                        }
                                      );
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  PopupMenuItem(
                                    value: 'Edit',
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(AppLocalizations.of(context)!.editLabel),
                                        const Icon(Icons.drive_file_rename_outline)
                                      ],
                                    )
                                  ),
                                  PopupMenuItem(
                                    value: 'Delete',
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(AppLocalizations.of(context)!.deleteLabel),
                                        const Icon(Icons.delete_forever_sharp)
                                      ],
                                    )
                                  ),
                                ],
                              )
                            ),
                            const Divider(height: 0,),
                          ],
                        ),
                      );
                    }
                  ),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
            ),
            // Column(
            //   children: [
            //     ListView.builder(
            //       itemCount: paymentAccounts?.length,
            //       shrinkWrap: true,
            //       scrollDirection: Axis.vertical,
            //       padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 0),
            //       itemBuilder: (BuildContext context, int accountIndex) {
            //         return Padding(
            //           padding: const EdgeInsets.all(0),
            //           child: Column(
            //             children: [
            //               ListTile(
            //                 title: Text(
            //                     "${paymentAccounts?[accountIndex].name}",
            //                     style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w600) ),
            //                 contentPadding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 0),
            //                 onTap: () {
            //                   Navigator.push(
            //                     context,
            //                     MaterialPageRoute(
            //                         builder: (context) {
            //                           return Scaffold(
            //                             appBar: AppBar(
            //                               title: Text(paymentAccounts![accountIndex].name),
            //                             ),
            //                             body: PaymentAccountExpenses(isarService: isarService, paymentAccount: paymentAccounts![accountIndex],),
            //                           );
            //                         }
            //                     )
            //                   );
            //                 },
            //                 trailing: PopupMenuButton<String>(
            //                   onSelected: (String value) {
            //                     switch (value) {
            //                       case 'Delete':
            //                         isarService.deletePaymentAccount(paymentAccounts![accountIndex]);
            //                       case 'Edit':
            //                         showDialog(
            //                           context: context,
            //                           builder: (BuildContext context) {
            //                             return SimpleDialog(
            //                               children: [AddPayAccountForm(isarService: isarService, prevAccount: paymentAccounts![accountIndex],)],
            //                             );
            //                           }
            //                         );
            //                     }
            //                   },
            //                   itemBuilder: (BuildContext context) =>
            //                   <PopupMenuEntry<String>>[
            //                     PopupMenuItem(
            //                       value: 'Edit',
            //                       child: Row(
            //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
            //                         crossAxisAlignment: CrossAxisAlignment.center,
            //                         children: [
            //                           Text(AppLocalizations.of(context)!.editLabel),
            //                           const Icon(Icons.drive_file_rename_outline)
            //                         ],
            //                       )
            //                     ),
            //                     PopupMenuItem(
            //                       value: 'Delete',
            //                       child: Row(
            //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
            //                         crossAxisAlignment: CrossAxisAlignment.center,
            //                         children: [
            //                           Text(AppLocalizations.of(context)!.deleteLabel),
            //                           const Icon(Icons.delete_forever_sharp)
            //                         ],
            //                       )
            //                     ),
            //                   ],
            //                 )
            //               ),
            //               const Divider(height: 0,),
            //             ],
            //           ),
            //         );
            //       }
            //     ),
            //   ],
            // ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      children: [AddPayAccountForm(isarService: isarService)],
                    );
                  }
                );
              },
              child: const Icon(Icons.add),
            ),
          );
        }
      }
    );
  }
}