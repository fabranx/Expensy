import 'package:expensy/entities/expense.dart';
import 'package:expensy/entities/tags.dart';
import 'package:expensy/utils/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:intl/intl.dart';

import '../forms/form_addEdit_Expense.dart';

class ExpensesListPage extends StatelessWidget {
  final IsarService isarService;
  final Stream<List<Expense>> streamExpenses;
  final bool hideTotalAmount;
  const ExpensesListPage({super.key, required this.isarService, required this.streamExpenses, this.hideTotalAmount = false});

  Map<String, double> calculateTotalPerCurrency(List<Expense> expenses) {
    Map<String, double> totals = {};

    for(Expense expense in expenses) {
      if (totals.containsKey(expense.currency)) {
        totals[expense.currency] = (totals[expense.currency]! + expense.amount);
      } else {
        totals[expense.currency] = expense.amount;
      }
    }
    return totals;
  }


  @override
  Widget build(BuildContext context) {
    // debugPrint(hideTotalAmount.toString());
    return StreamBuilder(
      stream: streamExpenses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SpinKitDoubleBounce(
              size: 20,
              color: Colors.blueGrey,
            ),
          );
        } else if (snapshot.hasError) {
          // Text('Error: ${snapshot.error}');
          return Center(
              child: Text(AppLocalizations.of(context)!.genericError));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noData),
          );
        } else {
          final expensesList = snapshot.data;
          final totals = calculateTotalPerCurrency(expensesList!);

          return Padding(
            padding: const EdgeInsets.all(8),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      hideTotalAmount ?
                      const SizedBox(width: 0) :
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 500
                        ),
                        padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
                        clipBehavior: Clip.none,
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withAlpha(60),
                              offset: const Offset(1, 2),
                              blurRadius: 0.5
                            )
                          ]
                        ),
                        // color: Colors.green,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 0),
                          child: Column(
                            children: totals.entries.map((entry) {
                              String currency = entry.key;
                              double total = entry.value;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${AppLocalizations.of(context)!.total} $currency"),
                                  // Text(total.toStringAsFixed(2), style: ,)
                                  Text(NumberFormat.simpleCurrency(
                                      locale: Localizations.localeOf(context).languageCode,
                                      name: currency
                                  ).format(total),
                                      style: const TextStyle(color: Colors.red,fontWeight: FontWeight.w700,fontSize: 18)
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Divider(),
                  ),
                ),

                SliverList(delegate: SliverChildBuilderDelegate((context, expenseIndex) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                            maxWidth: 600
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                          // border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withAlpha(60),
                              offset: const Offset(1, 2),
                              blurRadius: 0.5
                            )
                          ]
                        ),

                        child: ExpansionTile(
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          collapsedBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.secondaryContainer
                            )
                          ),
                          subtitle: Text(
                            expensesList[expenseIndex].description,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              shadows: [
                                Shadow(
                                  blurRadius: 0.1,
                                )
                              ]),
                          ),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          title: Padding(
                            padding: const EdgeInsets.only(top: 0, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        // DateFormat('dd/MM/yyyy').format(expensesList![expenseIndex].date),
                                        DateFormat('dd/MM/yyyy', Localizations.localeOf(context).languageCode).format(expensesList[expenseIndex].date),
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.tertiary,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(expensesList[expenseIndex].paymentAccount.value?.name ?? '',
                                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                                ),
                                Text(
                                  NumberFormat.simpleCurrency(
                                    locale: Localizations.localeOf(context).languageCode,
                                    name: expensesList[expenseIndex].currency).format(expensesList[expenseIndex].amount
                                  ),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22
                                  )
                                ),
                              ],
                            ),
                          ),
                          children: [
                            ListTile(
                              title: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                // padding: EdgeInsets.only(left: 0, bottom: 10, right: 0, top: 10),
                                child: Row(
                                  children: () {
                                    List<Widget> chipsList = [];
                                    for (Tags tag in expensesList[expenseIndex].tags) {
                                      chipsList.add(Padding(
                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                        child: Chip(
                                          label: Text(tag.name),
                                          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                                        ),
                                      ));
                                    }
                                    return chipsList;
                                  }(),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog.fullscreen(
                                            child: SingleChildScrollView(
                                              child: ExpensesForm(
                                                isarService: isarService,
                                                prevExpenses: expensesList[expenseIndex],
                                              ),
                                            ),
                                          );
                                        }
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.mode_edit),
                                          Text(AppLocalizations.of(context)!.editLabel)
                                        ]
                                      )
                                    ),
                                    TextButton(
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text( AppLocalizations.of(context)!.deleteLabel),
                                            content: Text(AppLocalizations.of(context)!.deleteQuestion),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(context),
                                                  child: Text(AppLocalizations.of(context)!.noLabel)
                                              ),
                                              TextButton(
                                                  onPressed: () async {
                                                    bool res = await isarService.deleteExpense(expensesList[expenseIndex].id);
                                                    if (!context.mounted) return;
                                                    if (res) {
                                                      final snackBar = SnackBar(
                                                        content: Text(AppLocalizations.of(context)!.deletedConfirm),
                                                        duration: const Duration(seconds:2),
                                                      );
                                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(AppLocalizations.of(context)!.yesLabel)),
                                            ],
                                          );
                                        },
                                      ),
                                      child: Row(children: [
                                        const Icon(Icons.delete),
                                        Text(AppLocalizations.of(context)!.deleteLabel)
                                      ])
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10)
                    ],
                    );
                  },
                  childCount: expensesList.length
                ))
              ],
            )
          ) ;
        }
      }
    );
  }
}