import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  final String videoId;
  final String title;
  final bool autoPlay;
  final bool mute;

  const YoutubeVideoPlayer({
    super.key,
    required this.videoId,
    required this.title,
    this.autoPlay = false,
    this.mute = false,
  });

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> with AutomaticKeepAliveClientMixin {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true; // Keep the state alive when scrolling

  @override
  void initState() {
    super.initState();
    _initializeController();
  }
  
  void _initializeController() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: widget.mute,
        enableCaption: true,
        controlsVisibleAtStart: true,
        useHybridComposition: true,
      ),
    );
  }

  @override
  void didUpdateWidget(YoutubeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the video ID has changed, update the controller
    if (oldWidget.videoId != widget.videoId && !_isDisposed) {
      // Dispose the old controller
      _controller.pause();
      _controller.dispose();
      
      // Create a new controller with the new video ID
      setState(() {
        _initializeController();
        _isPlayerReady = false;
      });
    }
  }

  @override
  void deactivate() {
    if (!_isDisposed) {
      _controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.red,
              progressColors: const ProgressBarColors(
                playedColor: Colors.red,
                handleColor: Colors.redAccent,
              ),
              onReady: () {
                setState(() {
                  _isPlayerReady = true;
                });
                _controller.addListener(() {
                  if (_isPlayerReady && mounted) {
                    setState(() {});
                  }
                });
              },
              onEnded: (data) => _controller.pause(),
              topActions: [
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            builder: (context, player) {
              return Column(
                children: [player],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}