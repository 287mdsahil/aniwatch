import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

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


//--------------------------Search page-----------------------------

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
    Map<String, String> queryParams = {'keyword':'naruto'};
    List<Anime> animeList = [];
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
      animeList.add(anime);
    }
    return animeList;
  }

  /*
  Future getAnimes() async {
    Map<String, String> queryParams = {'q':'naruto'};
    var url = Uri.https("api.jikan.moe", "v3/search/anime", queryParams);
    var response = await http.get(url);
    var jsonData = jsonDecode(response.body);
    List<Anime> animeList = [];

    for(var a in jsonData['results']) {
      Anime anime = Anime(a['title'], "placeholder_image_url");
      animeList.add(anime);
    }
    print("Fetched " + animeList.length.toString() + " titles");
    return animeList;
  }
  */

  void goToAnimePage(Anime anime) {
      print("Going to anime page of " + anime.title);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
            AnimePage(anime : anime),
        )
      );
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
                        title: Image(image: CachedNetworkImageProvider(snapshot.data[i].image_url),height: 200,),
                        subtitle: Text(snapshot.data[i].title),
                        onTap: () {goToAnimePage(snapshot.data[i]);},
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
  String image_url;
  String href;
  String? type;
  String? plot_summary;
  int? n_episodes;
  Anime(this.title, this.image_url, this.href);

  String getAnimeId() {
    return href.split("/")[2];
  }
}


//--------------------------Anime page-----------------------------
class AnimePage extends StatefulWidget {
    final Anime anime;

    AnimePage({Key? key, required this.anime,}) : super(key: key);

    @override
    _AnimePageState createState() => _AnimePageState();
}


class _AnimePageState extends State<AnimePage>{

  Future getAnimeDetails(Anime anime) async {
    var url = Uri.https("www3.gogoanime.cm", anime.href);
    print(url);
    var response = await http.Client().get(url);
    var document = parser.parse(response.body);
    //print(document.getElementById("episode_page")?.children[0].children[0].attributes);
    

    anime.type = document.getElementsByClassName("anime_info_body")[0].children[0].children[3].children[1].text;
    anime.plot_summary = document.getElementsByClassName("anime_info_body")[0].children[0].children[4].text;

    anime.n_episodes = 0;
    if(document.getElementById("episode_page")?.children !=  null) {
      var elements = document.getElementById("episode_page")?.children ?? [];
      for(var d in elements)
        anime.n_episodes = int.tryParse(d.children[0].attributes["ep_end"] ?? "0");
    }

    print(anime.n_episodes);
    return anime;
  }


  void goToEpisodePage(Anime anime, int episode) {
      print("Going to episode " + episode.toString() + " of " + anime.title);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
            EpisodePage(anime: anime, episode: episode),
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.anime.title),),
      body: FutureBuilder(
        future: getAnimeDetails(widget.anime), 
        builder: (context,AsyncSnapshot snapshot) {
          if(snapshot.data == null) return Container(child:Center(child:Text("Loading")));
          return SingleChildScrollView( 
            child: Column(
              children: [
                Image(image: CachedNetworkImageProvider(snapshot.data.image_url)),
                Text(snapshot.data.type),
                Text(snapshot.data.plot_summary),
                Column(
                children: List.generate(snapshot.data.n_episodes, (index) => 
                    ElevatedButton(child: Text((index+1).toString()), onPressed: (){goToEpisodePage(snapshot.data,index+1);},)
                  )
                )
              ],
            )
          );
        }
      )
    );
  } 

}




//--------------------------Episode page-----------------------------
class EpisodePage extends StatefulWidget {
    final Anime anime;
    final int episode;

    // Main urls
    String? dpage_link;
    String? video_url;

    EpisodePage({Key? key, required this.anime,required this.episode}) : super(key: key);

    @override
    _EpisodePageState createState() => _EpisodePageState();
}


class _EpisodePageState extends State<EpisodePage>{

  Future getDpageLink() async {
    print(widget.anime.getAnimeId());

    var url = Uri.https("www3.gogoanime.cm", widget.anime.getAnimeId() + "-episode-" + widget.episode.toString());
    var response = await http.Client().get(url);
    var document = parser.parse(response.body);
    widget.dpage_link = "https:" + (document.getElementsByClassName("vidcdn")[0].children[0].attributes["data-video"] ?? "/null");
    print(widget.dpage_link);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.anime.title + " ep:" + widget.episode.toString())),
      body: FutureBuilder(
        future: getDpageLink(), 
        builder: (context,AsyncSnapshot snapshot) {
          return Container(child:Center(child:Text("Loading")));
        }
      )
    );
  }
}
