import 'dart:html' as html;
import 'dart:typed_data';
import 'upload_interface.dart';
import 'dart:async';
import 'result_screen.dart';


class UploadHandler implements VideoPicker {
  @override
  Future<PickedVideo?> pickVideo() async {
    final completer = Completer<PickedVideo?>();
    final input = html.FileUploadInputElement();
    input.accept = 'video/*';
    input.click();
    input.onChange.listen((event) {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        final data = reader.result as Uint8List;
        completer.complete(PickedVideo(name: file.name, video: data));
      });
    });
    return completer.future;
  }
}
