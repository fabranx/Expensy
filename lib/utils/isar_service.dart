import 'dart:io';
import 'package:expensy/entities/payment_account.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import '../entities/expense.dart';
import '../entities/tags.dart';

class IsarService {
  late Future<Isar> db;
  //we define db that we want to use as late
  IsarService() {
    db = openDB();
    //open DB for use.
  }

  /// EXPENSE OPERATIONS
  //Save a new expense to the Isar database.
  Future<void> saveExpense(Expense newExpense) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.expenses.putSync(newExpense));
    _checkAndDeleteUnusedTags();
  }

  Future<bool> deleteExpense(int expenseId) async {
    final isar = await db;
    bool result = await isar.writeTxn(() => isar.expenses.delete(expenseId));
    _checkAndDeleteUnusedTags();
    return result;
  }

  //Retrieve all expense from the Isar database.
  Future<List<Expense>> getExpenses() async {
    final isar = await db;

    return await isar.expenses.where().findAll();
  }

  Future<Expense?> getExpenseById(int id) async {
    final isar = await db;
    return await isar.expenses.get(id);
  }

  //Save expenses in list to the Isar database.
  // Future<void> saveMultipleExpenses(List<Expense> newExpenses) async {
  //
  //   final isar = await db;
  //   //Perform a synchronous write transaction to add the user to the database.
  //   isar.writeTxn(() async {
  //     for(Expense expense in newExpenses) {
  //       await isar.expenses.put(expense);
  //     }
  //   });
  //   _checkAndDeleteUnusedTags();
  // }

  /// TAG OPERATIONS

  Future<void> saveTag(Tags newTag) async {
    final isar = await db;

    final filteredNameTag =
        await isar.tags.filter().nameEqualTo(newTag.name).findAll();
    if (filteredNameTag.isEmpty) {
      isar.writeTxnSync(() => isar.tags.putSync(newTag));
    }
  }

  Future<List<Tags>> getTags({String filterByName = ''}) async {
    final isar = await db;
    if (filterByName.isNotEmpty) {
      return isar.tags.filter().nameEqualTo(filterByName).findAllSync();
    } else {
      return isar.tags.where().sortByName().findAllSync();
    }
  }

  Future<Tags?> getTagById(int id) async {
    final isar = await db;
    return await isar.tags.get(id);
  }

  void deleteExpenseTags(Expense expense) async {
    final isar = await db;
    List<Tags> tags = [...expense.tags]; // make a copy for avoid error Concurrent modification during iteration
    for (Tags tag in tags) {
      expense.tags.remove(tag);
    }
    isar.writeTxnSync(() => isar.expenses.putSync(expense));
  }

  Future<void> deleteTag(Tags tag) async {
    final isar = await db;
    isar.writeTxn(() => isar.tags.delete(tag.id));
  }

  void _checkAndDeleteUnusedTags() async {
    final isar = await db;
    List<Tags> savedTags = await getTags();
    isar.writeTxnSync(() {
      for (Tags tag in savedTags) {
        if (tag.expense.isEmpty) {
          isar.tags.deleteSync(tag.id);
        }
      }
    });
  }

  /// PAYMENT ACCOUNT OPERATIONS
  Future<void> savePaymentAccount(PaymentAccount newPayAccount) async {
    final isar = await db;

    final filteredPayAccount = await isar.paymentAccounts
        .filter()
        .nameEqualTo(newPayAccount.name)
        .findAll();
    if (filteredPayAccount.isEmpty) {
      isar.writeTxnSync(() => isar.paymentAccounts.putSync(newPayAccount));
    }
  }

  Future<List<PaymentAccount>> getPaymentAccounts(
      {String filterByName = ''}) async {
    final isar = await db;
    if (filterByName.isNotEmpty) {
      return await isar.paymentAccounts
          .filter()
          .nameEqualTo(filterByName)
          .findAll();
    } else {
      return await isar.paymentAccounts.where().findAll();
    }
  }

  Future<PaymentAccount?> getPaymentAccountById(int id) async {
    final isar = await db;
    return await isar.paymentAccounts.get(id);
  }

  Future<void> deletePaymentAccount(PaymentAccount account) async {
    final isar = await db;
    isar.writeTxn(() => isar.paymentAccounts.delete(account.id));
  }

  /// PAYMENT ACCOUNT STREAMS

  Stream<List<PaymentAccount>> streamPaymentAccount() async* {
    final isar = await db;
    yield* isar.paymentAccounts
        .where()
        .sortByName()
        .watch(fireImmediately: true);
  }

  Stream<List<Expense>> streamExpensesPayAccountDateNewToOld(
      {required PaymentAccount account,
      DateTime? start,
      DateTime? end}) async* {
    final isar = await db;
    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .paymentAccount((q) => q.idEqualTo(account.id))
          .dateBetween(start, end)
          .sortByDateDesc()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .where()
          .filter()
          .paymentAccount((q) => q.idEqualTo(account.id))
          .sortByDateDesc()
          .watch(fireImmediately: true);
    }
  }

  Stream<List<Expense>> streamExpensesPayAccountDateOldToNew(
      {required PaymentAccount account,
      DateTime? start,
      DateTime? end}) async* {
    final isar = await db;
    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .paymentAccount((q) => q.idEqualTo(account.id))
          .dateBetween(start, end)
          .sortByDate()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .where()
          .filter()
          .paymentAccount((q) => q.idEqualTo(account.id))
          .sortByDate()
          .watch(fireImmediately: true);
    }
  }

  Stream<List<Expense>> streamExpensesPayAccountPriceHighToLow(
      {required PaymentAccount account,
      DateTime? start,
      DateTime? end}) async* {
    final isar = await db;
    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .paymentAccount((q) => q.idEqualTo(account.id))
          .dateBetween(start, end)
          .sortByTotalTransactionDesc()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .where()
          .filter()
          .paymentAccount((q) => q.idEqualTo(account.id))
          .sortByTotalTransactionDesc()
          .watch(fireImmediately: true);
    }
  }

  Stream<List<Expense>> streamExpensesPayAccountPriceLowToHigh(
      {required PaymentAccount account,
      DateTime? start,
      DateTime? end}) async* {
    final isar = await db;
    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .paymentAccount((q) => q.idEqualTo(account.id))
          .dateBetween(start, end)
          .sortByTotalTransaction()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .where()
          .filter()
          .paymentAccount((q) => q.idEqualTo(account.id))
          .sortByTotalTransaction()
          .watch(fireImmediately: true);
    }
  }

  /// TAGS STREAMS

  Stream<List<Tags>> streamTags() async* {
    final isar = await db;
    yield* isar.tags.where().sortByName().watch(fireImmediately: true);
  }

  Stream<List<Expense>> streamExpensesTagDateNewToOld(
      {required Tags tag, DateTime? start, DateTime? end}) async* {
    final isar = await db;
    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .tags((q) => q.idEqualTo(tag.id))
          .dateBetween(start, end)
          .sortByDateDesc()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .where()
          .filter()
          .tags((q) => q.idEqualTo(tag.id))
          .sortByDateDesc()
          .watch(fireImmediately: true);
    }
  }

  Stream<List<Expense>> streamExpensesTagDateOldToNew(
      {required Tags tag, DateTime? start, DateTime? end}) async* {
    final isar = await db;
    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .tags((q) => q.idEqualTo(tag.id))
          .dateBetween(start, end)
          .sortByDate()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .where()
          .filter()
          .tags((q) => q.idEqualTo(tag.id))
          .sortByDate()
          .watch(fireImmediately: true);
    }
  }

  Stream<List<Expense>> streamExpensesTagPriceHighToLow(
      {required Tags tag, DateTime? start, DateTime? end}) async* {
    final isar = await db;
    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .tags((q) => q.idEqualTo(tag.id))
          .dateBetween(start, end)
          .sortByTotalTransactionDesc()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .where()
          .filter()
          .tags((q) => q.idEqualTo(tag.id))
          .sortByTotalTransactionDesc()
          .watch(fireImmediately: true);
    }
  }

  Stream<List<Expense>> streamExpensesTagPriceLowToHigh(
      {required Tags tag, DateTime? start, DateTime? end}) async* {
    final isar = await db;
    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .tags((q) => q.idEqualTo(tag.id))
          .dateBetween(start, end)
          .sortByTotalTransaction()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .where()
          .filter()
          .tags((q) => q.idEqualTo(tag.id))
          .sortByTotalTransaction()
          .watch(fireImmediately: true);
    }
  }

  /// EXPENSES STREAMS

  Stream<List<Expense>> streamExpensesDateNewToOld({DateTime? start, DateTime? end}) async* {
    final isar = await db;

    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .dateBetween(start, end)
          .sortByDateDesc()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .where()
          .sortByDateDesc()
          .watch(fireImmediately: true);
    }
  }

  Stream<List<Expense>> streamExpensesDateOldToNew({DateTime? start, DateTime? end}) async* {
    final isar = await db;

    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .dateBetween(start, end)
          .sortByDate()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses.where().sortByDate().watch(fireImmediately: true);
    }
  }

  Stream<List<Expense>> streamExpensesPriceHighToLow({DateTime? start, DateTime? end}) async* {
    final isar = await db;

    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .dateBetween(start, end)
          .sortByTotalTransactionDesc()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .where()
          .sortByTotalTransactionDesc()
          .watch(fireImmediately: true);
    }
  }

  Stream<List<Expense>> streamExpensesPriceLowToHigh({DateTime? start, DateTime? end}) async* {
    final isar = await db;

    if (start != null && end != null) {
      yield* isar.expenses
          .where()
          .filter()
          .dateBetween(start, end)
          .sortByTotalTransaction()
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses.where().sortByTotalTransaction().watch(fireImmediately: true);
    }
  }

  Stream<List<Expense>> streamSearchExpense({required String query, Object? filterCriteria}) async* {
    final isar = await db;
    if (filterCriteria is Tags) {
      Tags tag = filterCriteria;
      yield* isar.expenses
          .filter()
          .tags((q) => q.idEqualTo(tag.id))
          .descriptionContains(query, caseSensitive: false)
          .watch(fireImmediately: true);
    } else if (filterCriteria is PaymentAccount) {
      PaymentAccount account = filterCriteria;
      yield* isar.expenses
          .filter()
          .paymentAccount((q) => q.idEqualTo(account.id))
          .descriptionContains(query, caseSensitive: false)
          .watch(fireImmediately: true);
    } else {
      yield* isar.expenses
          .filter()
          .descriptionContains(query, caseSensitive: false)
          .watch(fireImmediately: true);
    }
  }

  /// DB OPERATIONS

  Future<bool> exportDB(String selectedPath) async {
    final isar = await db;
    final DateTime now = DateTime.now();
    final DateFormat format = DateFormat('ddMMyyHms');
    final copiedDbFile =
        File(path.join(selectedPath, "backup_db_${format.format(now)}.isar"));
    try {
      isar.copyToFile(copiedDbFile.path);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> importDb(File dbFile) async {
    final isar = await db;
    final dbDirectory = await getApplicationDocumentsDirectory();

    // close the database before any changes
    await isar.close();

    final dbPath = path.join(dbDirectory.path, 'default.isar');

    if (await dbFile.exists()) {
      // here we overwrite the backup file on the database file
      await dbFile.copy(dbPath);
    }
  }

  Future<void> deleteDb() async {
    final isar = await db;
    await isar.close(deleteFromDisk: true);
  }

  Future<Isar> openDB() async {
    var dir = await getApplicationDocumentsDirectory();
    // to get application directory information
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [ExpenseSchema, TagsSchema, PaymentAccountSchema],
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
    // return instance of Isar - it makes the isar state Ready for Usage for adding/deleting operations.
  }
}
