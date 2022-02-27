import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VideoPage extends StatefulWidget {
  final String videoUrl;
  final String dPageUrl;
  const VideoPage({Key? key, required this.videoUrl, required this.dPageUrl}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;
  final GlobalKey _videoPlayerWidgetKey = GlobalKey();
  bool _visible = true;

  Future<void> initializePlayer() async {}


  @override
  void initState() {
    super.initState();

    Map<String, String> httpHeaders = new Map();
    httpHeaders['Referer'] = widget.dPageUrl;

    _videoPlayerController = VideoPlayerController.network(widget.videoUrl, httpHeaders: httpHeaders)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() async {
    super.dispose();
    await _videoPlayerController.dispose();
  }

  void _togglePausePlay() async {
    print("Tap...");
    _visible = true;
    setState(() {
      _videoPlayerController.value.isPlaying
        ? _visible = true
        : _visible = false;

      _videoPlayerController.value.isPlaying
          ? _videoPlayerController.pause()
          : _videoPlayerController.play();
    });
  }

  void _doubleTapDownCallback(TapDownDetails details) async {
    print("Tap Tap Down...");
    print(details.localPosition);
    double width = (_videoPlayerWidgetKey.currentContext?.size?.width ?? 0);
    print("width: " + width.toString());
    print("local position dx: " + details.localPosition.dx.toString());
    if(details.localPosition.dx > width/2) 
      _fastForward(10); 
    else 
      _fastForward(-10);
  }

  
  void _doubleTapCallback() async {
    print("Tap Tap...");
  }

  void _fastForward(int secs) async {
    print(secs);
    Duration current = _videoPlayerController.value.position;
    Duration seekTo = current + Duration(seconds: secs);
    await _videoPlayerController.seekTo(seekTo);
  }

  Widget getVideoPlayerWidget() {
    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer( _videoPlayerController),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 50),
            reverseDuration: Duration(milliseconds: 500),
            child: _visible
              ? Container(
                color: Colors.black26,
                child: Center(child: Icon(Icons.play_arrow, color: Colors.white, size: 75))
              )
              : SizedBox.shrink()
          ),
          VideoProgressIndicator(
            _videoPlayerController, 
            allowScrubbing: true,
            padding: EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: 
      Center(
        child: GestureDetector( 
          key: _videoPlayerWidgetKey,
          onTap: _togglePausePlay,
          onDoubleTap: _doubleTapCallback,
          onDoubleTapDown: _doubleTapDownCallback,
          /*
          child: VlcPlayer(
                  controller: _videoPlayerController,
                  aspectRatio: 16 / 9,
                  placeholder: Center(child: CircularProgressIndicator()), 
          ),
          */
          child: _videoPlayerController.value.isInitialized || _videoPlayerController.value.isBuffering
            ? getVideoPlayerWidget()
            : Center(child: CircularProgressIndicator())
        ),
      )
    );
  }
}

