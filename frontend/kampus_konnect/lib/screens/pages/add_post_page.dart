import '../../widgets/fields.dart';
import 'package:flutter/material.dart';
import '../../app/decorations.dart';

class AddPost extends StatefulWidget {
  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final _nameController = TextEditingController();
  final _bodyController = TextEditingController();
  final _priceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    mytext.context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Product',
          style: mytext.headingbold(fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              fields.TextField(
                label: 'Product Name',
                controller: _nameController,
              ),
              SizedBox(
                height: 20,
              ),
              fields.TextField(
                label: 'Product Price',
                controller: _priceController,
              ),
              SizedBox(
                height: 20,
              ),
              fields.TextField(
                label: 'Product Details',
                controller: _bodyController,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Container(
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        maximumSize: MaterialStateProperty.all(Size(200, 100)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primaryContainer,
                        ),
                        side: MaterialStateProperty.all<BorderSide>(
                          BorderSide(color: Colors.white),
                        ),
                      ),
                      onPressed: null,
                      child: Text(
                        'Add Images',
                        style: mytext.headingtext1(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
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
                      onPressed: null,
                      child: Text('Save Product',
                          style: mytext.headingtext1(fontSize: 15)),
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
