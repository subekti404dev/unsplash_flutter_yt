import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'dart:async';
import 'package:http/http.dart' as http;

import 'data.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _keyword = '';
  Timer _debounce;
  List<Results> _data = [];

  onChangeText(text) {
    _keyword = text;
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      var data = await fetchData(_keyword);
      setState(() {
        _data = data.results;
      });
    });
  }

  Future<Data> fetchData(keyword) async {
    var url =
        'https://unsplash.com/napi/search/photos?query=$keyword&xp=&per_page=50&page=1';
    var responseApi = await http.get(url);
    if (responseApi.statusCode == 200) {
      var resJSON = json.decode(responseApi.body);
      var data = Data.fromJson(resJSON);
      return data;
    } else {
      print('Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Image.asset('images/unsplash.png', width: 300, height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: TextField(
              onChanged: onChangeText,
              decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Text(
            '1000 images for `$_keyword`',
            style: TextStyle(fontSize: 20),
          ),
          Visibility(
            visible: _data.length > 0,
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(_data[index].urls.small)),
                      );
                    }),
              ),
            ),
          )
        ],
      )),
    );
  }
}
