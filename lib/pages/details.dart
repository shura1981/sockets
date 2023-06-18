import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
   
  const DetailsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
 appBar: AppBar(title: const Text('DetailsScreen'),),
      body: const Center(
         child: Text('DetailsScreen'),
      ),
    );
  }
}