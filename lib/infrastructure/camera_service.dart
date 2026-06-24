import 'package:image_picker/image_picker.dart';

class CameraService {
  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// カメラで撮影した画像のパスを返す。
  /// キャンセル時は null を返す。
  Future<String?> takePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    return file?.path;
  }

  /// ギャラリーから選択した画像のパスを返す。
  /// キャンセル時は null を返す。
  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    return file?.path;
  }
}
