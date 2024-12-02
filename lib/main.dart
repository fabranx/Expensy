import 'package:expensy/components/buttons/searchButton.dart';
import 'package:expensy/components/drawer.dart';
import 'package:expensy/components/navBarColorHandler.dart';
import 'package:expensy/components/pages/expenses_list_page.dart';
import 'package:expensy/entities/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:intl/intl.dart';
import 'components/buttons/popUpSortButton.dart';
import 'utils/isar_service.dart';
import 'components/forms/form_addEdit_Expense.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:expensy/utils/sortTypes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  setNavBarColor(savedThemeMode);
  runApp(MyApp(savedThemeMode: savedThemeMode,));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  MyApp({super.key, required this.savedThemeMode});
  final service = IsarService();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light:  ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent, brightness: Brightness.light),
        appBarTheme: AppBarTheme.of(context).copyWith(
          color: Colors.lightGreen[200],
        ),
        brightness: Brightness.light,
        // scaffoldBackgroundColor: Colors.lime[50],
        fontFamily: 'Lato',
        dialogTheme: DialogTheme(
          backgroundColor: Colors.lime[50],
          surfaceTintColor: Colors.lime
        ),
        useMaterial3: true,
      ),
      dark: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.limeAccent, brightness: Brightness.dark),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.blueGrey[900],
        fontFamily: 'Lato',

        dialogTheme: DialogTheme(
          backgroundColor: Colors.blueGrey[900],
          surfaceTintColor: Colors.lime[50]
        ),
        useMaterial3: true
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.dark,

      builder: (theme, darkTheme) => MaterialApp(
        theme: theme,
        darkTheme: darkTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FormBuilderLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('it'), // Italian
          Locale('en'), // English
        ],
        home: MyHomePage(isarService: service),
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.isarService});
  final IsarService isarService;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1).subtract(const Duration(milliseconds: 1));  // 23:59:59.999 on the last day of the current month

  late Stream<List<Expense>> streamExpenses = widget.isarService.streamExpensesDateNewToOld(start: startDate, end: endDate);

  SortTypes sortExpenses = SortTypes.newest;



  Stream<List<Expense>> getSortedExpenseStream(SortTypes sort) {
    switch(sort) {
      case SortTypes.newest:
        return widget.isarService.streamExpensesDateNewToOld(start: startDate, end: endDate);
      case SortTypes.older:
        return widget.isarService.streamExpensesDateOldToNew(start: startDate, end: endDate);
      case SortTypes.highestAmount:
        return widget.isarService.streamExpensesPriceHighToLow(start: startDate, end: endDate);
      case SortTypes.lowestAmount:
        return widget.isarService.streamExpensesPriceLowToHigh(start: startDate, end: endDate);
    }
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.appTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
        centerTitle: false,
        actions: [
          ButtonBar(
            buttonPadding: const EdgeInsets.all(0),
            alignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              SearchButton(isarService: widget.isarService),
              PopUpSortButton(
                getSortedStreamCallback: getSortedExpenseStream,
                setStateCallback: (SortTypes sort, Stream<List<Expense>> stream) {
                  setState(() {
                    sortExpenses = sort;
                    streamExpenses = stream;
                  });
                },
              ),
            ],
          )
        ],
      ),


      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 60,
                maxWidth: 400
              ),
              child: FormBuilderDateRangePicker(
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                allowClear: true,
                // clearIcon: Icon(Icons.clear, size: 22,),
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 16),
                name: 'Range',
                firstDate: DateTime(1950),
                lastDate: DateTime(2200),
                initialValue: DateTimeRange(
                  start: startDate,
                  end: endDate,
                ),
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
                      streamExpenses = getSortedExpenseStream(sortExpenses);
                    } else {
                      startDate = DateTime(1950);
                      endDate = DateTime(2200);
                      streamExpenses = getSortedExpenseStream(sortExpenses);
                    }
                  });
                },
              ),
            )

          ),
          Flexible(
            child: RefreshIndicator(
                child: ExpensesListPage(
                  isarService: widget.isarService,
                  streamExpenses: streamExpenses,
                ),
                onRefresh: () async {
                  setState(() {
                    streamExpenses = getSortedExpenseStream(sortExpenses);
                  });
                }
            ),
          )
        ],
      ),
      drawer: AppDrawer(isarService: widget.isarService),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog.fullscreen(
              child: SingleChildScrollView(
                child: ExpensesForm(isarService: widget.isarService,),
              ),
            );
          }
        ),
        tooltip: AppLocalizations.of(context)!.addButtonTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}