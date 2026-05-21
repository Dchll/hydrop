import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hydrop/gen/colors.gen.dart';

class TransientFeedback {
  const TransientFeedback._();

  static Future<void> show(BuildContext context, String message) async {
    if (_usesPlatformToast) {
      await Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: ColorName.black,
        textColor: ColorName.lightBackground,
        fontSize: 14,
      );
      return;
    }

    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static bool get _usesPlatformToast {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }
}
