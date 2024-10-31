import 'package:expensy/components/forms/form_addTag.dart';
import 'package:expensy/entities/expense.dart';
import 'package:expensy/entities/payment_account.dart';
import 'package:expensy/entities/tags.dart';
import 'package:expensy/utils/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/currencies.dart';


class ExpensesForm extends StatefulWidget {
  final IsarService isarService;
  final Expense? prevExpenses;
  const ExpensesForm({super.key, required this.isarService, this.prevExpenses});

  @override
  ExpensesFormState createState() {
    return ExpensesFormState();
  }
}

class ExpensesFormState extends State<ExpensesForm> {
  late List<String>? newTagsList; //?  list containing name of the tags not yet saved to database
  late Future<List<FormBuilderChipOption<String>>> tagsOptionList;  // tags saved in database + newTagsList
  late DateTime? stateDate; // state for Date field
  late String? stateDescription; // state for Description field
  late String? stateAmount; //  state for Amount field
  late String? statePayment;
  late String? stateCurrency;

  late SharedPreferences prefs;

  late Future<List<DropdownMenuItem<String>>> paymentsAccountItems;

  Future<List<FormBuilderChipOption<String>>> getTagsOptions({List<String>? chipsToAdd}) async {
    final tagsList = await widget.isarService.getTags();  // tags saved in db
    List<FormBuilderChipOption<String>> options = [];
    for (Tags tag in tagsList) {
      options.add(FormBuilderChipOption(value: tag.name));
    }
    if (chipsToAdd != null) {
      for(var chip in chipsToAdd) {
        options.add(FormBuilderChipOption(value: chip)); // new tags not yet saved in the db
      }
    }
    return options;
  }

