import 'package:pocketbase/pocketbase.dart';

const String env = "local";
const String appName = "Factual";
const String appVersion = "0.0.1";
const String backendUrlAndroid = 'http://10.0.2.2:8090';
const String fatalError = "Oops, something went wrong. Please try again later.";
const Duration snackBarShort = env == "local" ? Duration(seconds: 5) : Duration(seconds: 1);
const Duration snackBarMedium = env == "local" ? Duration(seconds: 5) : Duration(seconds: 2);
const Duration snackBarLong = env == "local" ? Duration(seconds: 5) : Duration(seconds: 5);

String errorMessage(ClientException e) {
  if (env == 'production') return fatalError;

  return e.response['message'] ?? fatalError;
}