import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search page',
      home: SearchPage()
    );
  }
}


class SearchPage extends StatefulWidget {
    @override
    _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchTitle = "";
  final GlobalKey<_SearchPageState> _formKey = GlobalKey<_SearchPageState>();

  Widget _buildSearchTitleField() {
    return Text("test");
  }

  Future getAnimesFromGogoanime() async {
    Map<String, String> queryParams = {'keyword':'Attack on Titan'};
    List<Anime> animeList = [];
    print("Trying...");
    var url = Uri.https("www3.gogoanime.cm", "search.html", queryParams);
    print(url);
    var response = await http.Client().get(url);
    var document = parser.parse(response.body);
    for(var a in document.getElementsByClassName("img")) {
      Anime anime = Anime(a.children[0].attributes["title"] ?? "null");
      animeList.add(anime);
    }

    print(document.getElementsByClassName("img")[0].children[0].attributes["title"]);
    return animeList;
  }

  Future getAnimes() async {
    Map<String, String> queryParams = {'q':'naruto'};
    var url = Uri.https("api.jikan.moe", "v3/search/anime", queryParams);
    var response = await http.get(url);
    var jsonData = jsonDecode(response.body);
    List<Anime> animeList = [];

    for(var a in jsonData['results']) {
      Anime anime = Anime(a['title']);
      animeList.add(anime);
    }
    print("Fetched " + animeList.length.toString() + " titles");
    return animeList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Page'),
      ),
      body: Container(
        child: Column(
          children: [
          Form(child: Column(children:<Widget> [
           _buildSearchTitleField(),
           ElevatedButton(onPressed: () => {}, child: Text("Search"),)
          ],)
          ),
          Expanded(
            child: FutureBuilder(
              future: getAnimesFromGogoanime(),
              builder: (context,AsyncSnapshot snapshot) {
                if(snapshot.data == null) {
                  return Container(child:Center(child:Text("Loading")));
                } else {
                  return ListView.builder(itemCount: snapshot.data.length, itemBuilder: (context, i){
                    return ListTile(
                        title: Text(snapshot.data[i].title),
                        );
                    });
                }
              }),
            )
          ])
      )
    );
  }
}


class Anime {
  /*
     {
     "mal_id": 20,
     "url": "https://myanimelist.net/anime/20/Naruto",
     "image_url": "https://cdn.myanimelist.net/images/anime/13/17405.jpg?s=59241469eb470604a792add6fbe7cce6",
     "title": "Naruto",
     "airing": false,
     "synopsis": "Moments prior to Naruto Uzumaki's birth, a huge demon known as the Kyuubi, the Nine-Tailed Fox, attacked Konohagakure, the Hidden Leaf Village, and wreaked havoc. In order to put an end to the Kyuubi'...",
     "type": "TV",
     "episodes": 220,
     "score": 7.95,
     "start_date": "2002-10-03T00:00:00+00:00",
     "end_date": "2007-02-08T00:00:00+00:00",
     "members": 2282665,
     "rated": "PG-13"
     }
   */
  String title;
  Anime(this.title);
}
