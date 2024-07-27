import '../auth/widgets/fields.dart';
import 'package:flutter/material.dart';
import '../../app/decorations.dart';
import 'add_product_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  List<File> _images = [];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images =
            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  Future<void> _submit() async {
    int price = int.tryParse(_priceController.text) ?? 0;
    bool success = await _productService.addProduct(
      title: _titleController.text,
      price: price,
      description: _descriptionController.text,
      images: _images,
    );
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Product added successfully')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add product')));
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
              fields.TextField(
                  label: 'Product Title',
                  controller: _titleController,
                  context: context),
              SizedBox(
                height: 20,
              ),
              fields.TextField(
                  label: 'Product Price',
                  controller: _priceController,
                  context: context),
              SizedBox(
                height: 20,
              ),
              fields.TextField(
                  label: 'Product Details',
                  controller: _descriptionController,
                  context: context),
              SizedBox(
                height: 20,
              ),
              if (_images.isNotEmpty)
                GridView.count(
                  crossAxisSpacing: 10,
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: _images.map((image) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(Size(100, 60)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.primaryContainer),
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(color: Colors.white),
                        ),
                      ),
                      onPressed: _pickImages,
                      child: Text(
                        'Add Images',
                        style: mytext.headingtext1(fontSize: 15, context),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        maximumSize: MaterialStateProperty.all(Size(200, 120)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primaryContainer,
                        ),
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(color: Colors.white),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text('Save Product',
                          style: mytext.headingtext1(fontSize: 15, context)),
                    ),
                  ),
                  Expanded(child: SizedBox())
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
