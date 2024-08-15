import 'dart:async';

import 'package:flutter/material.dart';
import 'package:Treddit/nav/nav_bar.dart';
import 'package:provider/provider.dart';
import '../models/my_posts_model.dart';
import '../services&providers/my_posts_provider.dart';
import '../../auth/services/auth.dart';

class EditPostDetailsPage extends StatefulWidget {
  final Product product;

  EditPostDetailsPage({required this.product});

  @override
  _EditPostDetailsPageState createState() => _EditPostDetailsPageState();
}

class _EditPostDetailsPageState extends State<EditPostDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _priceController;
  late String? _email;
  late String? _token;

  @override
  void initState() {
    super.initState();
    _fetchCredentials();
    _titleController = TextEditingController(text: widget.product.title);
    _bodyController = TextEditingController(text: widget.product.body);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _fetchCredentials() async {
    _email = await _authService.getEmail();
    _token = await _authService.getToken();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      Provider.of<MyPostsProvider>(context, listen: false)
          .editProduct(
        widget.product.id,
        _titleController.text,
        _bodyController.text,
        int.parse(_priceController.text),
        widget.product.isSold,
        _email ?? "",
        _token ?? "",
      )
          .then((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainPage(
            selectedIndex: 1,
          ),
        ));
      });
    }
  }

  Widget _SaveDetailsBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _saveForm();
        },
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(Size(100, 60)),
          backgroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondaryContainer),
        ),
        child: Text(
          'Update',
          style: TextStyle(fontSize: 17),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(labelText: 'Body'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a body';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _SaveDetailsBtn(),
            ],
          ),
        ),
      ),
    );
  }
}
