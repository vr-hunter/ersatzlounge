import 'dart:io';

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'dart:convert' show json;
import 'package:uuid/uuid.dart';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

const String VW_GLOBAL_CONFIG_URL = "https://www.volkswagen.de/de.global-config.json";
const String VEHICLE_DATA_PATH = "https://myvw-gvf-proxy.apps.emea.vwapps.io/vehicleData/de-DE/";
const String MY_VEHICLES_URL = "https://vum.apps.emea.vwapps.io/users/me/vehicles";
const String LOUNGE_URL = "https://www.volkswagen.de/de/besitzer-und-nutzer/myvolkswagen/volkswagen-lounge.html";
const String LOGIN_URL = "https://www.volkswagen.de/app/authproxy/login?fag=vw-de,vw-ag-direct-sales,vwag-weconnect&scope-vw-de=profile,address,phone,carConfigurations,dealers,cars,vin,profession&scope-vw-ag-direct-sales=address,phone,profile&scope-vwag-weconnect=openid,mbb&prompt-vw-ag-direct-sales=none&prompt-vwag-weconnect=none&redirectUrl=https://www.volkswagen.de/de/besitzer-und-nutzer/myvolkswagen/volkswagen-lounge.html";
const String TOKEN_URL = "https://www.volkswagen.de/app/authproxy/vw-de/tokens";
const String LOUNGE_CARS_URL = "https://myvwde.cloud.wholesaleservices.de/api/waiting-lounge/cars";
const String TBO_CARS_URL = "https://myvwde.cloud.wholesaleservices.de/api/tbo/cars";
const String RELATIONS_URL_V2 = "https://vum.apps.emea.vwapps.io/v2/users/me/relations";
const String RELATIONS_URL_V1 = "https://vum.apps.emea.vwapps.io/v1/dataStorageManagement/users/me/relations";
const String VW_IDENTITY_HOST = "https://identity.vwgroup.io";
const String VW_HOST = "https://www.volkswagen.de";

class VWCar{
  String? _nickname;
  String? _vin;
  String? _commID;
  String? _orderStatus;
  String? _ddType;
  String? _ddValue;
  bool _hasLoungeData = false;

  Map<dynamic, dynamic> rawDataRelation = {};
  Map<dynamic, dynamic> rawDataLounge = {};

  VWCar.fromRelation(this.rawDataRelation){
    try {
      _nickname = rawDataRelation["vehicleNickname"];
      _vin = rawDataRelation["vehicle"]["vin"];
      _commID = rawDataRelation["vehicle"]["commissionId"];
    }catch(e){
      throw APIException("Couldn't find fields in API response.");
    }
  }

  VWCar(this.rawDataRelation, this.rawDataLounge){
    try {
      _nickname = rawDataRelation["vehicleNickname"];
      _vin = rawDataRelation["vehicle"]["vin"];
      _commID = rawDataRelation["vehicle"]["commissionId"];
      _orderStatus = rawDataLounge["orderStatus"];
      _ddType = rawDataLounge["deliveryDateType"];
      _ddValue = rawDataLounge["deliveryDateValue"];
    }catch(e){
      throw APIException("Couldn't find fields in API response.");
    }
    _hasLoungeData = true;
  }

  get nickname{
    return _nickname ?? "null";
  }

  get vin{
    return _vin ?? "null";
  }

  get commID{
    return _commID ?? "null";
  }

  get orderStatus{
    return _orderStatus ?? "null";
  }

  get deliveryDateType{
    return _ddType ?? "null";
  }

  get deliveryDateValue{
    return _ddValue ?? "null";
  }

  get hasLoungeData{
    return _hasLoungeData;
  }
}

class ConnectionException implements Exception{
  String cause;
  ConnectionException(this.cause);

  @override
  String toString() {
    return "Connection Error: $cause";
  }
}

class APIException implements Exception{
  String cause;
  APIException(this.cause);

  @override
  String toString() {
    return "API Error: $cause";
  }
}

class VWConnector {
  String vwIdEmail;
  String vwIdPassword;

  bool loggedIn = false;


  String? _idToken;
  String? _accessToken;
  DateTime? tokenExpiration;

