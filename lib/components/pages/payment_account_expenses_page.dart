import 'package:expensy/entities/payment_account.dart';
import 'package:expensy/utils/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../entities/expense.dart';
import '../../utils/sortTypes.dart';
import '../buttons/popUpSortButton.dart';
import '../buttons/searchButton.dart';
import 'expenses_list_page.dart';


class PaymentAccountExpensesPage extends StatefulWidget {
  final IsarService isarService;
  final PaymentAccount paymentAccount;
  const PaymentAccountExpensesPage({super.key, required this.isarService, required this.paymentAccount});

  @override
  State<StatefulWidget> createState() => PaymentAccountExpensesPageState();

}

class PaymentAccountExpensesPageState extends State<PaymentAccountExpensesPage>{
  late DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1).subtract(const Duration(days: 1));
  late Stream<List<Expense>> streamExpenses = widget.isarService.streamExpensesPayAccountDateNewToOld(account: widget.paymentAccount, start: startDate, end: endDate);
  SortTypes sortExpenses = SortTypes.newest;

  Stream<List<Expense>> getSortedPayAccountExpenseStream(SortTypes sort) {
    switch(sort) {
      case SortTypes.newest:
        return widget.isarService.streamExpensesPayAccountDateNewToOld(account: widget.paymentAccount, start: startDate, end: endDate);
      case SortTypes.older:
        return widget.isarService.streamExpensesPayAccountDateOldToNew(account: widget.paymentAccount, start: startDate, end: endDate);
      case SortTypes.highestAmount:
        return widget.isarService.streamExpensesPayAccountPriceHighToLow(account: widget.paymentAccount, start: startDate, end: endDate);
      case SortTypes.lowestAmount:
        return widget.isarService.streamExpensesPayAccountPriceLowToHigh(account: widget.paymentAccount, start: startDate, end: endDate);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paymentAccount.name),
        actions: [
          ButtonBar(
            buttonPadding: const EdgeInsets.all(0),
            alignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              SearchButton(isarService: widget.isarService, filterCriteria: widget.paymentAccount,),
              PopUpSortButton(
                setStateCallback: (SortTypes sort, Stream<List<Expense>> stream) {
                  setState(() {
                    sortExpenses = sort;
                    streamExpenses = stream;
                  });
                },
                getSortedStreamCallback: getSortedPayAccountExpenseStream,
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 6, bottom: 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxHeight: 60,
                  maxWidth: 400
              ),
              child: FormBuilderDateRangePicker(
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                allowClear: true,
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary, ),
                name: 'Range',
                firstDate: DateTime(1950),
                lastDate: DateTime(2200),
                initialValue: DateTimeRange(
                  start: startDate,
                  end: endDate,
                ),
                keyboardType: TextInputType.text,
                locale: Locale(Localizations.localeOf(context).languageCode),
                format: DateFormat('dd/MM/yyyy', Localizations.localeOf(context).languageCode),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 18),
                  labelText: AppLocalizations.of(context)!.dateLabel,
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.date_range),
                ),
                onChanged: (val) {
                  setState(() {
                    if(val?.start != null && val?.end != null) {
                      startDate = val?.start ?? startDate;
                      endDate = val?.end ?? endDate;
                      streamExpenses = getSortedPayAccountExpenseStream(sortExpenses);
                    } else {
                      startDate = DateTime(1950);
                      endDate = DateTime(2200);
                      streamExpenses = getSortedPayAccountExpenseStream(sortExpenses);
                    }
                  });
                },
              ),
            ),

          ),
          Flexible(
            child: ExpensesListPage(
              isarService: widget.isarService,
              streamExpenses: streamExpenses,
            ),
          )
        ],
      ),
    );



    // return Column(
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.only(right: 20, left: 20, top: 6, bottom: 0),
    //       child: ConstrainedBox(
    //         constraints: const BoxConstraints(
    //           maxHeight: 60,
    //           maxWidth: 400
    //         ),
    //         child: FormBuilderDateRangePicker(
    //           textAlign: TextAlign.center,
    //           textAlignVertical: TextAlignVertical.center,
    //           allowClear: true,
    //           style: TextStyle(color: Theme.of(context).colorScheme.tertiary, ),
    //           name: 'Range',
    //           firstDate: DateTime(1950),
    //           lastDate: DateTime(2200),
    //           initialValue: DateTimeRange(
    //             start: startDate,
    //             end: endDate,
    //           ),
    //           keyboardType: TextInputType.text,
    //           locale: Locale(Localizations.localeOf(context).languageCode),
    //           format: DateFormat('dd/MM/yyyy', Localizations.localeOf(context).languageCode),
    //           decoration: InputDecoration(
    //             contentPadding: const EdgeInsets.only(bottom: 18),
    //             labelText: AppLocalizations.of(context)!.dateLabel,
    //             floatingLabelAlignment: FloatingLabelAlignment.center,
    //             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    //             prefixIcon: const Icon(Icons.date_range),
    //           ),
    //           onChanged: (val) {
    //             setState(() {
    //               if(val?.start != null && val?.end != null) {
    //                 startDate = val?.start ?? startDate;
    //                 endDate = val?.end ?? endDate;
    //                 streamExpenses = widget.isarService.streamExpensesPayAccount(account: widget.paymentAccount, start: startDate, end: endDate );
    //               } else {
    //                 streamExpenses = widget.isarService.streamExpensesPayAccount(account: widget.paymentAccount );
    //               }
    //             });
    //           },
    //         ),
    //       ),
    //
    //     ),
    //     Flexible(
    //       child: ExpensesListPage(
    //         isarService: widget.isarService,
    //         streamExpenses: streamExpenses,
    //       ),
    //     )
    //   ],
    // );
  }


}

