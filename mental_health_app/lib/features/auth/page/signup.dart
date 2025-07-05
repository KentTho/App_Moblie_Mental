import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mental_health_app/wrapper.dart';



class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {


  TextEditingController email     = TextEditingController();
  TextEditingController password  = TextEditingController();


  Future<void> signUp()async{
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
    Get.offAll(Wrapper());
  }  



  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}