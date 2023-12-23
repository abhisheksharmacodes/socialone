import 'package:flutter/material.dart';

Widget appCard(imgUrl, func) {
  return GestureDetector(
    onTap: () {
      func();
    },
    child: Container(
        height: 200,
        width: 140,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 0),
                blurRadius: 5.0,
                spreadRadius: 1.5,
                color: Colors.grey,
              )
            ],
            image: DecorationImage(image: new NetworkImage(imgUrl)))),
  );
}
