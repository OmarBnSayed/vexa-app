abstract class VideoPicker {
  Future<PickedVideo?> pickVideo();
}

class PickedVideo {
  final String name;
  final dynamic video; // File for IO, Blob or Bytes for web
  PickedVideo({required this.name, required this.video});
}
