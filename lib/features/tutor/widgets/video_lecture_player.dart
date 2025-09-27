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
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final VideoPlayerController vc =
          widget.isAsset
              ? VideoPlayerController.asset(widget.source)
              : VideoPlayerController.networkUrl(
                Uri.parse(widget.source),
                httpHeaders: {
                  // Helps some CDNs that require a UA
                  'User-Agent': 'Mozilla/5.0 (Flutter)',
                },
                videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
              );
      await vc.initialize();
      final double ratio =
          vc.value.aspectRatio == 0 ? 16 / 9 : vc.value.aspectRatio;
      final cc = ChewieController(
        videoPlayerController: vc,
        autoPlay: true,
        looping: false,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        aspectRatio: ratio,
      );
      if (mounted) {
        setState(() {
          _videoController = vc;
          _chewieController = cc;
          _lastError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastError = e;
        });
      }
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
    if (_lastError != null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'Video failed to load',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
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
