import 'package:flutter/material.dart';
import 'package:sql_notes_app/data/local/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;
  TextEditingController titleController = TextEditingController();
  TextEditingController decrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body:
          allNotes.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: allNotes.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      leading: Text(
                        '${allNotes[index][DBHelper.COLUMN_NOTE_SNO]}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                      subtitle: Text(
                        allNotes[index][DBHelper.COLUMN_NOTE_DESC],
                      ),
                      trailing: SizedBox(
                        width: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                // ✅ Initialize new controllers with current values
                                titleController = TextEditingController(
                                  text:
                                      allNotes[index][DBHelper
                                          .COLUMN_NOTE_TITLE],
                                );
                                decrController = TextEditingController(
                                  text:
                                      allNotes[index][DBHelper
                                          .COLUMN_NOTE_DESC],
                                );

                                // ✅ Show bottom sheet with pre-filled input
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return getBottomSheetWidget(
                                      isUpdate: true,
                                      sno:
                                          allNotes[index][DBHelper
                                              .COLUMN_NOTE_SNO],
                                    );
                                  },
                                );
                              },
                              child: Icon(Icons.edit),
                            ),

                            InkWell(
                              onTap: () async {
                                bool chack = await dbRef!.deleteNote(
                                  sno:
                                      allNotes[index][DBHelper.COLUMN_NOTE_SNO],
                                );
                                if (chack) {
                                  getNotes();
                                }
                              },
                              child: Icon(Icons.delete, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
              : Center(child: Text('No Notes Yet!..')),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          titleController.clear();
          decrController.clear();
          await showModalBottomSheet(
            context: context,
            builder: (cpntext) => getBottomSheetWidget(),
          );
          getNotes();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  //getBottomSheetWidget
  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return Container(
      padding: EdgeInsets.all(11),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            isUpdate ? 'Update Note' : 'Add Note',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 21),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: "Enter title here",
              label: Text('Title'),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          SizedBox(height: 11),

          TextField(
            controller: decrController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Enter Description here",
              label: Text('Desc'),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          SizedBox(height: 11),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () async {
                    var title = titleController.text;
                    var desc = decrController.text;

                    if (title.isNotEmpty && desc.isNotEmpty) {
                      bool check =
                          isUpdate
                              ? await dbRef!.updateNote(
                                mTitle: title,
                                mDesc: desc,
                                sno: sno,
                              )
                              : await dbRef!.addNote(
                                mTitle: title,
                                mDesc: desc,
                              );

                      if (check) {
                        getNotes();
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("*Please fill all required fields!"),
                        ),
                      );
                    }
                    titleController.clear();
                    decrController.clear();
                    Navigator.pop(context);
                  },
                  child: Text(isUpdate ? "Update Note" : "Add Note"),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
