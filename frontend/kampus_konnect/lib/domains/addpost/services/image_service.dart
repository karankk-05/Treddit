import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<List<Map<String, dynamic>>> pickAndCompressImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    List<Map<String, dynamic>> imagesWithSizes = [];
    for (var pickedFile in pickedFiles) {
      File originalImage = File(pickedFile.path);
      File? compressedImage = await _compressImage(originalImage);
      if (compressedImage != null) {
        imagesWithSizes.add({
          'original': originalImage,
          'compressed': compressedImage,
          'originalSize': await originalImage.length(),
          'compressedSize': await compressedImage.length(),
        });
      }
    }
    return imagesWithSizes;
     
  }

  Future<File?> _compressImage(File imageFile) async {
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      '${imageFile.path}_compressed.jpg',
      quality: 70,
      minWidth: 600,
      minHeight: 600,
    );
    return compressedFile != null ? File(compressedFile.path) : null;
  }
}
