import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aniwatch/models/anime.dart';
import 'package:aniwatch/screens/anime_screen.dart';


class SearchPage extends StatefulWidget {
    @override
    _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _controller;
  List<Anime>? animeList;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getAnimesFromGogoanime(String? keyword) async {
    setState(() {
      animeList = null;
      print("calling set state...");
    });
    Map<String, String> queryParams = {'keyword':(keyword ?? "")};
    List<Anime> newAnimeList = [];
    print("Trying...");
    var url = Uri.https("www3.gogoanime.cm", "search.html", queryParams);
    print(url);
    var response = await http.Client().get(url);
    var document = parser.parse(response.body);
    for(var a in document.getElementsByClassName("img")) {
      Anime anime = Anime(a.children[0].attributes["title"] ?? "null", 
                          a.children[0].children[0].attributes["src"] ?? "null",
                          a.children[0].attributes["href"] ?? "null");
      print(anime.title + "," + anime.image_url);
      newAnimeList.add(anime);
    }
    setState(() {
      animeList = newAnimeList;
      print("calling set state...");
    });
  }

  void goToAnimePage(Anime anime) {
      print("Going to anime page of " + anime.title);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
            AnimePage(anime : anime),
        )
      );
  }

  Widget getBody() {
    if(animeList == null) return Center(child: Text("Loading"),);
    List<Anime> nonNullAnimeList = animeList ?? [];
    return Expanded( child :ListView.builder(itemCount: nonNullAnimeList.length, itemBuilder: (context, i){
      return ListTile(
          title: Image(image: CachedNetworkImageProvider(nonNullAnimeList[i].image_url),height: 200,),
          subtitle: Text(nonNullAnimeList[i].title),
          onTap: () {goToAnimePage(nonNullAnimeList[i]);},
          );
      }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: TextFormField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                ),
                controller: _controller,
                onFieldSubmitted: (String keyword) {getAnimesFromGogoanime(keyword);},
              ),
        ),
      ),
      body: Container(
        child: Column(
          children: [getBody()],
        )
      )
    );
  }
}
