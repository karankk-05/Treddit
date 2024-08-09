import 'package:flutter/material.dart';
import '../../../theme/decorations.dart';
import '../services/add_product_service.dart';
import '../services/image_service.dart';
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
  final ImageService _imageService = ImageService();

  List<Map<String, dynamic>> _images = [];

  Future<void> _pickImages() async {
    final images = await _imageService.pickAndCompressImages();
    setState(() {
      _images = images;
    });
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
                    icon: const Icon(Icons.add_a_photo),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _pickImages,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Product Title'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Product Price'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Product Details'),
              ),
              const SizedBox(
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
                                  icon: const Icon(
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
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(Size(100, 60)),
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).colorScheme.secondaryContainer,
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
