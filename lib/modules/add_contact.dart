import 'dart:convert';
import 'package:pb_v5/model/contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class CreateNewContact extends StatefulWidget {
  @override
  _CreateNewContactState createState() => _CreateNewContactState();
}

class _CreateNewContactState extends State<CreateNewContact> {
  int key = 0, increments = 0, contactsSize = 1, _count = 1;
  String val = '';
  RegExp digitValidator = RegExp("[0-9]+");

  bool isANumber = true;
  String fname = '', lname = '';

  final firstNameCtrlr = TextEditingController();
  final lastNameCtrlr = TextEditingController();

  List<TextEditingController> contactNumCtrlr = <TextEditingController>[
    TextEditingController()
  ];

  final FocusNode fnameFocus = FocusNode();
  final FocusNode lnameFocus = FocusNode();

  List<Contact> newContact = <Contact>[];

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
  }

  void saveContact() {
    bool emptyDetect = false;
    List<String> listedContacts = <String>[];
    for (int i = 0; i < _count; i++) {
      listedContacts.add(contactNumCtrlr[i].text);
      if (contactNumCtrlr[i].text.isEmpty) {
        emptyDetect = true;
      }
    }
    setState(() {
      newContact.insert(
          0,
          Contact(firstNameCtrlr.text, lastNameCtrlr.text,
              listedContacts.reversed.toList()));
    });
    if (newContact[0].first_name.isEmpty || newContact[0].last_name.isEmpty) {
      emptyDetect = true;
    }

    Text message = Text('New Contact Added: \n\n' +
        newContact[0].first_name +
        " " +
        newContact[0].last_name +
        "\n" +
        listedContacts.reversed.toList().toString());

    if (!emptyDetect) {
      uploadContact(newContact[0].first_name, newContact[0].last_name,
          listedContacts.reversed.toList());
    } else {
      message = Text(
        'Please Fill All Fields',
        style: TextStyle(color: Colors.red),
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
      backgroundColor: _color("black"),
      appBar: AppBar(
        centerTitle: true,
        title: _cText("Create New", _color('def'), null, null),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
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
              ctrlrField(context, "First Name", firstNameCtrlr, _color('sel'),
                  _color('def'), Colors.red),
              _hfill(10),
              ctrlrField(context, "Last Name", lastNameCtrlr, _color('sel'),
                  _color('def'), Colors.red),
              _hfill(10),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(bottom: 8, left: 8),
                child: Text("#s: $_count",
                    style: _idTextStyle('italic', Colors.grey, 12)),
              ),
              _hfill(5),
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
          FloatingActionButton.extended(
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
            label: Text("Add"),
            foregroundColor: Colors.white,
            backgroundColor: Colors.teal[900],
          ),
          SizedBox(width: 12),
          FloatingActionButton.extended(
            onPressed: () {
              // >>>>>>>>>>>>>>>>>>>>>>>>>>>> SAVE BUTTON HERE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
              saveContact();
            },
            icon: Icon(Icons.save),
            label: Text("Save"),
            foregroundColor: Colors.white,
            backgroundColor: Colors.teal[900],
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
            child: TextFormField(
              //maxLength: 12,
              controller: contactNumCtrlr[index],
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              decoration: new InputDecoration(
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _color('sel'),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _color('def'),
                  ),
                ),

                disabledBorder: InputBorder.none,
                /*
                  errorText: (contactNumCtrlr[index].text.isNotEmpty)
                  ? null
                  : "Please enter a number",
                   errorBorder: OtlinedInputBorder, */
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                labelText: 'Contact Number',
                labelStyle: _idTextStyle('bold', _color('sel'), 15),
                //errorBorder:
              ),
              style: _idTextStyle('bold', _color('def'), 15),
            ),
          ),
        ],
      ),
      SizedBox(height: 12),
    ]);
  }

  void setValidator(valid) {
    setState(() {
      isANumber = valid;
    });
  }

  Widget _hfill(double height) {
    return SizedBox(height: height);
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

Widget ctrlrField(
    BuildContext context,
    String fieldPrompt,
    TextEditingController ctrlrID,
    Color selectedColor,
    Color defaultColor,
    Color errorColor) {
  return TextFormField(
    controller: ctrlrID,
    textInputAction: TextInputAction.next,
    textCapitalization: TextCapitalization.sentences,
    //focusNode: currentNodeID,
    /*
    onFieldSubmitted: (term) {
      _fieldFocusChange(context, currentNodeID, nextNodeID);
    },*/
    decoration: new InputDecoration(
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: selectedColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: defaultColor,
        ),
      ),
      disabledBorder: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 15),
      labelText: fieldPrompt,
      labelStyle: _idTextStyle('bold', selectedColor, 15),
      //errorText: (ctrlrID.text.isEmpty) ? "Field is Required" : null,
    ),
    style: _idTextStyle('bold', defaultColor, 15),
  );
}

Color _color(String id) {
  switch (id) {
    case ('black'):
      return Colors.black;
    case ('lblue'):
      return Colors.lightBlue;
    case ('grey'):
      return Colors.grey;
    case ('def'):
      return Color(0xFFFFFFFF);
    case ('sel'):
      return Color(0xFF00ABFF);
    case ('sub'):
      return Color(0xFF6F6F6F);
    case ('high'):
      return Colors.deepOrange;
    default:
      print('colorNot Identifed');
      return Colors.white;
  }
}

Widget _cText(String text, Color? colour, double? size, String? style) {
  return Text(text, style: _idTextStyle(style, colour, size));
}

TextStyle _idTextStyle(String? style, Color? colour, double? size) {
  double defaultSize = 20;
  switch (style) {
    case 'bold':
      return TextStyle(
        color: (colour != null) ? colour : Colors.grey,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        fontSize: (size != null) ? size : defaultSize,
      );
    case 'italic':
      return TextStyle(
        color: (colour != null) ? colour : Colors.grey,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.normal,
        fontSize: (size != null) ? size : defaultSize,
      );
    case 'boldItalic':
      return TextStyle(
        color: (colour != null) ? colour : Colors.grey,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        fontSize: (size != null) ? size : defaultSize,
      );
    default:
      return TextStyle(
        color: (colour != null) ? colour : Colors.grey,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: (size != null) ? size : defaultSize,
      );
  }
}