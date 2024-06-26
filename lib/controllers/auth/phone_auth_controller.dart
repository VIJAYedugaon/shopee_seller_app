import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopee_seller_app/views/screens/auth/otp_verification_screen.dart';
import 'package:shopee_seller_app/views/screens/home/home_screen.dart';
import 'package:shopee_seller_app/views/screens/profile/registration_screen.dart';
import 'package:shopee_seller_app/views/utils/app_colors/app_colors.dart';
import 'package:shopee_seller_app/views/utils/app_extensions/app_extensions.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  static phoneAuth(String number, BuildContext context) {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number,
      verificationCompleted: (c) {},
      verificationFailed: (f) {},
      codeSent: (verificationId, forceResendingToken) {
        context.pushReplace(OtpVerificationScreen(verificationId: verificationId));
      },
      codeAutoRetrievalTimeout: (v) {},
    );
  }

  static otpVerification(
      {required BuildContext context, required String smsCode, required String verificationId}) {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    FirebaseAuth.instance.signInWithCredential(credential).whenComplete(() {
      if(FirebaseAuth.instance.currentUser?.uid != null){
        context.showSnackBar(title: "Otp: ", message: ' verification completed', color: AppColor.dark);
       navigateUser(uid: FirebaseAuth.instance.currentUser?.uid);
      }
    });
  }

  static void navigateUser({String? uid}) async{
   var data = await FirebaseFirestore.instance.collection('Seller_Profile').doc(uid).get();
   if(data.exists){
     Get.offAll(()=>HomeScreen());
   }else{
     Get.offAll(()=>RegistrationScreen());
    }
  }


 static Future<void> signInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    var res = await FirebaseAuth.instance.signInWithCredential(credential);
    if(FirebaseAuth.instance.currentUser?.uid != null){
      context.showSnackBar(title: "Google Sign in: ", message: 'verification completed', color: AppColor.dark);
      navigateUser(uid: FirebaseAuth.instance.currentUser?.uid);
    }
  }
}
