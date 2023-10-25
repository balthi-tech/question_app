// singleton for toast

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// custom toast with FToast

// class CustomToast {
//   static final FToast _fToast = FToast();

//   _fToast.init(context);

//   factory CustomToast() {
//     return _fToast;
//   }

//   CustomToast._internal();

// }



// class Toast {
//   static final Toast _singleton = Toast._internal();



//   factory Toast() {
//     return _singleton;
//   }

//   Toast._internal();

//   static void show(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
// }