  Future<List<DropdownMenuItem<String>>> getPaymentAccountsItems() async {
    final paymentAccounts = await widget.isarService.getPaymentAccounts();
    List<DropdownMenuItem<String>> paymentItemList = [];
    
    for(PaymentAccount payment in paymentAccounts) {
      paymentItemList.add(DropdownMenuItem(
        value: payment.name,
        child: Text(payment.name)
      ));
    }
    return paymentItemList;
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
     if(widget.prevExpenses == null) {
       stateCurrency = prefs.getString('currency');
     }
    });
  }

  @override
  void initState() {
    super.initState();

    _loadPreferences();

    tagsOptionList = getTagsOptions();
    newTagsList = [];
    stateDate = widget.prevExpenses != null ? widget.prevExpenses?.date : DateTime.now();
    stateDescription = widget.prevExpenses?.description;
    stateAmount = widget.prevExpenses?.amount.toStringAsFixed(2);
    stateCurrency = widget.prevExpenses?.currency;

    statePayment = widget.prevExpenses?.paymentAccount.value?.name;
    paymentsAccountItems = getPaymentAccountsItems();

  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();

    return (
      FutureBuilder(
          future: Future.wait([paymentsAccountItems, tagsOptionList]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              debugPrint(snapshot.data.toString());
              List<DropdownMenuItem<String>> paymentsAccountItemsSnapshot = snapshot.data![0] as List<DropdownMenuItem<String>>;
              List<FormBuilderChipOption<String>> tagsOptionListSnapshot = snapshot.data![1] as List<FormBuilderChipOption<String>>;
              return Container(
                padding: const EdgeInsets.all(15),
                child: FormBuilder(
                  key: formKey,
                  child: Column(
                    children: [
                      /// DATE
                      FormBuilderDateTimePicker(
                        format: DateFormat('dd/MM/yyyy', Localizations.localeOf(context).languageCode), //DateFormat('dd/MM/y'),
                        inputType: InputType.date,
                        name: 'Date',
                        initialValue: stateDate,
                        onChanged: (date) {
                          stateDate = date;
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.dateLabel,
                          icon: const Icon(Icons.calendar_month),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.dateTime(errorText: AppLocalizations.of(context)!.dateErrorMessage),
                        ]),
                      ),
                      /// AMOUNT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: FormBuilderTextField(
                              name: 'Amount',
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.amountLabel,
                                icon: const Icon(Icons.money_rounded),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.numeric(),
                                FormBuilderValidators.min(0,inclusive: true)
                                // FormBuilderValidators.notZeroNumber(),
                                // FormBuilderValidators.positiveNumber(),
                              ]),
                              initialValue: stateAmount,
                              onChanged: (amount) {
                                stateAmount = amount;
                              },
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                              flex: 1,
                              child: FormBuilderDropdown(
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!.currencyLabel,
                                  ),
                                  onChanged: (currency) {
                                    stateCurrency = currency;
                                  },
                                  initialValue: stateCurrency,
                                  name: 'Currency',
                                  items: currenciesList.map((currency) =>
                                      DropdownMenuItem(
                                          alignment: AlignmentDirectional.center,
                                          value: currency,
                                          child: Text(currency)
                                      )
                                  ).toList()
                              )
                          )
                        ],
                      ),


                      /// PAYMENT ACCOUNTS
                      FormBuilderDropdown(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.selectPaymentAccount,
                            icon: const Icon(Icons.credit_card),
                          ),
                          onChanged: (payment) {
                            statePayment = payment;
                          },
                          name: 'Payments',
                          initialValue: statePayment,
                          items: paymentsAccountItemsSnapshot
                      ),

                      /// DESCRIPTION
                      FormBuilderTextField(
                        name: 'Description',
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.descriptionLabel,
                          icon: const Icon(Icons.shopping_cart_outlined),
                        ),
                        initialValue: stateDescription,
                        onChanged: (description) {
                          stateDescription = description;
                        },
                        minLines: 1,
                        maxLines: 3,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      /// TAGS
                      Center(
                        child: FormBuilderFilterChip<String>(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Tags',
                          ),
                          name: 'Tags',
                          selectedColor: Theme.of(context).colorScheme.inversePrimary,
                          options: tagsOptionListSnapshot,
                          alignment: WrapAlignment.center,
                          showCheckmark: false,
                          spacing: 15,
                          initialValue: () {
                            List<String> enabledValues = [];
                            if(widget.prevExpenses?.tags != null) {
                              for(var tag in widget.prevExpenses!.tags) {
                                enabledValues.add(tag.name);
                              }
                            }
                            return enabledValues;
                          } (),
                        ),
                      ),
                      /// ADD TAGS
                      TextButton(
                        onPressed: () async {
                          final data = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SimpleDialog(
                                  children: [AddTagForm()],
                                );
                              });
                          final res = await widget.isarService.getTags(filterByName: data);
                          if(data != null && res.isEmpty) {
                            setState(() {
                              newTagsList = [...?newTagsList, data];
                              tagsOptionList = getTagsOptions(chipsToAdd: newTagsList);
                            });
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.addTagsButtonName),
                      ),
                      const SizedBox(height: 20, ),
                      /// FORM BUTTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FilledButton(
                            onPressed: () async {
                              if (formKey.currentState?.saveAndValidate() ?? false) {
                                final mapentries = Map.fromEntries(formKey.currentState!.value.entries);

                                late Expense expense;
                                if(widget.prevExpenses != null) {
                                  final findExpense = await widget.isarService.getExpenseById(widget.prevExpenses!.id);
                                  if(findExpense != null) {
                                    expense = findExpense;
                                    expense.date = mapentries['Date'];
                                    expense.description = mapentries['Description'];
                                    expense.amount = double.parse(mapentries['Amount']);
                                    expense.currency = mapentries['Currency'];
                                  }
                                  else {
                                    return;
                                  }
                                }
                                else {
                                  expense = Expense(
                                      date: mapentries['Date'],
                                      description: mapentries['Description'],
                                      amount: double.parse(mapentries['Amount']),
                                      currency: mapentries['Currency']
                                  );
                                }
                                widget.isarService.deleteExpenseTags(expense); // remove all expense tags, they will be added later
                                for (String name in mapentries['Tags']) {
                                  if (name.isNotEmpty) {
                                    final tagsFound = await widget.isarService.getTags(filterByName: name);  // should be always one ?
                                    late Tags tag;
                                    if (tagsFound.isEmpty) {
                                      tag = Tags(name: name);
                                      expense.tags.add(tag);
                                    }
                                    else{
                                      for(Tags tag in tagsFound) {
                                        expense.tags.add(tag);
                                      }
                                    }
                                  }
                                }
                                if(mapentries['Payments'] != null) {
                                  final name = mapentries['Payments'];
                                  final paymentFound = await widget.isarService.getPaymentAccounts(filterByName: name);
                                  expense.paymentAccount.value = paymentFound.first;
                                }

                                widget.isarService.saveExpense(expense);

                                if (!context.mounted) return;
                                Navigator.pop(context);
                              }
                            },
                            child: Text(AppLocalizations.of(context)!.submitButtonName),
                          ),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(AppLocalizations.of(context)!.cancelButtonName),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            else {
              return const SizedBox(
                width: 400,
                height: 400,
                child: Center(
                  child: SpinKitDoubleBounce(
                    color: Colors.blueGrey,
                    size: 30,
                  ),
                ),
              );
            }
          }
        )
    );
  }
}
