import 'package:expensy/components/forms/form_editTag.dart';
import 'package:expensy/components/pages/tags_expenses_page.dart';
import 'package:expensy/utils/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class TagsPage extends StatelessWidget {
  final IsarService isarService;
  const TagsPage({super.key, required this.isarService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: isarService.streamTags(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final tags = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Tags"),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    itemCount: tags?.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 0),
                    itemBuilder: (BuildContext context, int accountIndex) {
                      return Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                "${tags?[accountIndex].name}",
                                style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w600) ),
                              contentPadding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 0),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return TagsExpensesPage(isarService: isarService, tag: tags![accountIndex]);
                                    }
                                  )
                                );
                              },
                              trailing: PopupMenuButton<String>(
                                onSelected: (String value) {
                                  switch (value) {
                                    case 'Delete':
                                      isarService.deleteTag(tags![accountIndex]);
                                    case 'Edit':
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SimpleDialog(
                                            children: [EditTagForm(isarService: isarService, prevTag: tags![accountIndex],)],
                                          );
                                        }
                                      );
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                                  PopupMenuItem(
                                    value: 'Edit',
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(AppLocalizations.of(context)!.editLabel),
                                        const Icon(Icons.drive_file_rename_outline)
                                      ],
                                    )
                                  ),
                                  PopupMenuItem(
                                    value: 'Delete',
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(AppLocalizations.of(context)!.deleteLabel),
                                        const Icon(Icons.delete_forever_sharp)
                                      ],
                                    )
                                  ),
                                ],
                              )
                            ),
                            const Divider(height: 0,),
                          ],
                        ),
                      );
                    }
                  ),
                ],
              ),
            )
          );
        }
      }
    );
  }
}