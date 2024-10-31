
import 'package:flutter/material.dart';
import 'package:expensy/utils/sortTypes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../entities/expense.dart';


class PopUpSortButton extends StatefulWidget {
  const PopUpSortButton({
    super.key,
    required this.setStateCallback,
    required this.getSortedStreamCallback,
  });

  final Function(SortTypes, Stream<List<Expense>>) setStateCallback;
  final Function(SortTypes) getSortedStreamCallback;


  @override
  State<StatefulWidget> createState() => _PopUpSortButtonState();
}

class _PopUpSortButtonState extends State<PopUpSortButton> {
  late SortTypes sortExpenses;
  late Stream<List<Expense>> streamExpenses;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        onSelected: (valueFunction) => valueFunction(),
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          PopupMenuItem(
              value: () {
                widget.setStateCallback(
                  sortExpenses = SortTypes.newest,
                  streamExpenses = widget.getSortedStreamCallback(sortExpenses)
                );
              },
              child: ListTile(
                  title: Text(AppLocalizations.of(context)!.newest),
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FontAwesomeIcons.arrowUpLong, size: 18,),
                      Icon(Icons.date_range),
                    ],
                  )
              )
          ),
          PopupMenuItem(
              value: () {
                widget.setStateCallback(
                    sortExpenses = SortTypes.older,
                    streamExpenses = widget.getSortedStreamCallback(sortExpenses)                );
              },
              child: ListTile(
                title: Text(AppLocalizations.of(context)!.older),
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.arrowDownLong, size: 18,),
                    Icon(Icons.date_range),
                  ],
                ),
              )
          ),
          PopupMenuItem(
              value: () {
                widget.setStateCallback(
                    sortExpenses = SortTypes.highestAmount,
                    streamExpenses = widget.getSortedStreamCallback(sortExpenses)                );
              },
              child: ListTile(
                title: Text(AppLocalizations.of(context)!.highestAmount),
                trailing: const Icon(FontAwesomeIcons.arrowUpWideShort),
              )
          ),
          PopupMenuItem(
              value: () {
                widget.setStateCallback(
                    sortExpenses = SortTypes.lowestAmount,
                    streamExpenses = widget.getSortedStreamCallback(sortExpenses)                );
              },
              child: ListTile(
                title: Text(AppLocalizations.of(context)!.lowestAmount),
                trailing: const Icon(FontAwesomeIcons.arrowDownShortWide),
              )
          ),
        ]
    );
  }
}