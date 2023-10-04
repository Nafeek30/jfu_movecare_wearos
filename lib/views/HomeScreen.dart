import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jfu_movecare_wearos/views/LoginScreen.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _isCollecting = false;
  String _message = "";
  var aX;
  var aY;
  var aZ;
  var gX;
  var gY;
  var gZ;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "MoveCare",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'aX: ${aX == null ? '0' : aX.toStringAsFixed(3)}, aY: ${aY == null ? '0' : aY.toStringAsFixed(3)}, aZ: ${aZ == null ? '0' : aZ.toStringAsFixed(3)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'gX: ${gX == null ? '0' : gX.toStringAsFixed(3)}, gY: ${gY == null ? '0' : gY.toStringAsFixed(3)}, gZ: ${gZ == null ? '0' : gZ.toStringAsFixed(3)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    _isCollecting ? 'Stop' : 'Start',
                    style: TextStyle(
                      color: Colors.greenAccent.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isCollecting) {
                        _isCollecting = false;
                        _message = "Data saved!";
                      } else {
                        _isCollecting = true;
                        _message = "Collecting data...";
                      }
                    });
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.redAccent.shade200,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    logout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getData() {
    accelerometerEvents.listen((event) {
      setState(() {
        aX = event.x;
        aY = event.y;
        aZ = event.z;
      });
    });

    gyroscopeEvents.listen((event) {
      gX = event.x;
      gY = event.y;
      gZ = event.z;
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut().then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }
}
