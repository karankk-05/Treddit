import 'package:flutter/material.dart';
import '../../widgets/fields.dart';
import 'package:kampus_konnect/screens/pages/homepage.dart';
import '../../../app/appcolors.dart';
import '../../../app/decorations.dart';
import '../../services/auth/auth.dart';
import '../../services/auth/auth_action.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // bool? _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthActions _authActions = AuthActions();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _email() {
    
    return fields.TextField(
        controller: _emailController, label: "Registered Email", secure: false,context: context);
  }

  Widget _password() {
    
    return fields.TextField(
        controller: _passwordController, label: "Password", secure: true,context: context);
  }

  // Widget _ForgotPasswordBtn() {
  //   return Container(
  //     alignment: Alignment.centerRight,
  //     child: TextButton(
  //       onPressed: (null),
  //       child: Text(
  //         'Forgot Password?',
  //         style: kLabelStyle,
  //       ),
  //     ),
  //   );
  // }

  // Widget _RememberMeCheckbox() {
  //   return Container(
  //     height: 20.0,
  //     child: Row(
  //       children: <Widget>[
  //         Theme(
  //           data: Theme.of(context),
  //           child: Checkbox(
  //             value: _rememberMe,
  //             onChanged: (value) {
  //               setState(() {
  //                 _rememberMe = value;
  //               });
  //             }, // Or provide a callback function for onChanged
  //             checkColor: Colors.green,
  //             activeColor: Colors.white,
  //           ),
  //         ),
  //         Text(
  //           'Remember me',
  //           style: kLabelStyle,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _LoginBtn() {
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _authActions.handleLoginButton(_emailController.text.trim(),
              _passwordController.text.trim(), context);
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(100, 60)),
          backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.primaryContainer),
        ),
        child: Text('LOGIN', style: mytext.headingbold(fontSize: 18,context)),
      ),
    );
  }

  Widget _SignupBtn() {
    return GestureDetector(
      onTap: () {
        (Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => signuppage(),
          ),
        ));
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'New To Campus Ebay? ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        body: Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(gradient: gradients.login),
        ),
        // Center(
        //    child: Image.asset('assets/logo.png', height: 100, width: 50)
        //        .animate()
        //        .scale(begin:Offset(0,0) ,
        //        end: Offset(8, 8
        //        ),curve:Cubic(0.5, 0, 0, 1),
        //        duration:2000.milliseconds).fadeOut(delay: 2500.milliseconds,duration: 500.milliseconds),
        //  ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
          child: Center(
              child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                // Transform.scale(
                //     scale: 2.5,
                //     child: Image.asset('assets/logo_star.png',
                //         height: 100, width: 50))
                //  .animate()
                //  .fadeIn(delay: 2600.milliseconds,)
                // ,
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Join The Community Now',
                  style: mytext.headingbold(fontSize: 30,context),
                ),
                Expanded(child: SizedBox()),
                _email(),
                SizedBox(
                  height: 30.0,
                ),
                _password(),
                // _ForgotPasswordBtn(),
                // _RememberMeCheckbox(),
                _LoginBtn(),
                _SignupBtn()
              ],
            ),
          )),
        )
      ],
    ));
  }
}
