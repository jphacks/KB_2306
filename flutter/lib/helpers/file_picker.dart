import 'package:file_picker/file_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final filePickerHelperProvider =
    Provider<FilePickerHelper>((ref) => const FilePickerHelper());

class FilePickerHelper {
  const FilePickerHelper();

  FilePicker get _filePicker => FilePicker.platform;

  Future<PlatformFile?> _pickFile({
    required List<String> allowedExtensions,
  }) async {
    final result = await _filePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null) {
      return null;
    }
    if (result.files.isEmpty) {
      return null;
    }
    return result.files.first;
  }

  Future<PlatformFile?> pickAudio() => _pickFile(
        allowedExtensions: [
          // TODO: 動作検証して対応ファイルを増やす
          'mp3',
          'wav',
        ],
      );
}
