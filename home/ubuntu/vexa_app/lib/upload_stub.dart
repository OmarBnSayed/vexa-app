import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'upload_interface.dart';
import 'result_screen.dart';

class UploadHandler implements VideoPicker {
  @override
  Future<PickedVideo?> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      final file = File(result.files.single.path!);
      return PickedVideo(name: result.files.single.name, video: file);
    }
    return null;
  }
}
