import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:io';
import 'package:mailer2/mailer.dart';

// DEPENDENCIES
// flutter_email_sender: ^5.0.2

// Widget Shortcuts

// Network Operations

sendMail() {
  var options = new GmailSmtpOptions()
    ..username = 'geekysharma31@gmail.com'
    ..password = '@Geeky4863#--lotion#sonu';

  var emailTransport = new SmtpTransport(options);

  // Create our mail/envelope.
  var envelope = new Envelope()
    ..recipients.add('geekysharma31@gmail.com')
    ..from = 'geekysharma31@gmail.com'
    ..subject = 'Testing the Dart Mailer library'
    ..text = 'This is a cool email message. Whats up? 語'
    ..html = '<h1>Test</h1><p>Hey!</p>';

  // Email it.
  emailTransport
      .send(envelope)
      .then((envelope) => print('Email sent!'))
      .catchError((e) => print('Error occurred: $e'));
}

sendEmail(subject, body, uEmail) async {
  Email email = Email(
    body: body,
    subject: subject,
    recipients: [uEmail],
    isHTML: true,
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
