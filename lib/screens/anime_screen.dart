import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aniwatch/models/anime.dart';
import 'package:aniwatch/screens/episode_screen.dart';

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

