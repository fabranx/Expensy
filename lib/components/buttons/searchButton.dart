import 'package:expensy/utils/isar_service.dart';
import 'package:flutter/material.dart';

import '../appbarSearchDelegate.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key, required this.isarService, this.filterCriteria});
  final IsarService isarService;
  final Object? filterCriteria;  // Tags or PaymentAccount type

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => showSearch(
            context: context,
            delegate: AppBarSearchDelegate(isarService: isarService, filterCriteria: filterCriteria)
        ),
        icon: const Icon(Icons.search)
    );
  }

}