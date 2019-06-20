import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/utlis/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptopnController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);
    var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextStyle textstyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptopnController.text = note.description;

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                moveToLastScreen();
              },
            ),
          ),
          body: Form(
            key: _formKey,
            child:Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    style: textstyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint("User selected $valueSelectedByUser");
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField(
                    controller: titleController,
                    style: textstyle,
                    validator: (String value){
                      if(value.isEmpty){
                        return 'Please Enter the Title';
                      }
                      updateTitle();
                    },
                    //onChanged: (value) {
                      //debugPrint('Something Changed in Title Text Field');
                      //updateTitle();
                    //},
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textstyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextFormField(
                    controller: descriptopnController,
                    style: textstyle,
                    validator: (String value){
                      if(value.isEmpty){
                        return 'Please Enter the Description';
                      }
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: textstyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Save button Clicked');
                              _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 6.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint('Delete button Clicked');
                              _delete();
                            });
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // HIGH
        break;
      case 2:
        priority = _priorities[1]; // LOW
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update Description of Note Object
  void updateDescription() {
    note.description = descriptopnController.text;
  }

  // Save data to database
  void _save() async {

    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    // Case 1 : Update Operation
    if (note.id != null) {
      result = await helper.updateNote(note);
    }
    // Case 2 : Insert Operation
    else {
      result = await helper.insertNote(note);
    }

    // if Success Process
    if (result != 0) {
      _showAlterDialog('Status', 'Note Saved Successfuly');
    }

    // if Failure Process
    else {
      _showAlterDialog('Status', 'Problem Saving Note');
    }
  }

  // Delete a Note 

  void _delete() async {
    moveToLastScreen();
    // Case 1: If user is trying to delete the NEW Note i.e He has come to
    // the detail page by presseng the FAB of the NoteList Page.
    if ( note.id ==  null)
    {
      _showAlterDialog('Status', 'Discarded');
      return;
    }

    // Case 2: User is Trying to delete the old note that already had a Valid ID.
    int result = await helper.deleteNote(note.id);
    if (result != 0){
      _showAlterDialog('Status', 'Note Deleted Succesfully');
    }
    else {
      _showAlterDialog('Status', 'Error Occured While Deleting the Note');
    }
  }

  void _showAlterDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
