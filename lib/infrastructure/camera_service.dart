import 'package:image_picker/image_picker.dart';

class CameraService {
  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const _imageQuality = 85;

  /// カメラで撮影した画像のパスを返す。
  /// キャンセル時は null を返す。
  Future<String?> takePhoto() => _pickImage(ImageSource.camera);

  /// ギャラリーから選択した画像のパスを返す。
  /// キャンセル時は null を返す。
  Future<String?> pickFromGallery() => _pickImage(ImageSource.gallery);

  Future<String?> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: _imageQuality,
    );
    return file?.path;
  }
}
