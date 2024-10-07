import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Image picking
import 'package:flutter_image_compress/flutter_image_compress.dart'; // For image compression

// ImageService class for picking and compressing images
class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<List<Map<String, dynamic>>> pickAndCompressImages() async {
    if (kIsWeb) {
      return _pickImagesForWeb();
    } else {
      return _pickAndCompressImagesForMobile();
    }
  }

  // Web-specific image picking
  Future<List<Map<String, dynamic>>> _pickImagesForWeb() async {
    final pickedFiles = await _picker.pickMultiImage();
    List<Map<String, dynamic>> imagesWithDetails = [];

    if (pickedFiles != null) {
      for (var pickedFile in pickedFiles) {
        final byteData = await pickedFile.readAsBytes();
        imagesWithDetails.add({
          'original': byteData, // Store as Uint8List
          'filename': pickedFile.name, // Store the filename
        });
      }
    }

    return imagesWithDetails;
  }

  // Mobile-specific image picking and compression
  Future<List<Map<String, dynamic>>> _pickAndCompressImagesForMobile() async {
    final pickedFiles = await _picker.pickMultiImage();
    List<Map<String, dynamic>> imagesWithDetails = [];

    if (pickedFiles != null) {
      for (var pickedFile in pickedFiles) {
        File originalImage = File(pickedFile.path);
        File? compressedImage = await _compressImage(originalImage);
        if (compressedImage != null) {
          imagesWithDetails.add({
            'original': originalImage,
            'compressed': compressedImage,
            'filename':originalImage.path, // Store the filename
          });
        }
      }
    }

    return imagesWithDetails;
  }

  // Compression for mobile
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
