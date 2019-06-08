import 'dart:convert';
import 'package:flutter/material.dart';
import '../util/utils.dart' as util;
import 'dart:async';
import 'package:http/http.dart' as http;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  String _cityEntererd;

  Future _goNext(BuildContext context) async {
    Map results = await Navigator.of(context)
        .push(new MaterialPageRoute<Map>(builder: (BuildContext context) {
      return new ChangeCity();
    }));
    if (results != null && results.containsKey('enter')) {
//      print(results['enter'].toString());
      _cityEntererd = results['enter'].toString();
    }
    else{
      print("Empty");
    }
  }

  void showStuff() async {
    Map data = await getWeather(util.apiID, util.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Klimatic', style: new TextStyle(color: Colors.red)),
          backgroundColor: Colors.white70,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(
                  Icons.menu,
                  color: Colors.red,
                ),
                onPressed: () {
                  _goNext(context);
                }),
          ],
        ),
        body: new Stack(
          children: <Widget>[
            new Center(
              child: new Image.asset(
                'images/umbrella.png',
                width: 500,
                height: 1200,
                fit: BoxFit.fill,
              ),
            ),
            new Container(
              alignment: Alignment.topRight,
              margin: const EdgeInsets.fromLTRB(0.0, 15, 23, 0.0),
              child: new Text(
                '${_cityEntererd == null ? util.defaultCity : _cityEntererd}',
                style: cityStyle(),
              ),
            ),
            new Container(
                alignment: Alignment.center,
                child: new Image.asset('images/light_rain.png')),
            new Container(
                margin: const EdgeInsets.fromLTRB(50, 370, 0, 0),
                child: updateTempWidget("$_cityEntererd")),
          ],
        ));
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&APPID=${util.apiID}&units=metric';
    http.Response response = await http.get(apiUrl);
    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return new FutureBuilder(
        future: getWeather(util.apiID, city == null ? util.defaultCity : city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          if (snapshot.hasData) {
            Map content = snapshot.data;
            return new Container(
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(
                      content['main']['temp'].toString() + " C",
                      style: tempStyle(),
                    ),
                    subtitle: new ListTile(
                      title: new Text(
                        "Humidity: ${content['main']['humidity'].toString()}\n"
                            "Min: ${content['main']['temp_min'].toString()} C\n"
                            "Max: ${content['main']['temp_max'].toString()} C",
                        style: newStyle(),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return new Container();
          }
        });
  }
}

class ChangeCity extends StatelessWidget {
  var _cityController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.white70,
          title: new Text(
            'Change City',
            style: new TextStyle(color: Colors.red),
          ),
          centerTitle: true,
        ),
        body: new Stack(children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/white_snow.png',
              width: 500,
              height: 1200,
              fit: BoxFit.fill,
            ),
          ),
          new ListView(
            children: <Widget>[
              new ListTile(
                title: new TextField(
                  decoration: new InputDecoration(hintText: 'Enter City'),
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                ),
              ),
              new ListTile(
                title: new FlatButton(
                  onPressed: () {
                    Navigator.pop(context, {'enter': _cityController.text});
                  },
                  child: new Text('Get Weather'),
                  color: Colors.red,
                  textColor: Colors.white70,
                ),
              ),
            ],
          )
        ]));
  }
}

TextStyle cityStyle() {
  return new TextStyle(
      color: Colors.white70, fontSize: 30, fontStyle: FontStyle.italic);
}

TextStyle tempStyle() {
  return new TextStyle(
      color: Colors.white,
      fontSize: 50.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500);
}

TextStyle newStyle() {
  return new TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400);
}
