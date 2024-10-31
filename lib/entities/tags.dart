import 'package:expensy/entities/expense.dart';
import 'package:isar/isar.dart';
part 'tags.g.dart';


@collection
class Tags {
  Tags({
    required this.name,
  });

  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  late String name;

  @Backlink(to: 'tags')
  final expense = IsarLinks<Expense>();
}
