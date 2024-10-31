import 'package:expensy/entities/payment_account.dart';
import 'package:expensy/entities/tags.dart';
import 'package:isar/isar.dart';

part 'expense.g.dart';


@collection
class Expense {
  Expense(
    {
      required this.date,
      required this.description,
      required this.amount,
      required this.currency
    }
  );
  Id id = Isar.autoIncrement;
  DateTime date;
  String description;
  float amount;
  String currency;

  final tags = IsarLinks<Tags>();

  final paymentAccount = IsarLink<PaymentAccount>();
}
