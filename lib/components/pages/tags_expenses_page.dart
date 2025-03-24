import 'package:expensy/components/buttons/popUpSortButton.dart';
import 'package:expensy/entities/tags.dart';
import 'package:expensy/utils/isar_service.dart';
import 'package:expensy/utils/sortTypes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../entities/expense.dart';
import '../buttons/searchButton.dart';
import 'expenses_list_page.dart';


class TagsExpensesPage extends StatefulWidget {
  final IsarService isarService;
  final Tags tag;
  const TagsExpensesPage({super.key, required this.isarService, required this.tag});

  @override
  State<StatefulWidget> createState() => TagsExpensesPageState();

}

class TagsExpensesPageState extends State<TagsExpensesPage>{
  late DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1).subtract(const Duration(milliseconds: 1)); // 23:59:59.999 on the last day of the current month
  late Stream<List<Expense>> streamExpenses = widget.isarService.streamExpensesTagDateNewToOld(tag: widget.tag, start: startDate, end: endDate);
  SortTypes sortExpenses = SortTypes.newest;


  Stream<List<Expense>> getSortedTagExpenseStream(SortTypes sort) {
    switch(sort) {
      case SortTypes.newest:
        return widget.isarService.streamExpensesTagDateNewToOld(tag: widget.tag, start: startDate, end: endDate);
      case SortTypes.older:
        return widget.isarService.streamExpensesTagDateOldToNew(tag: widget.tag, start: startDate, end: endDate);
      case SortTypes.highestTransaction:
        return widget.isarService.streamExpensesTagPriceHighToLow(tag: widget.tag, start: startDate, end: endDate);
      case SortTypes.lowestTransaction:
        return widget.isarService.streamExpensesTagPriceLowToHigh(tag: widget.tag, start: startDate, end: endDate);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag.name),
        actions: [
          ButtonBar(
            buttonPadding: const EdgeInsets.all(0),
            alignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              SearchButton(isarService: widget.isarService, filterCriteria: widget.tag,),
              PopUpSortButton(
                setStateCallback: (SortTypes sort, Stream<List<Expense>> stream) {
                  setState(() {
                    sortExpenses = sort;
                    streamExpenses = stream;
                  });
                },
                getSortedStreamCallback: getSortedTagExpenseStream,
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
                      endDate = val?.end != null ? val!.end.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1)) : endDate;
                      streamExpenses = getSortedTagExpenseStream(sortExpenses);
                    } else {
                      startDate = DateTime(1950);
                      endDate = DateTime(2200);
                      streamExpenses = getSortedTagExpenseStream(sortExpenses);
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

  }


}

