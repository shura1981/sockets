import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
   
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {

final args= ModalRoute.of(context)?.settings.arguments ?? 'No data';

    return Scaffold(
 appBar: AppBar(title: const Text('home'),),
      body:   Center(
         child: Text('$args'),
      ),
    );
  }
}