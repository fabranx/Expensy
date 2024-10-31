import 'package:isar/isar.dart';
import 'expense.dart';
part 'payment_account.g.dart';


@collection
class PaymentAccount {
  PaymentAccount({required this.name});
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  late String name;

  @Backlink(to: 'paymentAccount')
  final expense = IsarLinks<Expense>();
}
