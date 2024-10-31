import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class AddTagForm extends StatelessWidget {
 final formKey = GlobalKey <FormBuilderState> ();

  AddTagForm({super.key});

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
                name: 'tag',
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.addTagLabel,
                    icon: const Icon(Icons.tag)
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FilledButton( onPressed: () {
                    if(formKey.currentState?.saveAndValidate() ?? false) {
                      final entries = Map.fromEntries(formKey.currentState!.value.entries);
                      Navigator.pop(context, entries['tag']);
                    }
                  },
                    child: Text(AppLocalizations.of(context)!.addTagsButtonName),
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