import 'package:flutter/material.dart';

class padin extends StatelessWidget {
  final String hinttext;
  final TextEditingController mycontroller;

  const padin({super.key, required this.hinttext, required this.mycontroller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: mycontroller,
        decoration: InputDecoration(
          hintText: hinttext,
          prefixIcon: Icon(Icons.person),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
