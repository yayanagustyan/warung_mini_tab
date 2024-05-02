import 'dart:convert';

String envy = 'dev';
// String envy = 'prod';

getEnvy() {
  return envy;
}

String getBaseUrl() {
  if (getEnvy() == "dev") {
    String local = "http://192.168.1.100:1122";
    // return "http://$local/app_project/np/warung";
    return local;
  } else {
    return "https://warung.mookaps.com";
  }
}

String getApiUrl() {
  return "${getBaseUrl()}/api";
}

// String getBasicAuth() {
//   return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
// }

String getBase64Encode(String source) {
  return 'Basic ${base64Encode(utf8.encode(source))}';
}
