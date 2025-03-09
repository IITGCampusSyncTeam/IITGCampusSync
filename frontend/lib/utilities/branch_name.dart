
import 'package:flutter/material.dart';

String calculateBranch(String rollNumber) {


  final branchCode = rollNumber.substring(4, 6);

  switch (branchCode) {
    case "06":
      return "Biosciences and Bioengineering";
    case "07":
      return "Chemical Engineering";
    case "22":
      return "Chemical Science and Technology";
    case "04":
      return "Civil Engineering";
    case "01":
      return "Computer Science and Engineering";
    case "50":
      return "Data Science and Artificial Intelligence";
    case "02":
      return "Electronics and Communication Engineering";
    case "08":
      return "Electronics and Electrical Engineering";
    case "21":
      return "Engineering Physics";
    case "23":
      return "Mathematics and Computing";
    case "03":
      return "Mechanical Engineering";
    case "51":
      return "Energy Engineering";
    default:
      return "Unknown Branch";
  }
}