  List<VWCar> _cars = [];

  Function? _statusCallback;
  String _status = "";

  var dio =  Dio();
  var cookieJar=CookieJar();


  VWConnector(this.vwIdEmail, this.vwIdPassword)
  {
    dio.interceptors.add(CookieManager(cookieJar));
    dio.options.followRedirects = false;
    dio.options.maxRedirects = 30;
    dio.options.validateStatus = (status) { if(status == null) return false; return status < 400; };
  }

  set statusCallback(Function f)
  {
    _statusCallback = f;
  }

  get status{
    return _status;
  }

  get access_token{
    getAccessToken();
    if(_accessToken == null){
      throw ConnectionException("Couldn't retrieve tokens");
    } else {
      return _accessToken!;
    }
  }

  get id_token{
    getAccessToken();
    if(_idToken == null){
      throw ConnectionException("Couldn't retrieve tokens");
    } else {
      return _idToken!;
    }
  }

  _setStatus(String status){
    _status = status;
    if(_statusCallback != null){
      _statusCallback!(status);
    }
  }

  clear() async{
    await cookieJar.deleteAll();
  }

  Future<Response> redirectingGET(String path, {Map<String, dynamic>? queryParameters,}) async
  {
    Response r = await dio.get(path, queryParameters: queryParameters);
    while(r.statusCode == 302 && r.headers.map["Location"]?[0] != null){
      String location = r.headers.map["Location"]?[0]??"";
      if(location.startsWith("/")){
        location = "${r.realUri.host}$location";
      }
      r = await dio.get(location, queryParameters: queryParameters);
    }
    return r;
  }

  Future<Response> redirectingPOST(String path, {data,Map<String, dynamic>? queryParameters,}) async
  {
    Response r = await dio.post(path,data: data, queryParameters: queryParameters);
    while([302, 303].contains(r.statusCode) && r.headers.map["Location"]?[0] != null){
      String location = r.headers.map["Location"]?[0]??"";
      if(location.startsWith("/")){
        location = "${r.realUri.scheme}://${r.realUri.host}$location";
      }
      r = await dio.get(location, queryParameters: queryParameters);
    }
    return r;
  }

  Future<bool> login() async{
    await clear();
    loggedIn = false;

    _setStatus("Logging in");
    Response data = await redirectingGET(LOGIN_URL);
    if((data.statusCode ?? 999) >= 400) {
      throw ConnectionException("Couldn't get login page");
    }
    Document p = parse(data.data);
    String? csrf = p.getElementById("csrf")?.attributes["value"];
    String? relay_state = p.getElementById("input_relayState")?.attributes["value"];
    String? hmac = p.getElementById("hmac")?.attributes["value"];
    String? url = p.getElementById("emailPasswordForm")?.attributes["action"];

    if(csrf == null || relay_state == null  || hmac == null || url == null) {
      throw ConnectionException("Error parsing login page");
    }

    // Enter Email
    Map<String,String> params = {"_csrf": csrf, "relayState": relay_state, "hmac": hmac, "email": vwIdEmail};
    data = await redirectingPOST("$VW_IDENTITY_HOST$url", data: FormData.fromMap(params));
    if((data.statusCode ?? 999) >= 400) {
      throw ConnectionException("Couldn't get login page 2");
    }
    p = parse(data.data);
    csrf = p.getElementById("csrf")?.attributes["value"];
    relay_state = p.getElementById("input_relayState")?.attributes["value"];
    hmac = p.getElementById("hmac")?.attributes["value"];
    url = p.getElementById("credentialsForm")?.attributes["action"];

    if(csrf == null || relay_state == null  || hmac == null || url == null) {
      if(p.getElementById("emailPasswordForm") != null){
        throw ConnectionException("User not found. Please use a valid VW ID.");
      }
      else {
        throw ConnectionException("Error parsing login page");
      }
    }

    // Enter password
    params = {"_csrf": csrf, "relayState": relay_state, "hmac": hmac, "email": vwIdEmail, "password": vwIdPassword};
    data = await redirectingPOST("$VW_IDENTITY_HOST$url", data: FormData.fromMap(params));
    p = parse(data.data);
    if((data.statusCode ?? 999) >= 400) {
      throw ConnectionException("Couldn't get login page 2");
    }

    if(p.getElementById("credentialsForm") != null){
      throw ConnectionException("Incorrect password. Please use a valid VW ID.");
    }

    String? epf_action = p.getElementById("emailPasswordForm")?.attributes["action"];
    if(epf_action != null && epf_action.contains("terms-and-conditions")){
      throw ConnectionException("Please log in to your VW account using the website. There may be new terms and conditions to accept before you can continue using this app.");
    }

    loggedIn = true;
    return loggedIn;
  }

