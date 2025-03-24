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
      required this.currency,
      this.refund = 0,
      this.dateRefund
    }
  );
  Id id = Isar.autoIncrement;
  DateTime date;
  DateTime? dateRefund;
  String description;
  double amount;
  double refund;
  String currency;

  // Value not saved in the database, calculated each time amount or refund changes
  float get totalTransaction => amount - refund.abs();

  final tags = IsarLinks<Tags>();

  final paymentAccount = IsarLink<PaymentAccount>();
}
