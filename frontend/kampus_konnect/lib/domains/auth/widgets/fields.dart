

import 'package:flutter/material.dart';
import '../../../theme/decorations.dart';
class fields {
  static Widget TextField({
    required BuildContext context, // Add BuildContext parameter here
    TextEditingController? controller,
    required String label,
    bool? secure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: mydeco.deco(context), // Pass the context here
          height: 60.0,
          child: TextFormField(
            cursorColor: Colors.white,
            controller: controller,
            obscureText: secure ?? false,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.white,
              ),
              hintText: 'Enter your $label',
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }
}
