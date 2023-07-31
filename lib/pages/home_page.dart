import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:groceryapp/pages/cart_page.dart';
import 'package:provider/provider.dart';
import '../components/grocery_item_tile.dart';
import '../model/cart_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var datajson;
  int totalData = 0;
  bool isLoading = true;
  final itemController = TextEditingController();
  final priceController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:1337/api/freshmarts'),
      );

      if (response.statusCode == 200) {
        setState(() {
          datajson = jsonDecode(response.body);
          totalData = datajson["meta"]["pagination"]["total"];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to connect to the server');
    }
  }

  Future<void> updateData(String id) async {
    final response = await http.put(
      Uri.parse('http://localhost:1337/api/freshmarts/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'data': {
          'item': itemController.text,
          'price': priceController.text,
        }
      }),
    );

    if (response.statusCode == 200) {
      _fetchData();
      itemController.clear();
      priceController.clear();
    } else {
      throw Exception('Failed to update data');
    }
  }

  Future<void> _confirmDelete(String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteData(id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteData(String id) async {
    final response = await http
        .delete(Uri.parse('http://localhost:1337/api/freshmarts/$id'));

    if (response.statusCode == 200) {
      _fetchData();
    } else {
      throw Exception('Failed to delete data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CreateAlat(),
          ));
        },
        child: const Icon(Icons.add_box_rounded),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('Good morning,'),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Let's order fresh items for you",
              style: GoogleFonts.notoSerif(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Fresh Items",
              style: GoogleFonts.notoSerif(
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : totalData == 0
                    ? Center(child: Text('No data available.'))
                    : Consumer<CartModel>(
                        builder: (context, value, child) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: totalData,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1 / 1.2,
                            ),
                            itemBuilder: (data, index) {
                              final itemId =
                                  datajson['data'][index]['id'].toString();
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Update Data'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
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
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Icon(Icons.cancel),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Icon(Icons.change_circle),
                                            onPressed: () {
                                              updateData(datajson['data'][index]
                                                      ['id']
                                                  .toString());
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: GroceryItemTile(
                                  itemName: datajson['data'][index]
                                      ['attributes']['item'],
                                  itemPrice:
                                      '   ${datajson['data'][index]['attributes']['price']}',
                                  imagePath: value.shopItems[index][2],
                                  color: value.shopItems[index][3],
                                  onPressed: () {
                                    _confirmDelete(itemId);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
