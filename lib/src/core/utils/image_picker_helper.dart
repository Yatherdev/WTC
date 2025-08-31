import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> pickAndSaveAvatar() async {
  final picker = ImagePicker();
  final res = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800, maxHeight: 800);
  if (res == null) return null;
  final dir = await getApplicationDocumentsDirectory();
  final newPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${res.name}';
  final file = await File(res.path).copy(newPath);
  return file.path;
}