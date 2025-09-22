import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoLecturePlayer extends StatefulWidget {
  final String source; // asset path or url
  final bool isAsset;
  const VideoLecturePlayer({
    super.key,
    required this.source,
    this.isAsset = true,
  });

  @override
  State<VideoLecturePlayer> createState() => _VideoLecturePlayerState();
}

class _VideoLecturePlayerState extends State<VideoLecturePlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final vc = widget.isAsset
        ? VideoPlayerController.asset(widget.source)
        : VideoPlayerController.networkUrl(Uri.parse(widget.source));
    await vc.initialize();
    final cc = ChewieController(
      videoPlayerController: vc,
      autoPlay: false,
      looping: false,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
      showControls: true,
      aspectRatio: vc.value.aspectRatio == 0 ? 16 / 9 : vc.value.aspectRatio,
    );
    if (mounted) {
      setState(() {
        _videoController = vc;
        _chewieController = cc;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}
