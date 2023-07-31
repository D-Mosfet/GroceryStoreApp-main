import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groceryapp/pages/home_page.dart';

import 'package:http/http.dart' as http;

class CreateAlat extends StatefulWidget {
  const CreateAlat({super.key});

  @override
  State<CreateAlat> createState() => _CreateAlatState();
}

class _CreateAlatState extends State<CreateAlat> {
  final itemController = TextEditingController();
  final priceController = TextEditingController();

  Future<void> addData() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    final response =
        await http.post(Uri.parse('http://localhost:1337/api/freshmarts'),
            headers: headers,
            body: jsonEncode({
              'data': {
                'item': itemController.text,
                'price': priceController.text,
              }
            }));

    if (response.statusCode == 200) {
      itemController.clear();
      priceController.clear();
    } else {
      throw Exception('Failed to add data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 216, 49, 49)),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: Text(
          "Tambah Barang",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          TextField(
            controller: itemController,
            decoration: InputDecoration(
              labelText: 'Nama',
            ),
          ),
          TextField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: 'Harga',
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              addData();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const HomePage(),
              ));
            },
            child: Text(
              'Create',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ]),
      ),
    );
  }
}
