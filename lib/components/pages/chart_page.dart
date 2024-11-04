import 'package:expensy/utils/isar_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../entities/expense.dart';

const YEAR = 'Annual';
const MONTH = 'Monthly';
const DATE_VISUALIZATION = {YEAR: 'y', MONTH:'MMMM'};

class ChartPage extends StatefulWidget {
  final IsarService isarService;
  const ChartPage({super.key, required this.isarService});

  @override
  State<StatefulWidget> createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> {

  DateTime? stateDate = DateTime.now(); // state for Date field
  String formatVisualization = DATE_VISUALIZATION[YEAR]!;
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  DateTime startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime endDate = DateTime(DateTime.now().year + 1, 1, 1).subtract(const Duration(days: 1));
  late Stream<List<Expense>> streamExpenses = widget.isarService.streamExpensesDateOldToNew(start: startDate, end: endDate);


  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context,) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.chart),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 8, right: 8),
              decoration: BoxDecoration(
                // color: Theme.of(context).colorScheme.primaryContainer,
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                border: Border.all(color: Theme.of(context).colorScheme.inversePrimary),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 2,
                      blurStyle: BlurStyle.normal,
                      color: Theme.of(context).shadowColor.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      spreadRadius: 2
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 0),
                    child: FormBuilderDropdown(
                      decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.graphicView),
                      ),
                      onChanged: (val) {
                        setState(() {
                          formatVisualization = val!;
                          formKey = GlobalKey<FormBuilderState>();
                          if(val == DATE_VISUALIZATION[YEAR]) {
                            startDate = DateTime(stateDate!.year, 1, 1);  // 1 january of year selected
                            endDate = DateTime(stateDate!.year + 1, 1, 1).subtract(const Duration(days: 1)); // 31 december of year selected
                          } else {
                            startDate = DateTime(stateDate!.year, stateDate!.month, 1);  // first day of the month and year selected
                            endDate = DateTime(stateDate!.year, stateDate!.month + 1, 1).subtract(const Duration(days: 1)); // last day of the month and year selected
                          }
                          streamExpenses = widget.isarService.streamExpensesDateOldToNew(start: startDate, end: endDate);
                        });
                      },
                      name: 'DateVisualization',
                      items: [
                        DropdownMenuItem(
                          value: DATE_VISUALIZATION[YEAR],
                          child: Text(AppLocalizations.of(context)!.year),
                        ),
                        DropdownMenuItem(
                          value: DATE_VISUALIZATION[MONTH],
                          child: Text(AppLocalizations.of(context)!.month),
                        ),
                      ],
                      initialValue: formatVisualization,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 10),
                    child: FormBuilderDateTimePicker(
                      key: formKey,
                      format: DateFormat(formatVisualization, Localizations.localeOf(context).languageCode),
                      inputType: InputType.date,
                      name: 'Date',
                      initialDatePickerMode: formatVisualization == DATE_VISUALIZATION[MONTH] ? DatePickerMode.day : DatePickerMode.year,
                      initialValue: stateDate,
                      onChanged: (date) {
                        setState(() {
                          stateDate = date;
                          if(formatVisualization == DATE_VISUALIZATION[YEAR]) {
                            startDate = DateTime(stateDate!.year, 1, 1);
                            endDate = DateTime(stateDate!.year + 1, 1, 1).subtract(const Duration(days: 1));
                          } else {
                            startDate = DateTime(stateDate!.year, stateDate!.month, 1);
                            endDate = DateTime(stateDate!.year, stateDate!.month + 1, 1).subtract(const Duration(days: 1));
                          }
                          streamExpenses = widget.isarService.streamExpensesDateOldToNew(start: startDate, end: endDate);
                        });
                      },
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.dateLabel,
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.dateTime(errorText: AppLocalizations.of(context)!.dateErrorMessage),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            StreamBuilder(
              stream: streamExpenses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitDoubleBounce(
                      size: 20,
                      color: Colors.blueGrey,
                    ),
                  );
                } else if (snapshot.hasError) {
                  // Text('Error: ${snapshot.error}');
                  return Center(
                      child: Text(AppLocalizations.of(context)!.genericError)
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.noData),
                  );
                } else {
                  final expensesList = snapshot.data;
                  for(Expense exp in expensesList!) {
                    debugPrint("${exp.date} - ${exp.amount}${exp.currency} - ${exp.description}");
                  }
                  Map<String, List<Expense>> currenciesExpenses = {};
                  for(Expense expense in expensesList) {
                    if (currenciesExpenses.containsKey(expense.currency)) {
                      currenciesExpenses[expense.currency]?.add(expense);
                    } else {
                      currenciesExpenses[expense.currency] = [expense];
                    }
                  }

                  final orientation = MediaQuery.of(context).orientation;

                  double aspectRatio() {
                    double value = 1.0;
                    if(orientation == Orientation.portrait) {
                      formatVisualization == DATE_VISUALIZATION[YEAR] ? value=1.0 : value=0.7;
                    } else {
                      formatVisualization == DATE_VISUALIZATION[YEAR] ? value=1.4 : value=0.8;
                    }
                    return value;
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currenciesExpenses.keys.length,
                    itemBuilder: (BuildContext context, int index) {
                      String keyCurrency = currenciesExpenses.keys.elementAt(index);
                      List<Expense>? expensePerCurrency = currenciesExpenses[keyCurrency];

                      return Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 4, right: 4),

                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 450),
                            decoration: BoxDecoration(
                              // color: Theme.of(context).colorScheme.primaryContainer,
                              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 2,
                                    blurStyle: BlurStyle.normal,
                                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    spreadRadius: 2
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("${AppLocalizations.of(context)!.expensesIn} $keyCurrency", style: const TextStyle(fontWeight: FontWeight.w600),),
                                AspectRatio(
                                  aspectRatio: aspectRatio(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5, right: 35, top: 15, bottom: 25),
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child: BarChart(
                                        BarChartData(
                                          barTouchData: barTouchData(keyCurrency),
                                          titlesData: titlesData,
                                          borderData: borderData,
                                          barGroups: formatVisualization == DATE_VISUALIZATION[YEAR] ? barYearGroups(expensePerCurrency) : barMonthGroups(expensePerCurrency),
                                          gridData: const FlGridData(show: false),
                                          alignment: BarChartAlignment.spaceAround,
                                          // maxY: 20000,
                                        ),
                                        swapAnimationDuration: animDuration,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ),
                        )
                      );
                    }
                  );
                }
              }
            )
          ],
        ),
      ),
    );
  }

  BarTouchData barTouchData(String keyCurrency) {
    return BarTouchData(
      enabled: true,
      handleBuiltInTouches: true,
      // allowTouchBarBackDraw: false,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => Colors.black.withOpacity(0.8),
        rotateAngle: 270,
        tooltipHorizontalAlignment: FLHorizontalAlignment.left,
        tooltipHorizontalOffset: -5,
        // fitInsideHorizontally: false,
        // fitInsideVertically: false,
        tooltipPadding: const EdgeInsets.all(4),
        tooltipMargin: -45,
        getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
        ) {
          return BarTooltipItem(
            NumberFormat.simpleCurrency(
                    locale: Localizations.localeOf(context).languageCode,
                    name: keyCurrency)
                .format(rod.toY)
                .toString(),
            textAlign: TextAlign.center,
            TextStyle(
              color: Theme.of(context).colorScheme.tertiaryFixed,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) { // titles on the left
    final style = TextStyle(
      color: Theme.of(context).colorScheme.tertiary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = (value.toInt() + 1).toString();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Transform.rotate(
        angle: -1.5708,
        child: Container(
          alignment: Alignment.centerLeft,
          child: Text(text, style: style),
        ),
      ),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
    show: true,
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: getTitles,
      ),
    ),
    leftTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    topTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
    rightTitles: const AxisTitles(
      sideTitles: SideTitles(showTitles: false),
    ),
  );

  FlBorderData get borderData => FlBorderData(
    show: false,
  );

  LinearGradient get _barsGradient => LinearGradient(
    colors: [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.primary.withOpacity(0.6),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );


  List<BarChartGroupData> barYearGroups(List<Expense>? expenses) {
    List<BarChartGroupData> barChartMonthData = [];
    for(int i=0; i<12; i++) {
      double totalInMonth = 0;
      if(expenses != null) {
        for(Expense exp in expenses) {
          if(exp.date.month == i+1) {
            totalInMonth += exp.amount;
          }
        }
      }
      barChartMonthData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              // color: i == touchedIndex ? Colors.green: Colors.red,
              toY: totalInMonth,
              gradient: _barsGradient,
              width: 12,
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2),)
            )
          ],
          // showingTooltipIndicators: [0],
        ),
      );
    }
    return barChartMonthData;
  }

  List<BarChartGroupData> barMonthGroups(List<Expense>? expenses) {
    List<BarChartGroupData> barChartMonthData = [];

    for(int i=0; i<endDate.day; i++) {
      double totalInDay = 0;
      if(expenses != null) {
        for(Expense exp in expenses) {
          if(exp.date.day == i+1) {
            totalInDay += exp.amount;
          }
        }
      }
      barChartMonthData.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalInDay,
              gradient: _barsGradient,
              width: 10,
              borderSide: const BorderSide(color: Colors.white10,)
            )
          ],
          // showingTooltipIndicators: [0],
        ),
      );
    }
    return barChartMonthData;
  }
}