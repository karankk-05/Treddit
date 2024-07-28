import '../auth/widgets/fields.dart';
import 'package:flutter/material.dart';
import '../../theme/decorations.dart';
import 'add_product_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AddPost extends StatefulWidget {
  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ProductService _productService = ProductService();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _images = [];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
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
      setState(() {
        _images = imagesWithSizes;
      });
    }
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

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _submit() async {
    int price = int.tryParse(_priceController.text) ?? 0;
    bool success = await _productService.addProduct(
      title: _titleController.text,
      price: price,
      description: _descriptionController.text,
      images: _images.map((image) => image['compressed'] as File).toList(),
    );
    if (success) {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Product',
          style: mytext.headingbold(fontSize: 20, context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  radius: 30,
                  child: IconButton(
                    icon: Icon(Icons.add_a_photo),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _pickImages,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Product Title'),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Product Price'),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Product Details'),
              ),
              SizedBox(
                height: 20,
              ),
              if (_images.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Image.file(
                                _images[index]['compressed'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              Positioned(
                                right: -10,
                                top: -10,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeImage(index),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(100, 60)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Colors.white),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text('Let\'s Sell',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
