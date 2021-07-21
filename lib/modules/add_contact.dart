import 'dart:convert';
import 'dart:io';
import 'package:pb_v5/model/contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dev.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateNewContact extends StatefulWidget {
  @override
  _CreateNewContactState createState() => _CreateNewContactState();
}

class _CreateNewContactState extends State<CreateNewContact> {
  int key = 0, increments = 0, contactsSize = 1, _count = 1;

  final firstNameCtrlr = TextEditingController();
  final lastNameCtrlr = TextEditingController();

  List<TextEditingController> contactNumCtrlr = <TextEditingController>[
    TextEditingController()
  ];

  late Contact newContact;
  late SharedPreferences tokenStore;
  /*
  Future<http.Response> uploadContact(
      String firstName, String lastName, List contactNumbers) {
    return http.post(
      Uri.parse('https://nukesite-phonebook-api.herokuapp.com/new'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'contact_numbers': contactNumbers,
      }),
      // RETURN ERROR CATCH
    );
  }*/

  Future<int> uploadContact(
      String firstName, String lastName, List contactNumbers) async {
    String retrievedToken = '';
    await prefSetup().then((value) =>
        {print("TOKEN FROM PREFERENCES: " + value!), retrievedToken = value});
    final response = await http.post(
      Uri.parse('https://nukesite-phonebook-api.herokuapp.com/new'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer " + retrievedToken
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'contact_numbers': contactNumbers,
      }),
    );
    print("RESPONSE UPLOAD: " + response.statusCode.toString());
    return (response.statusCode);
  }

  Future<String?> prefSetup() async {
    tokenStore = await SharedPreferences.getInstance();
    return tokenStore.getString('token');
  }

  void saveContact() async {
    bool emptyDetect = false;
    List<String> listedContacts = <String>[];
    for (int i = 0; i < _count; i++) {
      listedContacts.add(contactNumCtrlr[i].text);
      if (contactNumCtrlr[i].text.isEmpty) {
        emptyDetect = true;
      }
    }
    setState(() {
      newContact = Contact(firstNameCtrlr.text, lastNameCtrlr.text,
          listedContacts.reversed.toList());
    });
    if (newContact.first_name.isEmpty || newContact.last_name.isEmpty) {
      emptyDetect = true;
    }

    Text message = Text('New Contact Added: \n\n' +
        newContact.first_name +
        " " +
        newContact.last_name +
        "\n" +
        listedContacts.reversed.toList().toString());

    if (!emptyDetect) {
      //disguisedToast(context: context, message: 'Adding...');
      await uploadContact(newContact.first_name, newContact.last_name,
          listedContacts.reversed.toList());
    } else {
      message = Text(
        'Please Fill All Fields',
        style: cxTextStyle(style: 'bold', colour: Colors.deepOrange, size: 16),
      );
    }

    final snackBar = SnackBar(
      content: message,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    if (!emptyDetect) {
      Navigator.pop(context);
    } else {
      emptyDetect = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _count = 1;
  }

  @override
  void dispose() {
    firstNameCtrlr.dispose();
    lastNameCtrlr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colour(colour: 'black'),
      appBar: AppBar(
        centerTitle: true,
        title: cText(text: "Create New", colour: colour()),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {
                key = 0;
                increments = 0;
                contactsSize = 1;
                _count = 1;
                firstNameCtrlr.clear();
                lastNameCtrlr.clear();
                contactNumCtrlr.clear();
                contactNumCtrlr = <TextEditingController>[
                  TextEditingController()
                ];
              });
            },
          )
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ctrlrField(
                  context: context,
                  fieldPrompt: "First Name",
                  ctrlrID: firstNameCtrlr,
                  defaultColor: colour(),
                  selectedColor: colour(colour: 'sel'),
                  errorColor: Colors.red,
                  next: true,
                  autoFocus: true),
              hfill(10),
              ctrlrField(
                  context: context,
                  fieldPrompt: "Last Name",
                  ctrlrID: lastNameCtrlr,
                  defaultColor: colour(),
                  selectedColor: colour(colour: 'sel'),
                  errorColor: Colors.red,
                  next: true,
                  autoFocus: true),
              /*
              ctrlrField(context, "Last Name", lastNameCtrlr, colour('sel'),
                  colour('def'), Colors.red, null, false, true, true),*/
              hfill(10),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(bottom: 8, left: 8),
                child: Text("#s: $_count",
                    style: cxTextStyle(
                        style: 'italic', colour: Colors.grey, size: 12)),
              ),
              hfill(5),
              Flexible(
                child: ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    itemCount: _count,
                    itemBuilder: (context, index) {
                      return _contactsInput(index, context);
                    }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FAB(
            onPressed: () {
              // >>>>>>>>>>>>>>>>>>>>>>>>>>>> ADD BUTTON HERE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
              setState(() {
                _count++;
                increments++;
                contactsSize++;
                contactNumCtrlr.insert(0, TextEditingController());
              });
            },
            icon: Icon(Icons.add),
            text: "Add",
            foreground: colour(),
            background: colour(colour: 'dblue'),
          ),
          vfill(12),
          FAB(
            onPressed: () {
              // >>>>>>>>>>>>>>>>>>>>>>>>>>>> SAVE BUTTON HERE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
              saveContact();
            },
            icon: Icon(Icons.save),
            text: "Save",
            background: colour(colour: 'dblue'),
          ),
        ],
      ),
    );
  }

  _contactsInput(int index, context) {
    return Column(children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: 24,
              height: 24,
              child: _removeButton(index),
            ),
          ),
          Expanded(
            child: ctrlrField(
                context: context,
                fieldPrompt: "Contact Number",
                ctrlrID: contactNumCtrlr[index],
                defaultColor: colour(),
                selectedColor: colour(colour: 'sel'),
                errorColor: Colors.red,
                next: true,
                autoFocus: true,
                inputType: TextInputType.phone),
          ),
        ],
      ),
      hfill(12),
    ]);
  }

  Widget _removeButton(int index) {
    return InkWell(
      onTap: () {
        //FocusManager.instance.primaryFocus?.unfocus();
        if (contactsSize != 1) {
          setState(() {
            _count--;
            increments--;
            contactsSize--;
            contactNumCtrlr.removeAt(index);
          });
        }
      },
      child: (_count != 1)
          ? Container(
              alignment: Alignment.center,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.cancel,
                color: Colors.white70,
              ),
            )
          : null,
    );
  }
}
