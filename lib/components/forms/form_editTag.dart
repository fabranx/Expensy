import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../entities/tags.dart';
import '../../utils/isar_service.dart';


class EditTagForm extends StatelessWidget {
  final formKey = GlobalKey <FormBuilderState> ();
  final IsarService isarService;
  final Tags prevTag;
  EditTagForm({super.key, required this.isarService, required this.prevTag});

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
                name: 'tags',
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.addTagLabel,
                  icon: const Icon(Icons.tag)
                ),
                initialValue: prevTag.name,
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

                      final foundTag = await isarService.getTagById(prevTag.id);
                      if(foundTag != null) {
                        foundTag.name = entries['tags'];
                        isarService.saveTag(foundTag);
                      } else {
                        return;
                      }

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