import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:convert/convert.dart';
import 'package:aniwatch/models/anime.dart';
import 'package:aniwatch/screens/video_screen.dart';

class EpisodePage extends StatefulWidget {
    final Anime anime;
    final int episode;

    EpisodePage({Key? key, required this.anime,required this.episode}) : super(key: key);

    @override
    _EpisodePageState createState() => _EpisodePageState();
}


class _EpisodePageState extends State<EpisodePage>{

  late String dpage_link;

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
    dpage_link = "https:" + (document.getElementsByClassName("vidcdn")[0].children[0].attributes["data-video"] ?? "/null");
    print("dpage link: " + dpage_link);
 
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
    print("response body: " + res.body);
    Map<String, dynamic> map = json.decode(res.body);
    List<dynamic> source = map["source"]; 
    print("Episode file: " + source[0]["file"]);
    return source; 
  }

  void play(video_url, dpage_url) {
    print("Going to Video page");
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
          //VideoPlayerScreen(video_url: video_url),
          VideoPage(videoUrl: video_url, dPageUrl: dpage_url,),
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
                      onPressed: (){play(snapshot.data[index]["file"], dpage_link);})
            )));
          }
        }
      )
    );
  }
}