  Future<bool> getAccessToken() async{
    if(tokenExpiration != null){
      if (tokenExpiration!.isAfter(DateTime.now())){
        return true;
      }
    }
    // Get tokens
    _setStatus("Getting bearer tokens");
    String csrf = "";
    List<Cookie> cookies = await cookieJar.loadForRequest(Uri.parse(LOUNGE_URL));
    for (Cookie cookie in cookies){
      if(cookie.name == "csrf_token"){
        csrf = cookie.value;
      }

    }

    Map<String, String> headers = {"X-CSRF-TOKEN": csrf};
    Response data;

    data = await dio.get(TOKEN_URL,
        options: Options(headers: headers, responseType: ResponseType.plain));


    Map decoded = json.decode(data.data);
    if(!decoded.containsKey("access_token") || !decoded.containsKey("id_token")){
      throw ConnectionException("Couldn't get tokens.");
    }

    _accessToken = decoded["access_token"] ;
    _idToken = decoded["id_token"];
    tokenExpiration = DateTime.now().add(Duration(minutes: 59));
    return true;
  }

  Future<List<VWCar>?> getCars() async{
    if(!loggedIn){
      await login();
    } else {
      // Refresh the session
      _setStatus("Refreshing the session");
      await redirectingGET(LOUNGE_URL);
    }

    try {
      await getAccessToken();
    } catch(e) {
      // retry once
      await login();
      await getAccessToken();
    }

    Map<String,String> authHeaders = {"Authorization": "Bearer $_accessToken", "traceId": Uuid().v4()};
    
    // get relations API
    _setStatus("Getting relations API");
    Response relationsResponse = await dio.get(RELATIONS_URL_V2, options: Options(headers: authHeaders, responseType: ResponseType.plain));
    if(relationsResponse.statusCode != 200){
      throw ConnectionException("Couldn't get relations API.");
    }

    // get lounge API
    _setStatus("Getting lounge API");
    Response loungeResponse = await dio.get(LOUNGE_CARS_URL, options: Options(headers: authHeaders, responseType: ResponseType.plain));
    if(loungeResponse.statusCode != 200){
      throw ConnectionException("Couldn't get lounge API.");
    }

    _setStatus("Parsing data");
    List<dynamic> loungeData;
    Map<dynamic, dynamic> relationsResponseData;
    try{
      loungeData = json.decode(loungeResponse.data);
      relationsResponseData = json.decode(relationsResponse.data);
    } catch(e){
      throw APIException("Couldn't map API response.");
    }

    
    if(!relationsResponseData.containsKey("relations")){
        throw APIException("Malformed relations API response.");
    }
    List relationsData = relationsResponseData["relations"];

    _cars = [];

    List<String> nicknames = [];

    for( var relationsRecord in relationsData ){
      String nickname = relationsRecord['vehicleNickname'];

      if(nicknames.contains(nickname)){
        throw APIException("Two or more vehicles registered to this VW ID have the same name. Please make sure that vehicle names are unique.");
      }
      nicknames.add(nickname);

      // find a lounge record with the same nickname
      Map? loungeRecord;
      for(var loungeEntry in loungeData){
        if(loungeEntry["name"] == nickname){
          loungeRecord = loungeEntry;
          break;
        }
      }

      if(loungeRecord == null){
        // Found no corresponding lounge entry
        _cars.add(VWCar.fromRelation(relationsRecord));
      }
      else {
        _cars.add(VWCar(relationsRecord, loungeRecord));
      }



    }


    return _cars;
  }

  

}
