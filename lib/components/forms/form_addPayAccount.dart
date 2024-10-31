import 'package:expensy/entities/payment_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/isar_service.dart';


class AddPayAccountForm extends StatelessWidget {
  final formKey = GlobalKey <FormBuilderState> ();
  final IsarService isarService;
  final PaymentAccount? prevAccount;
  AddPayAccountForm({super.key, required this.isarService, this.prevAccount});


  @override
  Widget build(BuildContext context) {
    return
      Container(
        padding: const EdgeInsets.all(15),
        height: 180,
        child: FormBuilder(
          key: formKey,
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FormBuilderTextField(
                name: 'payment_account',
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.addPaymentAccountLabel,
                  icon: const Icon(Icons.wallet)
                ),
                initialValue: prevAccount?.name,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FilledButton( onPressed: () async {
                    if(formKey.currentState?.saveAndValidate() ?? false) {
                      final entries = Map.fromEntries(formKey.currentState!.value.entries);

                      late PaymentAccount payAccount;
                      if(prevAccount != null) {
                        final findPayAccount = await isarService.getPaymentAccountById(prevAccount!.id);
                        if(findPayAccount != null) {
                          payAccount = findPayAccount;
                          payAccount.name = entries['payment_account'];
                        } else {
                          return;
                        }
                      }
                      else {
                        payAccount = PaymentAccount(name: entries['payment_account']);
                      }

                      isarService.savePaymentAccount(payAccount);

                      if(!context.mounted) return;
                      Navigator.pop(context);
                    }
                  },
                    child: Text(AppLocalizations.of(context)!.submitButtonName),
                  ),
                  OutlinedButton( onPressed: () {
                    Navigator.pop(context);
                  }, child: Text(AppLocalizations.of(context)!.cancelButtonName)
                  )
                ],
              )

            ],
          )
        ),
      );

  }
}