import 'package:flutter/material.dart';
import 'modules/contacts_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts',
      theme: ThemeData(
        primaryColor: Colors.black,
        primarySwatch: Colors.grey,
        fontFamily: 'LexendDeca',
      ),
      home: ContactList(),
    );
  }
}
