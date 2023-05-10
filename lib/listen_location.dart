import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:open_gate/mqtt_thing.dart';

class ListenLocationWidget extends StatefulWidget {
  const ListenLocationWidget({Key? key}) : super(key: key);

  @override
  _ListenLocationState createState() => _ListenLocationState();
}

class _ListenLocationState extends State<ListenLocationWidget> {
  final Location location = Location();
  var distance = Distance();
  bool wasEver1000plus=false;
  bool wasEverPlayed=false;

  LocationData? _location;
  int _meter=0;
  StreamSubscription<LocationData>? _locationSubscription;
  String? _error;

  late AudioPlayer player;
  @override
  void initState()  {
    super.initState();
    player = AudioPlayer();
  }





  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((dynamic err) {
      if (err is PlatformException) {
        setState(() {
          _error = err.code;
        });
      }
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((LocationData currentLocation) async {
      print("========= .listen() ");
      _meter = await calcDistance();//you cant put this inside setState cz if u make setState async it doesnot update.
      setState(() {
        _error = null;
        _location = currentLocation;
        print("xxxxxxxxxx .listen() SETSTATE() .........");
      });
    });
    setState(() {});
  }

  Future<void> _stopListen() async {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(//to avoid overflow of the text from location coordinates
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'location: ' + (_error ?? '${_location ?? "unknown"}'),
            style: Theme.of(context).textTheme.bodyText1,
          ),

          Text('Distance:  $_meter',style: TextStyle(fontSize: 24),),
          Text('$wasEver1000plus | $wasEverPlayed',style: TextStyle(fontSize: 24),),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: const Text('Listen'),
                onPressed:
                    _locationSubscription == null ? _listenLocation : null,
              ),
              ElevatedButton(
                child: const Text('Stop'),
                onPressed: _locationSubscription != null ? _stopListen : null,
              ),
              ElevatedButton(
                child: const Text('Play'),
                onPressed: () {
                    doit();
                }
              )
            ],
          ),
        ],
      ),
    );
  }

  doit() async {
    await player.setAsset('assets/audio/opening.ogg');
    player.play();
  }

  Future<int> calcDistance()  async { //(home , newLocation). casted to int
    print("=============calDistance");
    int d =0;
    if(_location!=null && _location?.longitude != null) {
      d = distance(LatLng(54.642142, 25.339019),LatLng(_location!.latitude!, _location!.longitude!)).toInt();
      if (d > 200) { wasEver1000plus = true; wasEverPlayed = false; }
      else if (d < 180 && d > 120 && wasEver1000plus == true && wasEverPlayed == false) {
        wasEverPlayed = true;
        Mqtt_Thing obj = Mqtt_Thing();
        await obj.doThePub();
        await player.setAsset('assets/audio/opening.ogg');
        player.play();
      }
      else if (d < 50) { wasEver1000plus = false;  wasEverPlayed = false; }
    }
    print("returned $d");
  return d;
  }
}
