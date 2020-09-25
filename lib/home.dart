import 'package:flutter/material.dart';
import 'Todo_screen.dart';

 class home extends StatelessWidget {
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text("ToDoList"),
         centerTitle: true,
         backgroundColor: Colors.black54,

       ),
       body: ToDoScreen(),
     );
   }
 }
