import 'package:flutter/material.dart';


Color categoryColor(int category){
  return [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.purple,
    Colors.teal,
    Colors.lime,
    Colors.pink,
    Colors.indigo
  ][category % 10];
}