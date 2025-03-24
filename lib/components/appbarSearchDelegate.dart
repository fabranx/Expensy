import 'dart:async';
import 'package:expensy/components/pages/expenses_list_page.dart';
import 'package:expensy/utils/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../entities/expense.dart';

class AppBarSearchDelegate extends SearchDelegate {
  AppBarSearchDelegate({required this.isarService, this.filterCriteria});
  final IsarService isarService;
  late Stream<List<Expense>> streamExpenses;
  Object? filterCriteria;


  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }


  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query.isEmpty ? close(context, null) : query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if(query.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.searchSomething),);
    }
    else {
      return expensesStreamList();
    }
  }

  // @override
  // void showResults(BuildContext context) {
  // close(context, query);
  // }

  @override
  Widget buildSuggestions(BuildContext context) {
    if(query.isEmpty) {
      return const SizedBox(height: 0, width: 0,);
    }
    else {
      return expensesStreamList();
    }
  }

  // used a function to show ExpensesListPage containing the stream streamExpenses,
  // so as to avoid the error “Bad state: Stream has already been listened to”
  // if I use ExpensesListPage directly in buildSuggestions and buildResults
  Widget expensesStreamList() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          setState(() {
            streamExpenses = isarService.streamSearchExpense(query: query, filterCriteria: filterCriteria);
          });
          return ExpensesListPage(
            isarService: isarService,
            streamExpenses: streamExpenses,
            hideTotal: true,
          );
        }
    );
  }
}


