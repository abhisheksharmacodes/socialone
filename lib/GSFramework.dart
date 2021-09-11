import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:io';

// DEPENDENCIES
// flutter_email_sender: ^5.0.2

// Widget Shortcuts

// Network Operations

sendEmail(subject, body, uEmail) async {
  Email email = Email(
    body: body,
    subject: subject,
    recipients: [uEmail],
  );

  bool platformResponse;

  try {
    await FlutterEmailSender.send(email);
    platformResponse = true;
  } catch (error) {
    platformResponse = false;
  }

  return (platformResponse);
}

isConnected() async {
  try {
    final result = await InternetAddress.lookup('www.google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }
}

emailValidation(String email) {
  if (email.length != 0) {
    if (RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return null;
    } else {
      return "Enter a valid emailCtrl";
    }
  }
}


// NOTES

// UNFOCUS FIELD
/*FocusScopeNode currentFocus = FocusScope.of(context);
currentFocus.unfocus();*/
