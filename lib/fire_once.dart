import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:open_gate/mqtt_thing.dart';

class FireOnceWidget extends StatefulWidget {
  const FireOnceWidget({Key? key}) : super(key: key);

  @override
  _FireOnceState createState() => _FireOnceState();
}

class _FireOnceState extends State<FireOnceWidget> {
  bool isDone=false;
  bool isDoing=false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text("Fired: $isDone",style: Theme.of(context).textTheme.bodyText1),
        Row(
          children: <Widget>[
            ElevatedButton(
              child: isDoing ? const CircularProgressIndicator( color: Colors.white,) : const Text('Fire'),
              onPressed: () async{
                setState(() { isDoing = true;});
                await FireOnceOpenGate();
                },
            )
          ],
        ),
      ],
    );
  }

  Future<void> FireOnceOpenGate() async {
    Mqtt_Thing obj = Mqtt_Thing();
    await obj.doThePub();

    isDone=true;
    setState(() {isDoing = false; });
    return;
  }
  
}
