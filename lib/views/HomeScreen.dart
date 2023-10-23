import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:jfu_movecare_wearos/views/LoginScreen.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _isCollecting = false;
  String _message = "";
  int dataCollectionFrequency = 1000;
  var aX;
  var aY;
  var aZ;
  var gX;
  var gY;
  var gZ;
  List accelData = []; // every 4 elements is its own timestamp and accel data
  List gyroData = []; // every 3 element is its own gyro data

  @override
  void initState() {
    super.initState();
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
                        getFrequency();
                        _message = "Data saved!";
                        saveData();
                      } else {
                        _isCollecting = true;
                        getFrequency();
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

  Future<void> getFrequency() async {
    FirebaseFirestore.instance
        .collection("user_collection")
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((snapshots) {
      setState(() {
        if (snapshots.docs[0].data()['sampleRate'] == 'Low') {
          dataCollectionFrequency = 1000;
        } else if (snapshots.docs[0].data()['sampleRate'] == 'Medium') {
          dataCollectionFrequency = 5000;
        } else if (snapshots.docs[0].data()['sampleRate'] == 'High') {
          dataCollectionFrequency = 10000;
        }
      });
      getData();
    });
  }

  void getData() {
    accelerometerEvents
        .throttle(Duration(milliseconds: dataCollectionFrequency))
        .listen((event) {
      setState(() {
        if (_isCollecting) {
          accelData.add({
            'time':
                '${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}_${DateTime.now().hour}_${DateTime.now().minute}_${DateTime.now().second}',
            'aX': event.x,
            'aY': event.y,
            'aZ': event.z,
          });
        }
        // print(DateTime.now().millisecondsSinceEpoch);
        aX = event.x;
        aY = event.y;
        aZ = event.z;
      });
      // print(aX);
    });

    gyroscopeEvents
        .throttle(Duration(milliseconds: dataCollectionFrequency))
        .listen((event) {
      setState(() {
        if (_isCollecting) {
          gyroData.add({
            'gX': event.x,
            'gY': event.y,
            'gZ': event.z,
          });
        }

        gX = event.x;
        gY = event.y;
        gZ = event.z;
      });
      // print(gX);
    });
  }

  Future<void> saveData() async {
    List<List> finalList = [];
    String filename = '';
    finalList
        .add(['timestamp', 'accX', 'accY', 'accZ', 'gyroX', 'gyroY', 'gyroZ']);
    for (int i = 0; i < accelData.length; i++) {
      if (i == accelData.length - 1) {
        setState(() {
          filename = '${accelData[i]['time']}_telemetry';
        });
      }
      finalList.add([
        accelData[i]['time'],
        accelData[i]['aX'],
        accelData[i]['aY'],
        accelData[i]['aZ'],
        gyroData[i]['gX'],
        gyroData[i]['gY'],
        gyroData[i]['gZ'],
      ]);
    }

    // Create a CSV file from data
    File file = await createCSVFile(finalList, filename);

    // Upload the file to Firebase
    await uploadToFirebaseStorage(file, filename);
  }

  Future<File> createCSVFile(List<List<dynamic>> rows, String filename) async {
    // Convert our data to CSV string
    String csv = const ListToCsvConverter().convert(rows);

    // Save the CSV data to a file
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/$filename.csv';
    final File file = File(path);
    await file.writeAsString(csv);

    return file;
  }

  Future<void> uploadToFirebaseStorage(File file, String filename) async {
    try {
      // Reference to the folder 'telemetry'
      var reference = FirebaseStorage.instance.ref().child(
          '${FirebaseAuth.instance.currentUser!.uid}/telemetry/$filename.csv');

      // Upload the file to Firebase Storage with metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'text/csv',
      );

      // Upload the file to Firebase Storage
      await reference.putFile(file, metadata);

      // If upload task was successful, print the download link
      final String downloadUrl = await reference.getDownloadURL();
      print("Upload successful: $downloadUrl");
    } catch (e) {
      // e.g, e.code == 'canceled'
      print("Upload failed: $e");
    }
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
