import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:convert/convert.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

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

  Widget _buildSearchTitleField() {
    return Text("test");
  }

  Future getAnimesFromGogoanime() async {
    Map<String, String> queryParams = {'keyword':'boruto'};
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
      //print(anime.title + "," + anime.image_url);
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

    EpisodePage({Key? key, required this.anime,required this.episode}) : super(key: key);

    @override
    _EpisodePageState createState() => _EpisodePageState();
}


class _EpisodePageState extends State<EpisodePage>{

  String decryptData(final String encrypted) {
    String hex_secret_key = "3235373436353338353932393338333936373634363632383739383333323838";
    List<int> int_key = hex.decode(hex_secret_key);
    String secret_key = new String.fromCharCodes(int_key);

    String hex_iv_str = "34323036393133333738303038313335";
    List<int> int_iv = hex.decode(hex_iv_str);
    String iv_str = new String.fromCharCodes(int_iv);

    final key = encrypt.Key.fromUtf8(secret_key);
    final iv = encrypt.IV.fromUtf8(iv_str);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final decrypted = encrypter.encrypt(encrypted, iv: iv).base64;
    print("Decrypted: " + decrypted);
    return decrypted;
  }

  Future getLinks() async {

    // Dpage link
    var url = Uri.https("www3.gogoanime.cm", widget.anime.getAnimeId() + "-episode-" + widget.episode.toString());
    var response = await http.Client().get(url);
    var document = parser.parse(response.body);
    String dpage_link = "https:" + (document.getElementsByClassName("vidcdn")[0].children[0].attributes["data-video"] ?? "/null");
    print(dpage_link);
 
    // decrypt link
    String video_id = dpage_link.split("?")[1].split("&")[0].split("id=")[1];
    print("video_id : " + video_id);
    String decrypted_video_id = decryptData(video_id);

    var headers = {
      'x-requested-with': 'XMLHttpRequest',
    };

    var data = {
      'id': decrypted_video_id,
      'time': '69420691337800813569',
    };

    var ajax_url = Uri.https("gogoplay.io", "/encrypt-ajax.php");
    var res = await http.post(ajax_url, headers: headers, body: data);
    if (res.statusCode != 200) throw Exception('http.post error: statusCode= ${res.statusCode}');
    Map<String, dynamic> map = json.decode(res.body);
    List<dynamic> source = map["source"]; 
    print("Episode file: " + source[0]["file"]);
    return source; 
  }

  void play(video_url) {
    print("Going to Video page");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
          //VideoPlayerScreen(video_url: video_url),
          VLCVideoPage(video_url: video_url),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.anime.title + " ep:" + widget.episode.toString())),
      body: FutureBuilder(
        future: getLinks(), 
        builder: (context,AsyncSnapshot snapshot) {
          print(snapshot.data);
          if(snapshot.data == null) return Container(child:Center(child:Text("Loading")));
          else {
            return SingleChildScrollView(child: Column(
                children: List.generate(snapshot.data.length, (index) => 
                    ElevatedButton(
                      child: Text((snapshot.data[index]["label"]).toString()), 
                      onPressed: (){play(snapshot.data[index]["file"]);})
            )));
          }
        }
      )
    );
  }
}




//--------------------------------Video Screen------------------------------
class VideoPlayerScreen extends StatefulWidget {
  final String video_url;
  const VideoPlayerScreen({Key? key, required this.video_url}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.network(widget.video_url);

    _initializeVideoPlayerFuture = _controller.initialize();
    // Use the controller to loop the video.
    _controller.setLooping(true);

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime Video'),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(_controller),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

//----------------------------------------VLC------------------------------------------
class VLCVideoPage extends StatefulWidget {
  final String video_url;
  const VLCVideoPage({Key? key, required this.video_url}) : super(key: key);

  @override
  _VLCVideoPageState createState() => _VLCVideoPageState();
}

class _VLCVideoPageState extends State<VLCVideoPage> {
  late VlcPlayerController _videoPlayerController;

  Future<void> initializePlayer() async {}

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VlcPlayerController.network(
      widget.video_url,
      hwAcc: HwAcc.FULL,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _videoPlayerController.stopRendererScanning();
    //await _videoViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: VlcPlayer(
            controller: _videoPlayerController,
            aspectRatio: 16 / 9,
            placeholder: Center(child: CircularProgressIndicator()),
          ),
        ));
  }
}
