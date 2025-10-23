import 'dart:developer';
import 'package:pocketbase/pocketbase.dart';

const String env = "local";
const String appName = "Factual";
const String appVersion = "0.0.1";
const String backendUrlAndroid = 'http://10.0.2.2:8090';
const String fatalError = "Oops, something went wrong. Please try again later.";
const String defaultAvatar = 'https://i.pravatar.cc/300';
const Duration snackBarShort = Duration(seconds: 1, milliseconds: 500);
const Duration snackBarMedium = Duration(seconds: 3);
const Duration snackBarLong = Duration(seconds: 5);

String errorClient(ClientException e) {
  log(e.toString());
  if (env == 'production') return fatalError;

  return e.response['message'] ?? fatalError;
}

String errorFatal(Exception e) {
  log(e.toString());
  
  return fatalError;
}