import 'package:flutter/material.dart';

class CardInfo {
  final String? title, totalStorage;
  final int? numOfFiles, percentage;
  final Color? color;

  CardInfo({
    this.title,
    this.totalStorage,
    this.numOfFiles,
    this.percentage,
    this.color,
  });
}