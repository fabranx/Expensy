import 'dart:io';
import 'package:expensy/entities/payment_account.dart';
import 'package:expensy/utils/currencies.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../entities/expense.dart';
import 'package:excel/excel.dart';
import '../entities/tags.dart';
import 'isar_service.dart';

Map<String, int> rowTitlesColPosition = {
  "Date": 0,
  "Description": 1,
  "Amount": 2,
  "Currency": 3,
  "Tags": 4,
  "Payment-Account": 5
};



String sheetName = "Expenses";

bool exportToExcel(List<Expense> expenses,String path) {
  try {
    Excel excel = Excel.createExcel();
    excel.rename('Sheet1', sheetName);
    Sheet sheetObject = excel[sheetName];

    List<CellValue> titleCellRow = rowTitlesColPosition.keys.map((String title) => TextCellValue(title)).toList();
    sheetObject.insertRowIterables(titleCellRow, 0, startingColumn: 0);

    for(Expense expense in expenses) {
      DateCellValue date = DateCellValue(year: expense.date.year, month: expense.date.month, day: expense.date.day);
      TextCellValue description = TextCellValue(expense.description);
      DoubleCellValue amount = DoubleCellValue(expense.amount);
      TextCellValue currency = TextCellValue(expense.currency);
      TextCellValue tags = TextCellValue(expense.tags.map((el) => el.name).join(';'));
      TextCellValue paymentAccount = TextCellValue("${expense.paymentAccount.value != null ? expense.paymentAccount.value?.name : ''}");
      List<CellValue> expenseRow = [date, description, amount, currency, tags, paymentAccount];
      sheetObject.appendRow(expenseRow);
    }

    final DateTime now = DateTime.now();
    final DateFormat format = DateFormat('ddMMyyHms');

    var fileBytes = excel.save();

    File(join('$path/expenses-${format.format(now)}.xlsx'))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    return true;

  } catch (e) {
    return false;
  }

}

Future<(bool, String?)> importFromExcel(File selectedFile, BuildContext context, IsarService isarService) async {
  String? message;
  List<int> rowWithWrongValues = [];

  try {
    var bytes = selectedFile.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    var table = excel.sheets[sheetName];

    if(table?.sheetName != sheetName || table == null) {
      throw NoSheetFoundException();
    } else {
      var tableRowTitles = table.row(0);
      List<String?> titles = tableRowTitles.map((cell) => cell?.value.toString()).toList();
      if(!listEquals(rowTitlesColPosition.keys.toList(), titles)) {
        throw ExcelParseError();
      }

      for(int i=1; i< table.maxRows; i++) {
        DateTime? date;
        String description;
        double? amount;
        String currency;
        List<String>? tags;
        String? paymentAccountName;

        Expense newExpense;

        date = DateTime.tryParse(table.row(i)[rowTitlesColPosition["Date"]!]!.value.toString());
        if(date == null) {
          rowWithWrongValues.add(i+1);
          continue;
        }

        description = table.row(i)[rowTitlesColPosition["Description"]!]!.value != null ? table.row(i)[rowTitlesColPosition["Description"]!]!.value.toString() : '';
        if(description.isEmpty) {
          rowWithWrongValues.add(i+1);
          continue;
        }

        amount = double.tryParse(table.row(i)[rowTitlesColPosition["Amount"]!]!.value.toString())?.abs();
        if(amount == null) {
          rowWithWrongValues.add(i+1);
          continue;
        }

        currency = table.row(i)[rowTitlesColPosition["Currency"]!]!.value.toString().toUpperCase();
        if(!currenciesList.contains(currency)) {
          rowWithWrongValues.add(i+1);
          continue;
        }

        if(table.row(i)[rowTitlesColPosition["Tags"]!]!.value != null) {
          tags = table.row(i)[rowTitlesColPosition["Tags"]!]!.value.toString().split(';');
        }

        if(table.row(i)[rowTitlesColPosition["Payment-Account"]!]!.value != null) {
          paymentAccountName = table.row(i)[rowTitlesColPosition["Payment-Account"]!]!.value.toString();
        }

        newExpense = Expense(
          date: date,
          description: description,
          amount: amount,
          currency: currency
        );

        if(tags != null && tags.isNotEmpty) {
          for(String tagName in tags) {
            if(tagName.isNotEmpty) {
              final tagsFound = await isarService.getTags(filterByName: tagName);
              late Tags tag;
              if (tagsFound.isEmpty) {
                tag = Tags(name: tagName);
                await isarService.saveTag(tag);
                newExpense.tags.add(tag);
              }
              else{
                for(Tags tag in tagsFound) {
                  newExpense.tags.add(tag);
                }
              }
            }
          }
        }

        if(paymentAccountName != null) {
          final paymentFound = await isarService.getPaymentAccounts(filterByName: paymentAccountName);
          if(paymentFound.isNotEmpty) {
            newExpense.paymentAccount.value = paymentFound.first;
          } else {
            PaymentAccount payAccount = PaymentAccount(name: paymentAccountName);
            isarService.savePaymentAccount(payAccount);
            newExpense.paymentAccount.value = payAccount;
          }
        }
        isarService.saveExpense(newExpense);
      }
    }

  } on PathNotFoundException{
    if (context.mounted) {
      return (false, AppLocalizations.of(context)!.fileNotFound );
    }

  } on NoSheetFoundException {
    if(context.mounted) {
      return (false, AppLocalizations.of(context)!.noSheetFound);
    }

  } on ExcelParseError {
    if(context.mounted) {
      return (false, AppLocalizations.of(context)!.excelParseError);
    }
  }

  catch(e) {
    if(context.mounted) {
      return (false, "${AppLocalizations.of(context)!.genericError} $e");
    }
  }

  if(context.mounted) {
    message = "${AppLocalizations.of(context)!.excelImportSuccess} ${rowWithWrongValues.toString()}";
  }
  return (true, message);

}



class NoSheetFoundException implements Exception {
  NoSheetFoundException();
}

class ExcelParseError implements Exception {
  ExcelParseError();
}